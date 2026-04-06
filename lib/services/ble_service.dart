import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'base_client.dart';
import 'mqtt_service.dart';

// BLE Device Status
enum BleDeviceStatus {
  disconnected,
  connected,
  idle, // Device connected but sending idle/standby values
  measuring, // Device connected and sending valid measurements
  noFinger, // Specifically for SpO2 1000 detection
  inflating, // BP cuff is inflating
  deflating, // BP cuff is deflating
}

// BLE Measurement data class
class BleMeasurement {
  final int type;
  final String typeName;
  final String category;
  final int value;
  final String rawHex;
  final DateTime timestamp;
  final bool isValid;

  BleMeasurement({
    required this.type,
    required this.typeName,
    required this.category,
    required this.value,
    required this.rawHex,
    required this.timestamp,
    required this.isValid,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'type_name': typeName,
        'category': category,
        'value': value,
        'raw_hex': rawHex,
        'timestamp': timestamp.toIso8601String(),
        'is_valid': isValid,
      };

  // Get formatted value based on type
  String getFormattedValue() {
    switch (category) {
      case 'Temperature':
        // Support x10 and x100 hardware payloads.
        final tempValue = value >= 9000 ? (value / 100) : (value / 10);
        return '${tempValue.toStringAsFixed(2)} °F';
      case 'SpO2':
        // Raw value is percentage * 100 (e.g., 9158 = 91.58%)
        return '${(value / 100).toStringAsFixed(1)}%';
      case 'BP_SYS':
      case 'BP_DIA':
        return '$value mmHg';
      case 'Pulse':
        return '$value bpm';
      default:
        return '$value';
    }
  }
}

class BleService {
  static const String _nusServiceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String _nusRxCharUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String _nusTxCharUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  // MQTT integration
  void listenAndPushToMqtt(
      Stream<BleMeasurement> stream, String Function()? getDeviceName) {
    stream.listen((measurement) async {
      if (measurement.isValid) {
        final deviceName = getDeviceName?.call() ?? 'UnknownDevice';
        // Use category as vitalType, value as formatted value
        await mqttService.publishVital(
          deviceName: deviceName,
          vitalType: measurement.category,
          value: measurement.getFormattedValue(),
        );
      }
    });
  }

  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  final _box = GetStorage();
  final _baseClient = BaseClient();
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? _characteristicSubscription;
  BluetoothCharacteristic? _writeCharacteristic;
  final StreamController<String> _dataController =
      StreamController<String>.broadcast();
  final StreamController<BleMeasurement> _measurementController =
      StreamController<BleMeasurement>.broadcast();
  final StreamController<BluetoothConnectionState> _connectionController =
      StreamController<BluetoothConnectionState>.broadcast();
  final StreamController<BleDeviceStatus> _statusController =
      StreamController<BleDeviceStatus>.broadcast();
  final StreamController<String> _measurementSavedController =
      StreamController<String>.broadcast();

  // Device status
  BleDeviceStatus _deviceStatus = BleDeviceStatus.disconnected;
  DateTime? _lastValidMeasurement;
  DateTime? _lastNoFinger;
  DateTime? _lastInflating;
  DateTime? _lastDeflating;

  // Idle timer
  Timer? _idleTimer;
  static const Duration _idleTimeout = Duration(minutes: 5);

  // Pending BP state
  int? _pendingSysBP;
  int? _pendingDiaBP;
  DateTime? _lastBPTime;

  // Auto-save state
  bool _autoSaveEnabled = true;
  static const String _autoSaveKey = 'ble_auto_save_enabled';

  // Getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  Stream<String> get dataStream => _dataController.stream;
  Stream<BleMeasurement> get measurementStream => _measurementController.stream;
  Stream<BluetoothConnectionState> get connectionStream =>
      _connectionController.stream;
  Stream<BleDeviceStatus> get statusStream => _statusController.stream;
  Stream<String> get measurementSavedStream =>
      _measurementSavedController.stream;
  BleDeviceStatus get deviceStatus => _deviceStatus;
  bool get isAutoSaveEnabled => _autoSaveEnabled;

  // Auto-save control
  void setAutoSaveEnabled(bool enabled) {
    _autoSaveEnabled = enabled;
    _box.write(_autoSaveKey, enabled);
  }

  void loadAutoSavePreference() {
    _autoSaveEnabled = _box.read(_autoSaveKey) ?? true;
  }

  // Temperature helpers: firmware may send x10 or x100 values.
  double _temperatureFahrenheitFromRaw(int rawValue) {
    // Home-SpO2 firmware sends x100 (e.g. 9860 = 98.60F).
    // Keep backward compatibility with old x10 payloads.
    return rawValue >= 3000 ? (rawValue / 100) : (rawValue / 10);
  }

  bool _isValidTemperatureRaw(int rawValue) {
    if (rawValue <= 0) return false;
    final tempF = _temperatureFahrenheitFromRaw(rawValue);
    // Relaxed range to avoid rejecting valid probe data.
    return tempF >= 50.0 && tempF <= 150.0;
  }

  String _formatTemperatureRaw(int rawValue) {
    return '${_temperatureFahrenheitFromRaw(rawValue).toStringAsFixed(2)}°F';
  }

  // Update device status and notify listeners
  void _updateDeviceStatus(BleDeviceStatus status) {
    if (status == BleDeviceStatus.idle) {
      // Prevent rapid flickering from interleaved sensor packets
      final now = DateTime.now();
      final timeSinceValid = _lastValidMeasurement != null
          ? now.difference(_lastValidMeasurement!).inSeconds
          : 999;
      final timeSinceNoFinger = _lastNoFinger != null
          ? now.difference(_lastNoFinger!).inSeconds
          : 999;

      // Preserve higher priority states if they were active in the last 3 seconds
      if (timeSinceValid <= 3 && _deviceStatus == BleDeviceStatus.measuring) {
        return;
      }
      if (timeSinceNoFinger <= 3 && _deviceStatus == BleDeviceStatus.noFinger) {
        return;
      }
      final timeSinceInflating = _lastInflating != null
          ? now.difference(_lastInflating!).inSeconds
          : 999;
      final timeSinceDeflating = _lastDeflating != null
          ? now.difference(_lastDeflating!).inSeconds
          : 999;
      if (timeSinceInflating <= 3 &&
          _deviceStatus == BleDeviceStatus.inflating) {
        return;
      }
      if (timeSinceDeflating <= 3 &&
          _deviceStatus == BleDeviceStatus.deflating) {
        return;
      }
    }

    if (_deviceStatus != status) {
      _deviceStatus = status;
      _statusController.add(status);
      debugPrint('ðŸ”µ BLE Status changed: $status');

      // Strict MQTT-BLE linkage:
      // MQTT should connect ONLY when BLE is connected.
      // MQTT should immediately disconnect when BLE is not connected.
      if (status == BleDeviceStatus.connected ||
          status == BleDeviceStatus.measuring ||
          status == BleDeviceStatus.idle ||
          status == BleDeviceStatus.noFinger ||
          status == BleDeviceStatus.inflating ||
          status == BleDeviceStatus.deflating) {
        mqttService.connect();
      } else if (status == BleDeviceStatus.disconnected) {
        mqttService.disconnect();
      }
    }
  }

  // Idle timer logic
  void resetIdleTimer() {
    _idleTimer?.cancel();
    if (_deviceStatus != BleDeviceStatus.disconnected) {
      _idleTimer = Timer(_idleTimeout, () {
        debugPrint('â° BLE Idle timeout reached (5 min). Disconnecting...');
        disconnectDevice();
      });
    }
  }

  // Saved device keys
  static const String _savedDeviceIdKey = 'saved_ble_device_id';
  static const String _savedDeviceNameKey = 'saved_ble_device_name';
  static const String _autoConnectKey = 'ble_auto_connect';

  // Scan for devices
  Stream<List<ScanResult>> scanForDevices(
      {Duration timeout = const Duration(seconds: 10)}) {
    FlutterBluePlus.startScan(timeout: timeout);
    return FlutterBluePlus.scanResults;
  }

  // Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // Connect to device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      _connectedDevice = device;

      // Listen for connection state changes
      device.connectionState.listen((state) {
        _connectionController.add(state);
        if (state == BluetoothConnectionState.disconnected) {
          _connectedDevice = null;
          _characteristicSubscription?.cancel();
          _writeCharacteristic = null;
          _updateDeviceStatus(BleDeviceStatus.disconnected);
        } else if (state == BluetoothConnectionState.connected) {
          _updateDeviceStatus(BleDeviceStatus.connected);
          resetIdleTimer(); // Start timer on connection
        }
      });

      // Discover services and subscribe to notifications
      await _discoverAndSubscribe(device);

      return true;
    } catch (e) {
      debugPrint('BLE Connect Error: $e');
      return false;
    }
  }

  // Discover services and subscribe to characteristics
  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      BluetoothCharacteristic? notifyChar;
      BluetoothCharacteristic? writeChar;

      // Prefer Nordic UART Service characteristics.
      for (BluetoothService service in services) {
        final serviceUuid = service.uuid.toString().toLowerCase();
        final isNusService = serviceUuid == _nusServiceUuid;
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          final charUuid = characteristic.uuid.toString().toLowerCase();

          if (isNusService &&
              charUuid == _nusTxCharUuid &&
              (characteristic.properties.notify ||
                  characteristic.properties.indicate)) {
            notifyChar = characteristic;
          }

          if (isNusService &&
              charUuid == _nusRxCharUuid &&
              (characteristic.properties.write ||
                  characteristic.properties.writeWithoutResponse)) {
            writeChar = characteristic;
          }
        }
      }

      // Fallback if canonical NUS UUIDs are not available.
      if (notifyChar == null || writeChar == null) {
        for (BluetoothService service in services) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (notifyChar == null &&
                (characteristic.properties.notify ||
                    characteristic.properties.indicate)) {
              notifyChar = characteristic;
            }
            if (writeChar == null &&
                (characteristic.properties.write ||
                    characteristic.properties.writeWithoutResponse)) {
              writeChar = characteristic;
            }
          }
        }
      }

      _writeCharacteristic = writeChar;

      if (notifyChar == null) {
        throw Exception('No notifiable characteristic found');
      }

      await notifyChar.setNotifyValue(true);

      _characteristicSubscription?.cancel();
      _characteristicSubscription = notifyChar.lastValueStream.listen((value) {
        if (value.isEmpty) return;

        final data = _decodeData(value);
        _dataController.add(data);

        // Detect BP cuff text messages (Inflating.../Deflating...)
        final lowerData = data.trim().toLowerCase();
        if (lowerData.contains('inflating')) {
          debugPrint('BLE Text: Inflating detected');
          _lastInflating = DateTime.now();
          _updateDeviceStatus(BleDeviceStatus.inflating);
          resetIdleTimer();
          return;
        } else if (lowerData.contains('deflating')) {
          debugPrint('BLE Text: Deflating detected');
          _lastDeflating = DateTime.now();
          _updateDeviceStatus(BleDeviceStatus.deflating);
          resetIdleTimer();
          return;
        }

        final List<BleMeasurement> parsedMeasurements = [];
        final singleMeasurement = _parseMeasurement(value);
        if (singleMeasurement != null) {
          parsedMeasurements.add(singleMeasurement);
        } else if (value.length > 4 && value.length % 4 == 0) {
          // Some stacks can surface concatenated 4-byte frames.
          for (int i = 0; i < value.length; i += 4) {
            final chunk = value.sublist(i, i + 4);
            final m = _parseMeasurement(chunk);
            if (m != null) {
              parsedMeasurements.add(m);
            }
          }
        }

        for (final measurement in parsedMeasurements) {
          debugPrint(
              'Emitting measurement to stream: ${measurement.category}, valid=${measurement.isValid}');
          _measurementController.add(measurement);
          resetIdleTimer();

          // Auto-save valid measurements globally (BP handled separately)
          if (measurement.isValid &&
              _autoSaveEnabled &&
              measurement.category != 'BP_SYS' &&
              measurement.category != 'BP_DIA' &&
              measurement.category != 'BP_MAP') {
            _autoSaveMeasurement(measurement);
          }
        }
      });
    } catch (e) {
      debugPrint('Service discovery error: $e');
    }
  }

  // Parse measurement data from BLE device (based on ble_terminal.py)
  BleMeasurement? _parseMeasurement(List<int> data) {
    String rawHex = data
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
    // Use print for visibility in all console types
    debugPrint('BLE Raw Data: $rawHex (length: ${data.length})');

    if (data.length == 4) {
      int bleType = data[0];
      int value = data[2] | (data[3] << 8);

      String typeName;
      String category;
      bool isValid = false;

      switch (bleType) {
        case 0x01:
          typeName = 'Temperature';
          category = 'Temperature';
          // Relaxed validity so app does not drop legitimate probe values.
          isValid = _isValidTemperatureRaw(value);
          break;
        case 0x02:
          typeName = 'SpO2';
          category = 'SpO2';
          // Valid SpO2 range: 70.00% - 99.00% (raw: 7000-9900)
          // Value 1000 indicates "No Finger" - we track this via status, not DB
          isValid = value >= 7000 && value <= 10000;
          break;
        case 0x03:
          typeName = 'BP_SYS';
          category = 'BP_SYS';
          isValid = value > 0 && value < 300;
          break;
        case 0x04:
          typeName = 'BP_DIA';
          category = 'BP_DIA';
          isValid = value > 0 && value < 200;
          break;
        case 0x05:
          typeName = 'BP_MAP';
          category = 'BP_MAP';
          isValid = value > 0 && value < 250;
          break;
        case 0x06:
          typeName = 'Pulse';
          category = 'Pulse';
          isValid = value >= 30 && value <= 240;
          break;
        default:
          typeName = 'Unknown ($bleType)';
          category = 'Unknown';
          debugPrint('BLE Unknown type: $bleType, value: $value');
      }

      if (isValid) {
        debugPrint(
            'BLE VALID: type=$bleType ($typeName), value=$value, formatted=${_formatValue(category, value)}');
        _lastValidMeasurement = DateTime.now();
        _updateDeviceStatus(BleDeviceStatus.measuring);

        if (category == 'BP_SYS') {
          _pendingSysBP = value;
          _lastBPTime = DateTime.now();
        } else if (category == 'BP_DIA') {
          _pendingDiaBP = value;
          _lastBPTime = DateTime.now();
        }
        _checkAndSaveCombinedBP();
      } else if (bleType == 0x02 && value == 1000) {
        debugPrint('BLE STATE: No Finger detected');
        _lastNoFinger = DateTime.now();
        _updateDeviceStatus(BleDeviceStatus.noFinger);
      } else if (bleType == 0x01 ||
          bleType == 0x02 ||
          bleType == 0x03 ||
          bleType == 0x04 ||
          bleType == 0x05 ||
          bleType == 0x06) {
        // Known type but invalid value (not 1000)
        debugPrint(
            'BLE INVALID (out of range): type=$bleType ($typeName), value=$value');
        _updateDeviceStatus(BleDeviceStatus.idle);
      } else {
        // Unknown or diagnostic packet - don't change global status to avoid flickering
        debugPrint('BLE INFO: type=$bleType, value=$value');
      }
      resetIdleTimer(); // Reset timer on any received characteristic value

      return BleMeasurement(
        type: bleType,
        typeName: typeName,
        category: category,
        value: value,
        rawHex: rawHex,
        timestamp: DateTime.now(),
        isValid: isValid,
      );
    }

    // Try to parse other formats
    debugPrint('BLE data not 4 bytes, trying alternative parsing...');
    return null;
  }

  void _checkAndSaveCombinedBP() {
    if (_pendingSysBP != null && _pendingDiaBP != null && _lastBPTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastBPTime!).inSeconds <= 10) {
        if (_autoSaveEnabled) {
          _autoSaveCombinedBP(_pendingSysBP!, _pendingDiaBP!);
        }
        _pendingSysBP = null;
        _pendingDiaBP = null;
      }
    }
  }

  // Helper to format value for logging
  String _formatValue(String category, int value) {
    switch (category) {
      case 'Temperature':
        return _formatTemperatureRaw(value);
      case 'SpO2':
        return '${(value / 100).toStringAsFixed(1)}%';
      case 'BP_SYS':
      case 'BP_DIA':
      case 'BP_MAP':
        return '$value mmHg';
      case 'Pulse':
        return '$value bpm';
      default:
        return '$value';
    }
  }

  // Decode received data
  bool _isLikelyTextPayload(List<int> data) {
    if (data.isEmpty) return false;
    int printable = 0;
    for (final b in data) {
      final isPrintableAscii = (b >= 32 && b <= 126);
      final isWhitespace = b == 9 || b == 10 || b == 13;
      if (isPrintableAscii || isWhitespace) {
        printable++;
      }
    }
    return printable / data.length >= 0.85;
  }

  String _decodeData(List<int> data) {
    if (_isLikelyTextPayload(data)) {
      try {
        return utf8.decode(data, allowMalformed: true);
      } catch (_) {
        // Fall through to hex.
      }
    }
    return data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  // Write data to device
  Future<bool> writeData(String data) async {
    if (_connectedDevice == null) return false;

    try {
      if (_writeCharacteristic != null) {
        final withoutResponse =
            _writeCharacteristic!.properties.writeWithoutResponse &&
                !_writeCharacteristic!.properties.write;
        await _writeCharacteristic!
            .write(utf8.encode(data), withoutResponse: withoutResponse);
        return true;
      }

      List<BluetoothService> services =
          await _connectedDevice!.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            await characteristic.write(utf8.encode(data));
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Write error: $e');
      return false;
    }
  }

  // Disconnect from device
  Future<void> disconnectDevice() async {
    try {
      _characteristicSubscription?.cancel();
      await _connectedDevice?.disconnect();
      _connectedDevice = null;
      _writeCharacteristic = null;
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }

  // Save device for auto-connect
  Future<void> saveDevice(BluetoothDevice device) async {
    await _box.write(_savedDeviceIdKey, device.remoteId.toString());
    await _box.write(_savedDeviceNameKey, device.platformName);
    await _box.write(_autoConnectKey, true);
  }

  // Remove saved device
  Future<void> removeSavedDevice() async {
    await _box.remove(_savedDeviceIdKey);
    await _box.remove(_savedDeviceNameKey);
    await _box.write(_autoConnectKey, false);
  }

  // Get saved device info
  Map<String, String>? getSavedDevice() {
    final id = _box.read<String>(_savedDeviceIdKey);
    final name = _box.read<String>(_savedDeviceNameKey);
    if (id != null && id.isNotEmpty) {
      return {'id': id, 'name': name ?? 'Unknown Device'};
    }
    return null;
  }

  // Check if auto-connect is enabled
  bool isAutoConnectEnabled() {
    return _box.read<bool>(_autoConnectKey) ?? false;
  }

  // Try to auto-connect to saved device
  Future<bool> tryAutoConnect() async {
    if (!isAutoConnectEnabled()) return false;

    final savedDevice = getSavedDevice();
    if (savedDevice == null) return false;

    // Scan briefly to find the saved device
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    await for (var results in FlutterBluePlus.scanResults) {
      for (var result in results) {
        if (result.device.remoteId.toString() == savedDevice['id']) {
          await FlutterBluePlus.stopScan();
          return await connectToDevice(result.device);
        }
      }
    }

    return false;
  }

  // Auto-save measurement to backend (global, works from any screen)
  Future<void> _autoSaveMeasurement(BleMeasurement measurement) async {
    debugPrint(
        'Global auto-save: ${measurement.category}, value=${measurement.value}');

    try {
      final now = DateTime.now();
      Map<String, dynamic> datas;

      if (measurement.category == 'Temperature') {
        // Store numeric value only (e.g., "98.6" not "98.6 °F")
        final tempValue =
            _temperatureFahrenheitFromRaw(measurement.value).toStringAsFixed(2);
        datas = {"temperature": tempValue};
      } else if (measurement.category == 'SpO2') {
        // Store numeric value only (e.g., "92.1" not "92.1%")
        final spo2Value = (measurement.value / 100).toStringAsFixed(1);
        datas = {"spo2": spo2Value};
      } else if (measurement.category == 'Pulse') {
        datas = {"pulse_rate": measurement.value.toString()};
      } else {
        debugPrint('Unhandled category: ${measurement.category}');
        return;
      }

      debugPrint('Sending to backend: $datas');

      final data = {
        'date': DateFormat('dd-MM-yyyy').format(now),
        'time': DateFormat('hh:mm a').format(now),
        'category': measurement.category,
        'datas': json.encode(datas),
        'comment': 'Auto-fetched from BLE device',
        'is_auto_fetched': true,
      };

      final response = await _baseClient.post('measurements', data, true);
      debugPrint('Backend response: $response');

      if (response['success'] == true) {
        // Notify listeners that a measurement was saved
        _measurementSavedController.add(measurement.category);
      } else {
        debugPrint('Auto-save failed: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Auto-save error: $e');
    }
  }

  Future<void> _autoSaveCombinedBP(int sys, int dia) async {
    debugPrint('Global auto-save: Combined BP Sys=$sys Dia=$dia');
    try {
      final now = DateTime.now();
      final datas = {
        "upper_bound": sys.toString(),
        "lower_bound": dia.toString()
      };

      final data = {
        'date': DateFormat('dd-MM-yyyy').format(now),
        'time': DateFormat('hh:mm a').format(now),
        'category': 'BP',
        'datas': json.encode(datas),
        'comment': 'Auto-fetched from BLE device',
        'is_auto_fetched': true,
      };

      final response = await _baseClient.post('measurements', data, true);
      debugPrint('Backend response (BP): $response');

      if (response['success'] == true) {
        _measurementSavedController.add('BP');
      } else {
        debugPrint('Auto-save BP failed: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Auto-save BP error: $e');
    }
  }

  // Dispose
  void dispose() {
    _idleTimer?.cancel();
    _characteristicSubscription?.cancel();
    _dataController.close();
    _measurementController.close();
    _connectionController.close();
    _statusController.close();
    _measurementSavedController.close();
  }
}
