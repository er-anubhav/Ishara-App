import 'dart:convert';

/// Device Vital model representing a single vital reading from hardware
class DeviceVital {
  final int? id;
  final int? profileId;
  final String deviceName;
  final String vitalType;
  final double value;
  final String? unit;
  final DateTime? recordedAt;
  final DateTime? createdAt;

  DeviceVital({
    this.id,
    this.profileId,
    required this.deviceName,
    required this.vitalType,
    required this.value,
    this.unit,
    this.recordedAt,
    this.createdAt,
  });

  factory DeviceVital.fromJson(Map<String, dynamic> json) => DeviceVital(
        id: json['id'],
        profileId: json['profile_id'],
        deviceName: json['device_name'] ?? '',
        vitalType: json['vital_type'] ?? '',
        value: (json['value'] is int)
            ? (json['value'] as int).toDouble()
            : double.tryParse(json['value']?.toString() ?? '0') ?? 0,
        unit: json['unit'],
        recordedAt: json['recorded_at'] != null
            ? DateTime.tryParse(json['recorded_at'])
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'profile_id': profileId,
        'device_name': deviceName,
        'vital_type': vitalType,
        'value': value,
        'unit': unit,
        'recorded_at': recordedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  /// Vital type constants
  static const String typeBodyTemp = 'Body_Temp';
  static const String typeSpo2 = 'SpO2';
  static const String typeBpSys = 'BP_SYS';
  static const String typeBpDia = 'BP_DIA';

  /// Display name for vital type
  String get displayName {
    switch (vitalType) {
      case typeBodyTemp:
        return 'Body Temperature';
      case typeSpo2:
        return 'SpO2 (Oxygen)';
      case typeBpSys:
        return 'Blood Pressure (Systolic)';
      case typeBpDia:
        return 'Blood Pressure (Diastolic)';
      default:
        return vitalType;
    }
  }

  /// Formatted value with unit
  String get formattedValue {
    final unitStr = unit ?? '';
    if (vitalType == typeBodyTemp) {
      return '${value.toStringAsFixed(2)} $unitStr';
    }
    return '${value.toStringAsFixed(0)} $unitStr';
  }
}

/// Response wrapper for getting device vitals list
class GetDeviceVitalsResponse {
  final bool success;
  final String? message;
  final List<DeviceVital> data;

  GetDeviceVitalsResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory GetDeviceVitalsResponse.fromJson(Map<String, dynamic> json) =>
      GetDeviceVitalsResponse(
        success: json['success'] ?? false,
        message: json['message'],
        data: json['data'] != null
            ? List<DeviceVital>.from(
                (json['data'] as List).map((x) => DeviceVital.fromJson(x)))
            : [],
      );
}

GetDeviceVitalsResponse getDeviceVitalsFromJson(String str) =>
    GetDeviceVitalsResponse.fromJson(json.decode(str));

/// Response wrapper for latest vitals (keyed by type)
class LatestVitalsResponse {
  final bool success;
  final String? message;
  final Map<String, DeviceVitalSummary?> data;

  LatestVitalsResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory LatestVitalsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, DeviceVitalSummary?> vitalsMap = {};
    
    if (json['data'] is Map) {
      final dataMap = json['data'] as Map<String, dynamic>;
      for (final entry in dataMap.entries) {
        if (entry.value != null) {
          vitalsMap[entry.key] = DeviceVitalSummary.fromJson(entry.value);
        } else {
          vitalsMap[entry.key] = null;
        }
      }
    }

    return LatestVitalsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: vitalsMap,
    );
  }

  DeviceVitalSummary? get bodyTemp => data[DeviceVital.typeBodyTemp];
  DeviceVitalSummary? get spo2 => data[DeviceVital.typeSpo2];
  DeviceVitalSummary? get bpSys => data[DeviceVital.typeBpSys];
  DeviceVitalSummary? get bpDia => data[DeviceVital.typeBpDia];
}

LatestVitalsResponse getLatestVitalsFromJson(String str) =>
    LatestVitalsResponse.fromJson(json.decode(str));

/// Summary of a single vital type
class DeviceVitalSummary {
  final double value;
  final String? unit;
  final String deviceName;
  final DateTime? recordedAt;

  DeviceVitalSummary({
    required this.value,
    this.unit,
    required this.deviceName,
    this.recordedAt,
  });

  factory DeviceVitalSummary.fromJson(Map<String, dynamic> json) =>
      DeviceVitalSummary(
        value: (json['value'] is int)
            ? (json['value'] as int).toDouble()
            : double.tryParse(json['value']?.toString() ?? '0') ?? 0,
        unit: json['unit'],
        deviceName: json['device_name'] ?? '',
        recordedAt: json['recorded_at'] != null
            ? DateTime.tryParse(json['recorded_at'])
            : null,
      );
}

/// Response for vital analytics
class VitalAnalyticsResponse {
  final bool success;
  final String? message;
  final VitalAnalyticsData? data;

  VitalAnalyticsResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory VitalAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      VitalAnalyticsResponse(
        success: json['success'] ?? false,
        message: json['message'],
        data: json['data'] != null
            ? VitalAnalyticsData.fromJson(json['data'])
            : null,
      );
}

VitalAnalyticsResponse getVitalAnalyticsFromJson(String str) =>
    VitalAnalyticsResponse.fromJson(json.decode(str));

class VitalAnalyticsData {
  final String vitalType;
  final String? unit;
  final String period;
  final String startDate;
  final String endDate;
  final VitalStatistics statistics;
  final List<VitalDateGroup> data;

  VitalAnalyticsData({
    required this.vitalType,
    this.unit,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.statistics,
    required this.data,
  });

  factory VitalAnalyticsData.fromJson(Map<String, dynamic> json) =>
      VitalAnalyticsData(
        vitalType: json['vital_type'] ?? '',
        unit: json['unit'],
        period: json['period'] ?? 'day',
        startDate: json['start_date'] ?? '',
        endDate: json['end_date'] ?? '',
        statistics: VitalStatistics.fromJson(json['statistics'] ?? {}),
        data: json['data'] != null
            ? List<VitalDateGroup>.from(
                (json['data'] as List).map((x) => VitalDateGroup.fromJson(x)))
            : [],
      );
}

class VitalStatistics {
  final double? min;
  final double? max;
  final double? avg;
  final int count;

  VitalStatistics({
    this.min,
    this.max,
    this.avg,
    required this.count,
  });

  factory VitalStatistics.fromJson(Map<String, dynamic> json) =>
      VitalStatistics(
        min: json['min']?.toDouble(),
        max: json['max']?.toDouble(),
        avg: json['avg']?.toDouble(),
        count: json['count'] ?? 0,
      );
}

class VitalDateGroup {
  final String date;
  final List<VitalReading> readings;

  VitalDateGroup({
    required this.date,
    required this.readings,
  });

  factory VitalDateGroup.fromJson(Map<String, dynamic> json) => VitalDateGroup(
        date: json['date'] ?? '',
        readings: json['readings'] != null
            ? List<VitalReading>.from(
                (json['readings'] as List).map((x) => VitalReading.fromJson(x)))
            : [],
      );
}

class VitalReading {
  final String time;
  final double value;

  VitalReading({
    required this.time,
    required this.value,
  });

  factory VitalReading.fromJson(Map<String, dynamic> json) => VitalReading(
        time: json['time'] ?? '',
        value: (json['value'] is int)
            ? (json['value'] as int).toDouble()
            : double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      );
}

/// Device info
class DeviceInfo {
  final String deviceName;
  final int readingCount;
  final DateTime? lastReading;

  DeviceInfo({
    required this.deviceName,
    required this.readingCount,
    this.lastReading,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        deviceName: json['device_name'] ?? '',
        readingCount: json['reading_count'] ?? 0,
        lastReading: json['last_reading'] != null
            ? DateTime.tryParse(json['last_reading'])
            : null,
      );
}

class GetDevicesResponse {
  final bool success;
  final String? message;
  final List<DeviceInfo> data;

  GetDevicesResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory GetDevicesResponse.fromJson(Map<String, dynamic> json) =>
      GetDevicesResponse(
        success: json['success'] ?? false,
        message: json['message'],
        data: json['data'] != null
            ? List<DeviceInfo>.from(
                (json['data'] as List).map((x) => DeviceInfo.fromJson(x)))
            : [],
      );
}

GetDevicesResponse getDevicesFromJson(String str) =>
    GetDevicesResponse.fromJson(json.decode(str));
