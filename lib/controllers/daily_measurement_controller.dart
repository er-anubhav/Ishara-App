import 'dart:convert';
import 'dart:io';
import 'package:docuhealth/model/daily_measurement/get_analytics.dart';
import 'package:docuhealth/model/daily_measurement/get_daily_measurements.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/daily_measurement/analytics_data.dart';
import '../model/daily_measurement/measurement_data.dart';

class DailyMeasurement extends ChangeNotifier {
  BaseClient baseClient = BaseClient();
  GetDailyMeasurements getDailyMeasurements = GetDailyMeasurements();
  GetAnalytics getAnalytics = GetAnalytics();
  List<MeasurementData>? measurementData = [];
  List<AnalyticsData>? analyticsData = [];

  Future<bool> addMeasureMent(String category, body, File? attachment) async {
    String encodedData = json.encode(body);
    final response = attachment == null
        ? await baseClient.post('measurements', encodedData, true)
        : await baseClient.dataWithAttachment(
            'measurements', encodedData, attachment.path, true);

    if (response['success']) {
      return true;
    } else {
      return false;
    }
  }

  Future getMeasurementsData(DateTime selectedPickerDate) async {
    final response = await baseClient.get(
      'measurements?date=${DateFormat('dd-MM-yyyy').format(selectedPickerDate)}',
      true,
    );
    final getDailyMeasurements = getDailyMeasurementsFromJson(response);
    if (getDailyMeasurements.success!) {
      measurementData = getDailyMeasurements.data;
    } else {
      measurementData = [];
    }
    notifyListeners();
  }

  Future getAnalyticsData(DateTime selectedPickerDate) async {
    final response = await baseClient.get(
      'measurements?date=${DateFormat('dd-MM-yyyy').format(selectedPickerDate)}',
      true,
    );
    getAnalytics = getAnalyticsFromJson(response);
    if (getAnalytics.success!) {
      analyticsData = getAnalytics.data;
    } else {
      analyticsData = [];
    }
    notifyListeners();
  }
}
