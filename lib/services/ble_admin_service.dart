import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_service.dart';

class BleAdminException implements Exception {
  final String message;

  const BleAdminException(this.message);

  @override
  String toString() => message;
}

enum AdminFieldKind {
  integer,
  decimal,
  text,
  select,
}

class AdminFieldOption {
  final String value;
  final String label;

  const AdminFieldOption({
    required this.value,
    required this.label,
  });
}

class AdminFieldDefinition {
  final String key;
  final String label;
  final AdminFieldKind kind;
  final bool required;
  final String? helperText;
  final String? unit;
  final num? min;
  final num? max;
  final List<AdminFieldOption> options;

  const AdminFieldDefinition({
    required this.key,
    required this.label,
    required this.kind,
    this.required = true,
    this.helperText,
    this.unit,
    this.min,
    this.max,
    this.options = const [],
  });
}

class AdminConfigProfile {
  final String id;
  final String title;
  final String description;
  final String modeLabel;
  final List<AdminFieldDefinition> fields;

  const AdminConfigProfile({
    required this.id,
    required this.title,
    required this.description,
    required this.modeLabel,
    required this.fields,
  });
}

class AdminConfigSnapshot {
  final AdminConfigProfile profile;
  final Map<String, String> values;
  final String rawLine;

  const AdminConfigSnapshot({
    required this.profile,
    required this.values,
    required this.rawLine,
  });
}

class AdminVerifyResult {
  final AdminConfigSnapshot current;
  final AdminConfigSnapshot candidate;

  const AdminVerifyResult({
    required this.current,
    required this.candidate,
  });
}

class BleAdminService {
  static final BleAdminService _instance = BleAdminService._internal();
  factory BleAdminService() => _instance;
  BleAdminService._internal();

  final BleService _bleService = BleService();
  String? _cachedSchemaDeviceId;
  AdminConfigProfile? _cachedSchema;

  static const Duration _defaultTimeout = Duration(seconds: 6);

  static const Set<String> _knownTokens = {
    'PASSWORD?',
    'UNLOCK_OK',
    'WRONG_PASSWORD',
    'BAD_PASSWORD',
    'WRONG_FORMAT',
    'BAD_FORMAT',
    'LOCKED',
    'CANDIDATE_OK',
    'ROOM_CANDIDATE_OK',
    'VERIFY_FAIL',
    'SAVE_OK',
    'SAVE_FAIL',
    'FACTORY_RESET',
    'SCHEMA_END',
    'UNKNOWN_CMD',
  };

  static const AdminConfigProfile _bpProfile = AdminConfigProfile(
    id: 'bp_legacy_v1',
    title: 'Blood Pressure Config',
    description:
        'Legacy six-field BP configuration exposed over BLE UART commands.',
    modeLabel: 'Legacy BP Adapter',
    fields: [
      AdminFieldDefinition(
        key: 'sensor_no',
        label: 'Sensor Number',
        kind: AdminFieldKind.integer,
        min: 0,
        max: 99,
      ),
      AdminFieldDefinition(
        key: 'version',
        label: 'Version',
        kind: AdminFieldKind.text,
        helperText: 'Firmware config version string.',
      ),
      AdminFieldDefinition(
        key: 'room_code',
        label: 'Room Code',
        kind: AdminFieldKind.text,
      ),
      AdminFieldDefinition(
        key: 'bp_raw_zero',
        label: 'BP Raw Zero',
        kind: AdminFieldKind.integer,
      ),
      AdminFieldDefinition(
        key: 'bp_slope_mmHg_per_count',
        label: 'BP Slope',
        kind: AdminFieldKind.decimal,
      ),
      AdminFieldDefinition(
        key: 'bp_intercept',
        label: 'BP Intercept',
        kind: AdminFieldKind.decimal,
      ),
    ],
  );

  static const AdminConfigProfile _spo2Profile = AdminConfigProfile(
    id: 'spo2_legacy_v1',
    title: 'SpO2 Config',
    description:
        'Legacy five-field SpO2 configuration exposed over BLE UART commands.',
    modeLabel: 'Legacy SpO2 Adapter',
    fields: [
      AdminFieldDefinition(
        key: 'sensor_no',
        label: 'Sensor Number',
        kind: AdminFieldKind.integer,
        min: 0,
        max: 99,
      ),
      AdminFieldDefinition(
        key: 'version',
        label: 'Version',
        kind: AdminFieldKind.text,
      ),
      AdminFieldDefinition(
        key: 'no_finger',
        label: 'No Finger Threshold',
        kind: AdminFieldKind.integer,
      ),
      AdminFieldDefinition(
        key: 'spo2_scan_rate',
        label: 'SpO2 Scan Rate',
        kind: AdminFieldKind.integer,
        unit: 'sec',
        min: 1,
      ),
      AdminFieldDefinition(
        key: 'temp_scan_rate',
        label: 'Temperature Scan Rate',
        kind: AdminFieldKind.integer,
        unit: 'sec',
        min: 1,
      ),
    ],
  );

  static const AdminConfigProfile _nurseCallProfile = AdminConfigProfile(
    id: 'nurse_call_legacy_v1',
    title: 'Nurse Call Config',
    description:
        'Legacy seven-field Nurse Call configuration exposed over BLE UART commands.',
    modeLabel: 'Legacy Nurse Call Adapter',
    fields: [
      AdminFieldDefinition(
        key: 'heartbeat_time_s',
        label: 'Heartbeat Time',
        kind: AdminFieldKind.integer,
        unit: 'sec',
        min: 1,
      ),
      AdminFieldDefinition(
        key: 'temp_sensor',
        label: 'Temperature Sensor',
        kind: AdminFieldKind.select,
        options: [
          AdminFieldOption(value: '0', label: 'Disabled'),
          AdminFieldOption(value: '1', label: 'Enabled'),
        ],
      ),
      AdminFieldDefinition(
        key: 'temp_scan_rate_s',
        label: 'Temperature Scan Rate',
        kind: AdminFieldKind.integer,
        unit: 'sec',
        min: 1,
      ),
      AdminFieldDefinition(
        key: 'hum_sensor',
        label: 'Humidity Sensor',
        kind: AdminFieldKind.select,
        options: [
          AdminFieldOption(value: '0', label: 'Disabled'),
          AdminFieldOption(value: '1', label: 'Enabled'),
        ],
      ),
      AdminFieldDefinition(
        key: 'hum_scan_rate_s',
        label: 'Humidity Scan Rate',
        kind: AdminFieldKind.integer,
        unit: 'sec',
        min: 1,
      ),
      AdminFieldDefinition(
        key: 'room_code',
        label: 'Room Code',
        kind: AdminFieldKind.text,
      ),
      AdminFieldDefinition(
        key: 'battery_mode',
        label: 'Battery Mode',
        kind: AdminFieldKind.select,
        options: [
          AdminFieldOption(value: '0', label: 'Main Power'),
          AdminFieldOption(value: '1', label: 'Battery'),
        ],
      ),
    ],
  );

  BluetoothDevice? get connectedDevice => _bleService.connectedDevice;

  Future<void> unlock(String password) async {
    await _ensureConnected();

    final prompt = await _sendForSingleResponse(
      command: 'c',
      successMatcher: (line) => line == 'PASSWORD?',
      timeoutMessage: 'Timed out while waiting for the device password prompt.',
    );

    if (prompt != 'PASSWORD?') {
      throw const BleAdminException(
          'Device did not request an admin password.');
    }

    final result = await _sendForSingleResponse(
      command: 'p|$password',
      successMatcher: (line) => line == 'UNLOCK_OK',
      timeoutMessage: 'Timed out while verifying the admin password.',
    );

    if (result != 'UNLOCK_OK') {
      throw _mapErrorLine(
        result,
        fallback: 'Admin password verification failed.',
      );
    }
  }

  Future<AdminConfigSnapshot> readCurrentConfig() async {
    await _ensureConnected();
    final schema = await _readSchemaOrNull();

    final cfgLine = await _sendForSingleResponse(
      command: 'r',
      successMatcher: (line) => line.startsWith('CFG|'),
      timeoutMessage: 'Timed out while reading the current device config.',
    );

    if (schema != null) {
      return _parseSnapshotForProfile(
        profile: schema,
        rawLine: cfgLine,
        expectedPrefix: 'CFG',
      );
    }

    return _parseSnapshotFromRawLine(cfgLine);
  }

  Future<AdminVerifyResult> verifyConfig({
    required AdminConfigProfile profile,
    required Map<String, String> editedValues,
    required String password,
  }) async {
    await unlock(password);
    await _stageCandidate(profile: profile, editedValues: editedValues);

    final completer = Completer<AdminVerifyResult>();
    String? currentLine;
    String? newLine;

    late StreamSubscription<String> subscription;
    subscription = _listenForAdminLines((line) async {
      if (line == 'VERIFY_FAIL') {
        if (!completer.isCompleted) {
          completer.completeError(
            const BleAdminException(
              'Device rejected the candidate config during verification.',
            ),
          );
        }
        await subscription.cancel();
        return;
      }

      if (line.startsWith('CUR|')) {
        currentLine = line;
      } else if (line.startsWith('NEW|')) {
        newLine = line;
      }

      if (currentLine != null && newLine != null && !completer.isCompleted) {
        completer.complete(
          AdminVerifyResult(
            current: _parseSnapshotForProfile(
              profile: profile,
              rawLine: currentLine!,
              expectedPrefix: 'CUR',
            ),
            candidate: _parseSnapshotForProfile(
              profile: profile,
              rawLine: newLine!,
              expectedPrefix: 'NEW',
            ),
          ),
        );
        await subscription.cancel();
      }
    });

    final didSend = await _bleService.writeData('v');
    if (!didSend) {
      await subscription.cancel();
      throw const BleAdminException('Unable to send the verify command.');
    }

    try {
      return await completer.future.timeout(
        _defaultTimeout,
        onTimeout: () {
          throw const BleAdminException(
            'Timed out while waiting for the verify result.',
          );
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  Future<AdminConfigSnapshot> saveConfig({
    required AdminConfigProfile profile,
    required Map<String, String> editedValues,
    required String password,
  }) async {
    await unlock(password);
    await _stageCandidate(profile: profile, editedValues: editedValues);

    final completer = Completer<AdminConfigSnapshot>();
    var saveAccepted = false;

    late StreamSubscription<String> subscription;
    subscription = _listenForAdminLines((line) async {
      if (line == 'SAVE_FAIL') {
        if (!completer.isCompleted) {
          completer.completeError(
            const BleAdminException('Device failed to save the NVS config.'),
          );
        }
        await subscription.cancel();
        return;
      }

      if (line == 'SAVE_OK') {
        saveAccepted = true;
        return;
      }

      if (saveAccepted && line.startsWith('CFG|') && !completer.isCompleted) {
        completer.complete(
          _parseSnapshotForProfile(
            profile: profile,
            rawLine: line,
            expectedPrefix: 'CFG',
          ),
        );
        await subscription.cancel();
      }
    });

    final didSend = await _bleService.writeData('s');
    if (!didSend) {
      await subscription.cancel();
      throw const BleAdminException('Unable to send the save command.');
    }

    try {
      return await completer.future.timeout(
        _defaultTimeout,
        onTimeout: () {
          throw const BleAdminException(
            'Timed out while waiting for the save response.',
          );
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> factoryReset({
    required String password,
  }) async {
    await unlock(password);

    final line = await _sendForSingleResponse(
      command: 'f',
      successMatcher: (response) => response == 'FACTORY_RESET',
      timeoutMessage: 'Timed out while waiting for the factory reset response.',
    );

    if (line != 'FACTORY_RESET') {
      throw _mapErrorLine(
        line,
        fallback: 'Device did not accept the factory reset command.',
      );
    }
  }

  Future<void> _stageCandidate({
    required AdminConfigProfile profile,
    required Map<String, String> editedValues,
  }) async {
    final serializedValues = profile.fields
        .map((field) => editedValues[field.key]?.trim() ?? '')
        .join('|');

    final response = await _sendForSingleResponse(
      command: 'c|$serializedValues',
      successMatcher: (line) =>
          line == 'CANDIDATE_OK' || line == 'ROOM_CANDIDATE_OK',
      timeoutMessage: 'Timed out while staging the candidate config.',
    );

    if (response != 'CANDIDATE_OK' && response != 'ROOM_CANDIDATE_OK') {
      throw _mapErrorLine(
        response,
        fallback: 'Device rejected the candidate config.',
      );
    }
  }

  Future<String> _sendForSingleResponse({
    required String command,
    required bool Function(String line) successMatcher,
    required String timeoutMessage,
  }) async {
    await _ensureConnected();

    final completer = Completer<String>();

    late StreamSubscription<String> subscription;
    subscription = _listenForAdminLines((line) async {
      if (successMatcher(line)) {
        if (!completer.isCompleted) {
          completer.complete(line);
        }
        await subscription.cancel();
        return;
      }

      if (_isErrorLine(line)) {
        if (!completer.isCompleted) {
          completer.completeError(
            _mapErrorLine(line, fallback: 'Device returned an admin error.'),
          );
        }
        await subscription.cancel();
      }
    });

    final didSend = await _bleService.writeData(command);
    if (!didSend) {
      await subscription.cancel();
      throw BleAdminException('Unable to send the command: $command');
    }

    try {
      return await completer.future.timeout(
        _defaultTimeout,
        onTimeout: () {
          throw BleAdminException(timeoutMessage);
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> _ensureConnected() async {
    if (_bleService.connectedDevice == null) {
      _clearSchemaCache();
      throw const BleAdminException(
        'Connect a BLE device before opening admin controls.',
      );
    }
  }

  Future<AdminConfigProfile?> _readSchemaOrNull() async {
    await _ensureConnected();

    final deviceId = _bleService.connectedDevice?.remoteId.toString();
    if (deviceId != null &&
        deviceId == _cachedSchemaDeviceId &&
        _cachedSchema != null) {
      return _cachedSchema;
    }

    final completer = Completer<AdminConfigProfile?>();
    String? schemaHeader;
    final fields = <AdminFieldDefinition>[];

    late StreamSubscription<String> subscription;
    subscription = _listenForAdminLines((line) async {
      if (line == 'UNKNOWN_CMD') {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        await subscription.cancel();
        return;
      }

      if (line.startsWith('SCHEMA|')) {
        schemaHeader = line;
        return;
      }

      if (line.startsWith('FIELD|')) {
        fields.add(_parseSchemaField(line));
        return;
      }

      if (line == 'SCHEMA_END') {
        if (!completer.isCompleted) {
          if (schemaHeader == null) {
            completer.completeError(
              const BleAdminException('Device returned an empty schema.'),
            );
          } else {
            final profile = _parseSchemaProfile(
              schemaHeader: schemaHeader!,
              fields: fields,
            );
            _cachedSchemaDeviceId = deviceId;
            _cachedSchema = profile;
            completer.complete(profile);
          }
        }
        await subscription.cancel();
      }
    });

    final didSend = await _bleService.writeData('m');
    if (!didSend) {
      await subscription.cancel();
      throw const BleAdminException('Unable to send the schema command.');
    }

    try {
      return await completer.future.timeout(
        _defaultTimeout,
        onTimeout: () => null,
      );
    } finally {
      await subscription.cancel();
    }
  }

  StreamSubscription<String> _listenForAdminLines(
    void Function(String line) onLine,
  ) {
    var buffer = '';

    void emitIfRecognized(String candidate) {
      final trimmed = candidate.trim();
      if (trimmed.isEmpty) {
        return;
      }
      if (_looksLikeAdminLine(trimmed)) {
        onLine(trimmed);
      }
    }

    return _bleService.dataStream.listen((chunk) {
      buffer += chunk.replaceAll('\r', '\n');

      while (buffer.contains('\n')) {
        final splitIndex = buffer.indexOf('\n');
        final line = buffer.substring(0, splitIndex);
        buffer = buffer.substring(splitIndex + 1);
        emitIfRecognized(line);
      }
    });
  }

  bool _looksLikeAdminLine(String line) {
    if (_knownTokens.contains(line)) {
      return true;
    }

    return line.startsWith('CFG|') ||
        line.startsWith('SCHEMA|') ||
        line.startsWith('FIELD|') ||
        line.startsWith('CUR|') ||
        line.startsWith('NEW|');
  }

  bool _isErrorLine(String line) {
    return line == 'WRONG_PASSWORD' ||
        line == 'BAD_PASSWORD' ||
        line == 'WRONG_FORMAT' ||
        line == 'BAD_FORMAT' ||
        line == 'LOCKED' ||
        line == 'VERIFY_FAIL' ||
        line == 'SAVE_FAIL' ||
        line == 'UNKNOWN_CMD';
  }

  BleAdminException _mapErrorLine(
    String line, {
    required String fallback,
  }) {
    switch (line) {
      case 'WRONG_PASSWORD':
      case 'BAD_PASSWORD':
        return const BleAdminException('Admin password is incorrect.');
      case 'WRONG_FORMAT':
      case 'BAD_FORMAT':
        return const BleAdminException('Device rejected the command format.');
      case 'LOCKED':
        return const BleAdminException(
          'Device is locked. Unlock it again before editing config.',
        );
      case 'VERIFY_FAIL':
        return const BleAdminException('Device reported verify failure.');
      case 'SAVE_FAIL':
        return const BleAdminException('Device reported save failure.');
      case 'UNKNOWN_CMD':
        return const BleAdminException(
          'Device firmware does not support this admin command.',
        );
      default:
        return BleAdminException(fallback);
    }
  }

  AdminConfigSnapshot _parseSnapshotFromRawLine(String rawLine) {
    final parts = rawLine.split('|');
    if (parts.isEmpty || parts.first != 'CFG') {
      throw const BleAdminException(
          'Device returned an invalid config payload.');
    }

    final profile = _resolveLegacyProfile(parts.length - 1);
    return _buildSnapshotFromParts(
      profile: profile,
      rawLine: rawLine,
      expectedPrefix: 'CFG',
    );
  }

  AdminConfigProfile _parseSchemaProfile({
    required String schemaHeader,
    required List<AdminFieldDefinition> fields,
  }) {
    final parts = schemaHeader.split('|');
    if (parts.length < 5 || parts.first != 'SCHEMA') {
      throw const BleAdminException(
          'Device returned an invalid schema header.');
    }

    final expectedFieldCount = int.tryParse(parts[4]);
    if (expectedFieldCount == null) {
      throw const BleAdminException('Device returned an invalid field count.');
    }

    if (fields.length != expectedFieldCount) {
      throw BleAdminException(
        'Device schema is incomplete. Expected $expectedFieldCount fields, '
        'received ${fields.length}.',
      );
    }

    return AdminConfigProfile(
      id: parts[1],
      title: parts[2],
      description: parts[3],
      modeLabel: 'Device Schema',
      fields: fields,
    );
  }

  AdminFieldDefinition _parseSchemaField(String rawLine) {
    final parts = rawLine.split('|');
    if (parts.length < 10 || parts.first != 'FIELD') {
      throw const BleAdminException('Device returned an invalid schema field.');
    }

    return AdminFieldDefinition(
      key: parts[1],
      label: parts[2],
      kind: _parseFieldKind(parts[3]),
      required: parts[4] == '1',
      min: _parseNumberOrNull(parts[5]),
      max: _parseNumberOrNull(parts[6]),
      unit: _emptyToNull(parts[7]),
      options: _parseFieldOptions(parts[8]),
      helperText: _emptyToNull(parts[9]),
    );
  }

  AdminFieldKind _parseFieldKind(String rawKind) {
    switch (rawKind.toLowerCase()) {
      case 'int':
      case 'integer':
        return AdminFieldKind.integer;
      case 'float':
      case 'double':
      case 'decimal':
        return AdminFieldKind.decimal;
      case 'select':
      case 'enum':
      case 'bool':
      case 'boolean':
        return AdminFieldKind.select;
      case 'text':
      case 'string':
      default:
        return AdminFieldKind.text;
    }
  }

  List<AdminFieldOption> _parseFieldOptions(String rawOptions) {
    if (rawOptions.trim().isEmpty) {
      return const [];
    }

    return rawOptions
        .split(',')
        .where((item) => item.trim().isNotEmpty)
        .map((item) {
      final separatorIndex = item.indexOf(':');
      if (separatorIndex == -1) {
        final value = item.trim();
        return AdminFieldOption(value: value, label: value);
      }

      final value = item.substring(0, separatorIndex).trim();
      final label = item.substring(separatorIndex + 1).trim();
      return AdminFieldOption(value: value, label: label);
    }).toList();
  }

  num? _parseNumberOrNull(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) {
      return null;
    }

    return num.tryParse(value);
  }

  String? _emptyToNull(String rawValue) {
    final value = rawValue.trim();
    return value.isEmpty ? null : value;
  }

  AdminConfigSnapshot _parseSnapshotForProfile({
    required AdminConfigProfile profile,
    required String rawLine,
    required String expectedPrefix,
  }) {
    return _buildSnapshotFromParts(
      profile: profile,
      rawLine: rawLine,
      expectedPrefix: expectedPrefix,
    );
  }

  AdminConfigSnapshot _buildSnapshotFromParts({
    required AdminConfigProfile profile,
    required String rawLine,
    required String expectedPrefix,
  }) {
    final parts = rawLine.split('|');

    if (parts.isEmpty || parts.first != expectedPrefix) {
      throw BleAdminException(
        'Unexpected response prefix. Expected $expectedPrefix.',
      );
    }

    if (parts.length - 1 != profile.fields.length) {
      throw const BleAdminException(
        'Device returned a config shape that does not match the selected adapter.',
      );
    }

    final values = <String, String>{};
    for (var index = 0; index < profile.fields.length; index++) {
      values[profile.fields[index].key] = parts[index + 1];
    }

    return AdminConfigSnapshot(
      profile: profile,
      values: values,
      rawLine: rawLine,
    );
  }

  AdminConfigProfile _resolveLegacyProfile(int valueCount) {
    final deviceName =
        (_bleService.connectedDevice?.platformName ?? '').toUpperCase();

    if (deviceName.startsWith('BP') && valueCount == _bpProfile.fields.length) {
      return _bpProfile;
    }

    if (deviceName.startsWith('SP') &&
        valueCount == _spo2Profile.fields.length) {
      return _spo2Profile;
    }

    if (deviceName.startsWith('NC') &&
        valueCount == _nurseCallProfile.fields.length) {
      return _nurseCallProfile;
    }

    throw BleAdminException(
      'This device does not expose a schema yet, and its legacy config layout '
      'does not match the adapters bundled in the app.',
    );
  }

  void _clearSchemaCache() {
    _cachedSchemaDeviceId = null;
    _cachedSchema = null;
  }
}
