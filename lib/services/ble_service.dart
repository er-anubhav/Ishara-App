import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'base_client.dart';
import 'mqtt_service.dart';

// BLE Device Status
enum BleDeviceStatus {
  disconnected,
  connected,
  idle,        // Device connected but sending idle/standby values
  measuring,   // Device connected and sending valid measurements
  noFinger,    // Specifically for SpO2 1000 detection
  inflating,   // BP cuff is inflating
  deflating,   // BP cuff is deflating
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
      default:
        return '$value';
    }
  }
}

class BleService {
    // MQTT integration
    void listenAndPushToMqtt(Stream<BleMeasurement> stream, String Function()? getDeviceName) {
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
  final StreamController<String> _dataController = StreamController<String>.broadcast();
  final StreamController<BleMeasurement> _measurementController = StreamController<BleMeasurement>.broadcast();
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
  Stream<BluetoothConnectionState> get connectionStream => _connectionController.stream;
  Stream<BleDeviceStatus> get statusStream => _statusController.stream;
  Stream<String> get measurementSavedStream => _measurementSavedController.stream;
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
    return rawValue >= 9000 ? (rawValue / 100) : (rawValue / 10);
  }

  bool _isValidTemperatureRaw(int rawValue) {
    final tempF = _temperatureFahrenheitFromRaw(rawValue);
    return tempF >= 95.0 && tempF <= 108.0;
  }

  String _formatTemperatureRaw(int rawValue) {
    return '${_temperatureFahrenheitFromRaw(rawValue).toStringAsFixed(2)}°F';
  }

  // Update device status and notify listeners
  void _updateDeviceStatus(BleDeviceStatus status) {
    if (status == BleDeviceStatus.idle) {
      // Prevent rapid flickering from interleaved sensor packets
      final now = DateTime.now();
      final timeSinceValid = _lastValidMeasurement != null ? now.difference(_lastValidMeasurement!).inSeconds : 999;
      final timeSinceNoFinger = _lastNoFinger != null ? now.difference(_lastNoFinger!).inSeconds : 999;
      
      // Preserve higher priority states if they were active in the last 3 seconds
      if (timeSinceValid <= 3 && _deviceStatus == BleDeviceStatus.measuring) return;
      if (timeSinceNoFinger <= 3 && _deviceStatus == BleDeviceStatus.noFinger) return;
      final timeSinceInflating = _lastInflating != null ? now.difference(_lastInflating!).inSeconds : 999;
      final timeSinceDeflating = _lastDeflating != null ? now.difference(_lastDeflating!).inSeconds : 999;
      if (timeSinceInflating <= 3 && _deviceStatus == BleDeviceStatus.inflating) return;
      if (timeSinceDeflating <= 3 && _deviceStatus == BleDeviceStatus.deflating) return;
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
  Stream<List<ScanResult>> scanForDevices({Duration timeout = const Duration(seconds: 10)}) {
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
      
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Subscribe to characteristics that support notify or indicate
          if (characteristic.properties.notify || characteristic.properties.indicate) {
            await characteristic.setNotifyValue(true);
            _characteristicSubscription = characteristic.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                String data = _decodeData(value);
                _dataController.add(data);
                
                // Detect BP cuff text messages (Inflating.../Deflating...)
                final lowerData = data.trim().toLowerCase();
                if (lowerData.contains('inflating')) {
                  debugPrint('ðŸ“¡ BLE Text: Inflating detected');
                  _lastInflating = DateTime.now();
                  _updateDeviceStatus(BleDeviceStatus.inflating);
                  resetIdleTimer();
                  return;
                } else if (lowerData.contains('deflating')) {
                  debugPrint('ðŸ“¡ BLE Text: Deflating detected');
                  _lastDeflating = DateTime.now();
                  _updateDeviceStatus(BleDeviceStatus.deflating);
                  resetIdleTimer();
                  return;
                }
                
                // Parse measurement data (like ble_terminal.py)
                BleMeasurement? measurement = _parseMeasurement(value);
                if (measurement != null) {
                  debugPrint('Emitting measurement to stream: ${measurement.category}, valid=${measurement.isValid}');
                  _measurementController.add(measurement);
                  resetIdleTimer(); // Reset timer on receiving data
                  
                  // Auto-save valid measurements globally (BP handled separately)
                  if (measurement.isValid && _autoSaveEnabled && measurement.category != 'BP_SYS' && measurement.category != 'BP_DIA') {
                    _autoSaveMeasurement(measurement);
                  }
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Service discovery error: $e');
    }
  }

  // Parse measurement data from BLE device (based on ble_terminal.py)
  BleMeasurement? _parseMeasurement(List<int> data) {
    String rawHex = data.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
    // Use print for visibility in all console types
    debugPrint('ðŸ“¡ BLE Raw Data: $rawHex (length: ${data.length})');
    
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
          // Valid range in Fahrenheit; supports x10 and x100 payloads.
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
        default:
          typeName = 'Unknown ($bleType)';
          category = 'Unknown';
          debugPrint('ðŸ“¡ BLE Unknown type: $bleType, value: $value');
      }
      
      if (isValid) {
        debugPrint('âœ… BLE VALID: type=$bleType ($typeName), value=$value, formatted=${_formatValue(category, value)}');
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
        debugPrint('ðŸ“¡ BLE STATE: No Finger detected');
        _lastNoFinger = DateTime.now();
        _updateDeviceStatus(BleDeviceStatus.noFinger);
      } else if (bleType == 0x01 || bleType == 0x02 || bleType == 0x03 || bleType == 0x04) {
        // Known type but invalid value (not 1000)
        debugPrint('âŒ BLE INVALID (out of range): type=$bleType ($typeName), value=$value');
        _updateDeviceStatus(BleDeviceStatus.idle);
      } else {
        // Unknown or diagnostic packet - don't change global status to avoid flickering
        debugPrint('ðŸ“¡ BLE INFO: type=$bleType, value=$value');
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
    debugPrint('ðŸ“¡ BLE Data not 4 bytes, trying alternative parsing...');
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
        return '$value mmHg';
      default:
        return '$value';
    }
  }

  // Decode received data
  String _decodeData(List<int> data) {
    try {
      return utf8.decode(data);
    } catch (e) {
      // If UTF-8 decoding fails, return hex representation
      return data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    }
  }

  // Write data to device
  Future<bool> writeData(String data) async {
    if (_connectedDevice == null) return false;
    
    try {
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
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
    debugPrint('Global auto-save: ${measurement.category}, value=${measurement.value}');
    
    try {
      final now = DateTime.now();
      Map<String, dynamic> datas;
      
      if (measurement.category == 'Temperature') {
        // Store numeric value only (e.g., "98.6" not "98.6 Â°F")
        final tempValue = _temperatureFahrenheitFromRaw(measurement.value).toStringAsFixed(2);
        datas = {"temperature": tempValue};
      } else if (measurement.category == 'SpO2') {
        // Store numeric value only (e.g., "92.1" not "92.1%")
        final spo2Value = (measurement.value / 100).toStringAsFixed(1);
        datas = {"spo2": spo2Value};
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
        
        Get.snackbar(
          'Auto-Saved',
          '${measurement.category}: ${measurement.getFormattedValue()}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.bluetooth, color: Colors.white),
        );
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
        Get.snackbar(
          'Auto-Saved',
          'Blood Pressure: $sys / $dia mmHg',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.favorite, color: Colors.white),
        );
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



