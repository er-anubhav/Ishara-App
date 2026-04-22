import 'dart:convert';

import 'package:docuhealth/model/device_vital/device_vital.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Controller for device vitals that come from BLE hardware via MQTT
class DeviceVitalController extends ChangeNotifier {
  final BaseClient _baseClient = BaseClient();

  // Latest vitals for dashboard display
  LatestVitalsResponse? latestVitals;

  // Historical data
  List<DeviceVital> vitalHistory = [];

  // Analytics data
  VitalAnalyticsData? analyticsData;

  // Linked devices
  List<DeviceInfo> devices = [];

  // Loading states
  bool isLoadingLatest = false;
  bool isLoadingHistory = false;
  bool isLoadingAnalytics = false;
  bool isLoadingDevices = false;

  // Error messages
  String? errorMessage;

  /// Fetch latest vitals for all types (dashboard view)
  Future<void> fetchLatestVitals({String? deviceName}) async {
    isLoadingLatest = true;
    errorMessage = null;
    notifyListeners();

    try {
      String endpoint = 'device-vitals/latest';
      if (deviceName != null && deviceName.isNotEmpty) {
        endpoint += '?device_name=$deviceName';
      }

      final response = await _baseClient.get(endpoint, true);
      final jsonResponse = jsonEncode(response);
      latestVitals = getLatestVitalsFromJson(jsonResponse);

      if (!latestVitals!.success) {
        errorMessage = latestVitals!.message;
      }
    } catch (e) {
      errorMessage = 'Failed to fetch latest vitals: $e';
    }

    isLoadingLatest = false;
    notifyListeners();
  }

  /// Fetch vital history with optional filters
  Future<void> fetchVitalHistory({
    String? vitalType,
    String? deviceName,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    isLoadingHistory = true;
    errorMessage = null;
    notifyListeners();

    try {
      final params = <String>[];
      
      if (vitalType != null) {
        params.add('vital_type=$vitalType');
      }
      if (deviceName != null) {
        params.add('device_name=$deviceName');
      }
      if (date != null) {
        params.add('date=${DateFormat('yyyy-MM-dd').format(date)}');
      }
      if (startDate != null) {
        params.add('start_date=${DateFormat('yyyy-MM-dd').format(startDate)}');
      }
      if (endDate != null) {
        params.add('end_date=${DateFormat('yyyy-MM-dd').format(endDate)}');
      }
      params.add('limit=$limit');

      final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
      final response = await _baseClient.get('device-vitals$queryString', true);
      final jsonResponse = jsonEncode(response);
      final result = getDeviceVitalsFromJson(jsonResponse);

      if (result.success) {
        vitalHistory = result.data;
      } else {
        errorMessage = result.message;
        vitalHistory = [];
      }
    } catch (e) {
      errorMessage = 'Failed to fetch vital history: $e';
      vitalHistory = [];
    }

    isLoadingHistory = false;
    notifyListeners();
  }

  /// Fetch analytics for a specific vital type
  Future<void> fetchAnalytics({
    required String vitalType,
    String period = 'day',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    isLoadingAnalytics = true;
    errorMessage = null;
    notifyListeners();

    try {
      final params = <String>['vital_type=$vitalType', 'period=$period'];
      
      if (startDate != null) {
        params.add('start_date=${DateFormat('yyyy-MM-dd').format(startDate)}');
      }
      if (endDate != null) {
        params.add('end_date=${DateFormat('yyyy-MM-dd').format(endDate)}');
      }

      final queryString = '?${params.join('&')}';
      final response = await _baseClient.get('device-vitals/analytics$queryString', true);
      final jsonResponse = jsonEncode(response);
      final result = getVitalAnalyticsFromJson(jsonResponse);

      if (result.success) {
        analyticsData = result.data;
      } else {
        errorMessage = result.message;
        analyticsData = null;
      }
    } catch (e) {
      errorMessage = 'Failed to fetch analytics: $e';
      analyticsData = null;
    }

    isLoadingAnalytics = false;
    notifyListeners();
  }

  /// Fetch list of linked devices
  Future<void> fetchDevices() async {
    isLoadingDevices = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _baseClient.get('device-vitals/devices', true);
      final jsonResponse = jsonEncode(response);
      final result = getDevicesFromJson(jsonResponse);

      if (result.success) {
        devices = result.data;
      } else {
        errorMessage = result.message;
        devices = [];
      }
    } catch (e) {
      errorMessage = 'Failed to fetch devices: $e';
      devices = [];
    }

    isLoadingDevices = false;
    notifyListeners();
  }

  /// Link a device to the current profile
  Future<bool> linkDevice(String deviceName) async {
    try {
      final response = await _baseClient.post(
        'device-vitals/link-device',
        {'device_name': deviceName},
        true,
      );

      if (response['success'] == true) {
        await fetchDevices();
        return true;
      } else {
        errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to link device: $e';
      return false;
    }
  }

  /// Store a vital reading directly (from the POC app)
  Future<bool> storeVital({
    required String deviceName,
    required String vitalType,
    required double value,
    DateTime? recordedAt,
  }) async {
    try {
      final payload = {
        'device_name': deviceName,
        'vital_type': vitalType,
        'value': value,
        if (recordedAt != null) 'recorded_at': recordedAt.toIso8601String(),
      };

      final response = await _baseClient.post('device-vitals', payload, true);

      if (response['success'] == true) {
        // Refresh latest vitals after storing
        await fetchLatestVitals();
        return true;
      } else {
        errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to store vital: $e';
      return false;
    }
  }

  /// Store vital in MQTT format (from the POC app gateway)
  Future<bool> storeVitalMqttFormat({
    required String deviceName,
    required String vitalType,
    required dynamic value,
  }) async {
    try {
      // Build MQTT format payload: {device_name: [{vital_type: value}]}
      final payload = {
        deviceName: [
          {vitalType: value}
        ]
      };

      final response = await _baseClient.post('device-vitals', payload, true);

      if (response['success'] == true) {
        await fetchLatestVitals();
        return true;
      } else {
        errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to store vital: $e';
      return false;
    }
  }

  /// Delete a vital reading
  Future<bool> deleteVital(int id) async {
    try {
      final response = await _baseClient.get('device-vitals/delete/$id', true);

      if (response['success'] == true) {
        vitalHistory.removeWhere((v) => v.id == id);
        notifyListeners();
        return true;
      } else {
        errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to delete vital: $e';
      return false;
    }
  }

  /// Get formatted display string for a vital type's latest value
  String getLatestValueDisplay(String vitalType) {
    if (latestVitals == null || latestVitals!.data[vitalType] == null) {
      return '--';
    }

    final vital = latestVitals!.data[vitalType]!;
    final unit = vital.unit ?? '';

    if (vitalType == DeviceVital.typeBodyTemp) {
      return '${vital.value.toStringAsFixed(2)} $unit';
    }
    return '${vital.value.toStringAsFixed(0)} $unit';
  }

  /// Check if any vitals are available
  bool get hasAnyVitals {
    if (latestVitals == null) return false;
    return latestVitals!.data.values.any((v) => v != null);
  }

  /// Clear all data
  void clear() {
    latestVitals = null;
    vitalHistory = [];
    analyticsData = null;
    devices = [];
    errorMessage = null;
    notifyListeners();
  }
}
