import 'dart:async';
import 'dart:convert';

import 'package:docuhealth/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// MQTT Service for receiving vital data from hardware devices
///
/// This service connects to the MQTT broker and listens for telemetry
/// data published by BLE gateway devices.
class MqttService extends ChangeNotifier {
  static const Duration _reconnectCheckInterval = Duration(seconds: 8);
  static const Duration _staleConnectingTimeout = Duration(seconds: 35);

  // Track last 5 successful sent messages
  final List<Map<String, dynamic>> _lastSentMessages = [];
  List<Map<String, dynamic>> get lastSentMessages =>
      List.unmodifiable(_lastSentMessages);
  // Queue for unsent messages
  final List<Map<String, dynamic>> _publishQueue = [];
  DateTime? _lastSentTime;
  int get queueLength => _publishQueue.length;
  DateTime? get lastSentTime => _lastSentTime;

  // MQTT client and subscription
  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;
  Timer? _reconnectTimer;

  // MQTT connection state

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _shouldStayConnected = false;
  DateTime? _connectingSince;
  String? _errorMessage;

  // Callbacks for vital data
  final List<void Function(String deviceName, String vitalType, dynamic value)>
      _vitalCallbacks = [];

  // Latest received vitals
  final Map<String, Map<String, dynamic>> _latestVitals = {};

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get errorMessage => _errorMessage;
  Map<String, Map<String, dynamic>> get latestVitals =>
      Map.unmodifiable(_latestVitals);

  bool get _isClientConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Duration _connectingAge() {
    final startedAt = _connectingSince;
    if (startedAt == null) return Duration.zero;
    return DateTime.now().difference(startedAt);
  }

  void _startReconnectMonitor() {
    _reconnectTimer ??= Timer.periodic(_reconnectCheckInterval, (_) {
      unawaited(_reconnectMonitorTick());
    });
  }

  void _stopReconnectMonitor() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Future<void> _reconnectMonitorTick() async {
    if (!_shouldStayConnected) return;

    if (_isClientConnected) {
      if (!_isConnected || _isConnecting) {
        _isConnected = true;
        _isConnecting = false;
        _connectingSince = null;
        _errorMessage = null;
        notifyListeners();
      }
      if (_publishQueue.isNotEmpty) {
        await flushQueue();
      }
      return;
    }

    if (_isConnecting && _connectingAge() < _staleConnectingTimeout) {
      return;
    }

    if (_isConnecting && _connectingAge() >= _staleConnectingTimeout) {
      _errorMessage = 'MQTT connect timed out, retrying...';
      _isConnecting = false;
      _connectingSince = null;
      await _disposeClient();
      notifyListeners();
    }

    await connect();
  }

  Future<void> _disposeClient() async {
    await _subscription?.cancel();
    _subscription = null;

    final client = _client;
    _client = null;
    if (client == null) return;

    // Avoid callback loops while force-resetting/rebuilding the client.
    client.onDisconnected = null;
    client.onConnected = null;
    client.onAutoReconnect = null;
    client.onAutoReconnected = null;

    try {
      client.disconnect();
    } catch (_) {
      // Ignore disconnect failures while resetting.
    }
  }

  /// Connect to MQTT broker
  Future<bool> connect({
    String? host,
    int? port,
    String? clientId,
    String? username,
    String? password,
  }) async {
    _shouldStayConnected = true;
    _startReconnectMonitor();

    if (_isClientConnected) {
      _isConnected = true;
      _isConnecting = false;
      _connectingSince = null;
      _errorMessage = null;
      if (_publishQueue.isNotEmpty) {
        unawaited(flushQueue());
      }
      notifyListeners();
      return true;
    }

    if (_isConnecting && _connectingAge() < _staleConnectingTimeout) {
      return false;
    }

    if (_isConnecting && _connectingAge() >= _staleConnectingTimeout) {
      await _disposeClient();
      _isConnecting = false;
      _connectingSince = null;
    }

    _isConnecting = true;
    _isConnected = false;
    _connectingSince = DateTime.now();
    _errorMessage = null;
    notifyListeners();

    try {
      final brokerHost = host ?? mqttBrokerHost;
      final brokerPort = port ?? mqttBrokerPort;
      final mqttClientIdValue = clientId ?? mqttClientId;
      final mqttUsernameValue = username ?? mqttUsername;
      final mqttPasswordValue = password ?? mqttPassword;

      await _disposeClient();

      _client = MqttServerClient.withPort(
        brokerHost,
        mqttClientIdValue,
        brokerPort,
      );

      _client!.secure = false;
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 20;
      _client!.connectTimeoutPeriod = 8000;
      _client!.autoReconnect = true;
      _client!.resubscribeOnAutoReconnect = true;
      _client!.onAutoReconnect = _onAutoReconnect;
      _client!.onAutoReconnected = _onAutoReconnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;

      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(mqttClientIdValue)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      await _client!.connect(mqttUsernameValue, mqttPasswordValue);

      if (!_isClientConnected) {
        final returnCode =
            _client!.connectionStatus?.returnCode.toString() ?? 'unknown';
        _errorMessage = 'Connection failed: $returnCode';
        _isConnected = false;
        _isConnecting = false;
        _connectingSince = null;
        await _disposeClient();
        notifyListeners();
      } else {
        _onConnected();
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isConnected = false;
      _isConnecting = false;
      _connectingSince = null;
      await _disposeClient();
      notifyListeners();
    }

    return _isConnected;
  }

  /// Subscribe to telemetry topic
  void _subscribeToTelemetry() {
    if (!_isClientConnected || _client == null) return;

    _client!.subscribe(mqttTelemetryTopic, MqttQos.atLeastOnce);

    _subscription?.cancel();
    _subscription = _client!.updates?.listen(_onMessage);
  }

  /// Handle incoming MQTT messages
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final MqttPublishMessage recMess = message.payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      _parseAndNotify(message.topic, payload);
    }
  }

  /// Parse MQTT payload and notify listeners
  /// Expected format: {device_name: [{vital_type: value}]}
  void _parseAndNotify(String topic, String payload) {
    try {
      final data = jsonDecode(payload);

      if (data is! Map<String, dynamic>) return;

      for (final entry in data.entries) {
        final deviceName = entry.key;
        final readings = entry.value;

        if (readings is! List) continue;

        // Initialize device map if needed
        _latestVitals[deviceName] ??= {};

        for (final reading in readings) {
          if (reading is! Map<String, dynamic>) continue;

          for (final vitalEntry in reading.entries) {
            final vitalType = vitalEntry.key;
            final value = vitalEntry.value;

            // Update latest vitals
            _latestVitals[deviceName]![vitalType] = value;

            // Notify callbacks
            for (final callback in _vitalCallbacks) {
              callback(deviceName, vitalType, value);
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      // ...existing code...
    }
  }

  /// Publish vital data to MQTT
  Future<bool> publishVital({
    required String deviceName,
    required String vitalType,
    required dynamic value,
  }) async {
    final message = {
      'deviceName': deviceName,
      'vitalType': vitalType,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (!_isClientConnected || _client == null) {
      _isConnected = false;
      _publishQueue.add(message);
      if (_shouldStayConnected && !_isConnecting) {
        unawaited(connect());
      }
      notifyListeners();
      return false;
    }
    final sent = await _sendMqttMessage(message);
    if (!sent) {
      _publishQueue.add(message);
      if (_shouldStayConnected && !_isConnecting) {
        unawaited(connect());
      }
      notifyListeners();
    }
    return sent;
  }

  // Internal: send a single message to MQTT
  Future<bool> _sendMqttMessage(Map<String, dynamic> message) async {
    if (!_isClientConnected || _client == null) {
      _isConnected = false;
      return false;
    }

    try {
      final payload = jsonEncode({
        message['deviceName']: [
          {message['vitalType']: message['value']}
        ]
      });
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      _client!.publishMessage(
        mqttTelemetryTopic,
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      _lastSentTime = DateTime.now();
      _isConnected = true;
      _isConnecting = false;
      _connectingSince = null;
      _errorMessage = null;
      // Track last 5 successful sent messages
      _lastSentMessages.add({
        ...message,
        'sentAt': _lastSentTime!.toIso8601String(),
      });
      if (_lastSentMessages.length > 5) {
        _lastSentMessages.removeAt(0);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Publish failed: $e';
      _isConnected = false;
      return false;
    }
  }

  // Flush queued messages when connected
  Future<void> flushQueue() async {
    if (!_isClientConnected || _client == null) return;
    while (_publishQueue.isNotEmpty && _isClientConnected) {
      final msg = _publishQueue.first;
      final sent = await _sendMqttMessage(msg);
      if (!sent) break;
      _publishQueue.removeAt(0);
    }
    notifyListeners();
  }

  /// Register a callback for vital data
  void addVitalCallback(
      void Function(String deviceName, String vitalType, dynamic value)
          callback) {
    _vitalCallbacks.add(callback);
  }

  /// Remove a vital callback
  void removeVitalCallback(
      void Function(String deviceName, String vitalType, dynamic value)
          callback) {
    _vitalCallbacks.remove(callback);
  }

  /// Get latest value for a device and vital type
  dynamic getLatestValue(String deviceName, String vitalType) {
    return _latestVitals[deviceName]?[vitalType];
  }

  /// Get all known device names
  List<String> get knownDevices => _latestVitals.keys.toList();

  /// Disconnect from MQTT broker
  void disconnect() {
    _shouldStayConnected = false;
    _stopReconnectMonitor();
    _isConnected = false;
    _isConnecting = false;
    _connectingSince = null;
    _errorMessage = null;
    unawaited(_disposeClient());
    notifyListeners();
  }

  void _onConnected() {
    if (!_shouldStayConnected) return;
    _isConnecting = false;
    _isConnected = true;
    _connectingSince = null;
    _errorMessage = null;
    _subscribeToTelemetry();
    if (_publishQueue.isNotEmpty) {
      unawaited(flushQueue());
    }
    notifyListeners();
  }

  void _onDisconnected() {
    _isConnected = false;
    _isConnecting = false;
    _connectingSince = null;
    if (_shouldStayConnected) {
      _startReconnectMonitor();
      unawaited(_reconnectMonitorTick());
    }
    notifyListeners();
  }

  void _onAutoReconnect() {
    _isConnecting = true;
    _isConnected = false;
    _connectingSince ??= DateTime.now();
    notifyListeners();
  }

  void _onAutoReconnected() {
    _isConnecting = false;
    _isConnected = true;
    _connectingSince = null;
    _errorMessage = null;
    _subscribeToTelemetry();
    if (_publishQueue.isNotEmpty) {
      unawaited(flushQueue());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _vitalCallbacks.clear();
    super.dispose();
  }
}

/// Global MQTT service instance (optional singleton pattern)
MqttService? _mqttServiceInstance;

MqttService get mqttService {
  _mqttServiceInstance ??= MqttService();
  return _mqttServiceInstance!;
}
