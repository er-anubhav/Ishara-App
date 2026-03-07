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
    // Track last 5 successful sent messages
    final List<Map<String, dynamic>> _lastSentMessages = [];
    List<Map<String, dynamic>> get lastSentMessages => List.unmodifiable(_lastSentMessages);
  // Queue for unsent messages
  final List<Map<String, dynamic>> _publishQueue = [];
  DateTime? _lastSentTime;
  int get queueLength => _publishQueue.length;
  DateTime? get lastSentTime => _lastSentTime;

  // MQTT client and subscription
  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;

  // MQTT connection state

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _errorMessage;

  // Callbacks for vital data
  final List<void Function(String deviceName, String vitalType, dynamic value)> _vitalCallbacks = [];

  // Latest received vitals
  final Map<String, Map<String, dynamic>> _latestVitals = {};

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get errorMessage => _errorMessage;
  Map<String, Map<String, dynamic>> get latestVitals => Map.unmodifiable(_latestVitals);

  /// Connect to MQTT broker
  Future<bool> connect({
    String? host,
    int? port,
    String? clientId,
    String? username,
    String? password,
  }) async {
    if (_isConnecting || _isConnected) return _isConnected;

    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final brokerHost = host ?? mqttBrokerHost;
      final brokerPort = port ?? mqttBrokerPort;
      final mqttClientIdValue = clientId ?? mqttClientId;
      final mqttUsernameValue = username ?? mqttUsername;
      final mqttPasswordValue = password ?? mqttPassword;

      _client = MqttServerClient.withPort(
        brokerHost,
        mqttClientIdValue,
        brokerPort,
      );

      _client!.secure = false;
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 20;
      _client!.autoReconnect = true;
      _client!.onAutoReconnect = _onAutoReconnect;
      _client!.onAutoReconnected = _onAutoReconnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;

      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(mqttClientIdValue)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      await _client!.connect(mqttUsernameValue, mqttPasswordValue);

      if (_client!.connectionStatus?.state != MqttConnectionState.connected) {
        final returnCode = _client!.connectionStatus?.returnCode.toString() ?? 'unknown';
        _errorMessage = 'Connection failed: $returnCode';
        _isConnected = false;
        _client?.disconnect();
        _client = null;
      } else {
        _isConnected = true;
        _subscribeToTelemetry();
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isConnected = false;
      _client?.disconnect();
      _client = null;
    }

    _isConnecting = false;
    notifyListeners();
    return _isConnected;
  }

  /// Subscribe to telemetry topic
  void _subscribeToTelemetry() {
    if (_client == null) return;

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
    if (!_isConnected || _client == null) {
      _publishQueue.add(message);
      notifyListeners();
      return false;
    }
    final sent = await _sendMqttMessage(message);
    if (!sent) {
      _publishQueue.add(message);
      notifyListeners();
    }
    return sent;
  }

  // Internal: send a single message to MQTT
  Future<bool> _sendMqttMessage(Map<String, dynamic> message) async {
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
      return false;
    }
  }

  // Flush queued messages when connected
  Future<void> flushQueue() async {
    if (!_isConnected || _client == null) return;
    while (_publishQueue.isNotEmpty) {
      final msg = _publishQueue.removeAt(0);
      await _sendMqttMessage(msg);
    }
	  notifyListeners();
  }

  /// Register a callback for vital data
  void addVitalCallback(void Function(String deviceName, String vitalType, dynamic value) callback) {
    _vitalCallbacks.add(callback);
  }

  /// Remove a vital callback
  void removeVitalCallback(void Function(String deviceName, String vitalType, dynamic value) callback) {
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
    _subscription?.cancel();
    _subscription = null;
    _client?.disconnect();
    _client = null;
    _isConnected = false;
    notifyListeners();
  }

  void _onConnected() {
    _isConnected = true;
    flushQueue();
    notifyListeners();
  }

  void _onDisconnected() {
    _isConnected = false;
    notifyListeners();
  }

  void _onAutoReconnect() {
    _isConnecting = true;
    // ...existing code...
    notifyListeners();
  }

  void _onAutoReconnected() {
    _isConnecting = false;
    _isConnected = true;
    // ...existing code...
    _subscribeToTelemetry();
    flushQueue();
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
