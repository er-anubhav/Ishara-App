import 'dart:convert';
import 'dart:io';
import 'package:docuhealth/model/daily_measurement/get_analytics.dart';
import 'package:docuhealth/model/daily_measurement/get_daily_measurements.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/daily_measurement/analytics_data.dart';
import '../model/daily_measurement/graph_data.dart';
import '../model/daily_measurement/measurement_data.dart';

class DailyMeasurementController extends ChangeNotifier {
  BaseClient baseClient = BaseClient();
  GetDailyMeasurements getDailyMeasurements = GetDailyMeasurements();
  GetAnalytics getAnalytics = GetAnalytics();
  List<MeasurementData>? measurementData = [];
  List<AnalyticsData>? analyticsData = [];
  List<GraphData> graphValue = [];
  List<GraphData> upperBond = [];
  List<GraphData> lowerBond = [];

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

  Future getMeasurementsData(
      DateTime selectedPickerDate, String selectedCategory) async {
    getAnalyticsData(selectedPickerDate, selectedCategory);
    final response = await baseClient.get(
      'measurements?date=${DateFormat('dd-MM-yyyy').format(selectedPickerDate)}&category=$selectedCategory',
      true,
    );
    var apiResponse = jsonEncode(response);
    final getDailyMeasurements = getDailyMeasurementsFromJson(apiResponse);
    if (getDailyMeasurements.success!) {
      measurementData = getDailyMeasurements.data;
    } else {
      measurementData = [];
    }
    notifyListeners();
  }

  Future onDeleteButtonPress(int recordId) async {
    final response =
        await baseClient.get('measurements/delete/$recordId', true);
    return response['success'];
  }

  Future getAnalyticsData(date, category) async {
    final response = await baseClient.get(
      'measurements/analytics?date=$date&category=$category',
      true,
    );
    var apiResponse = jsonEncode(response);
    getAnalytics = getAnalyticsFromJson(apiResponse);
    if (getAnalytics.success!) {
      analyticsData = getAnalytics.data;
      if (getAnalytics.success!) {
        graphValue = [];
        upperBond = [];
        lowerBond = [];
        for (var i = 0; i < getAnalytics.data!.length; i++) {
          for (var j = 0; j < getAnalytics.data![i].values!.length; j++) {
            if (getAnalytics.data![i].values![j].category == "BP") {
              upperBond.add(
                GraphData(
                  '${getAnalytics.data![i].label ?? ''} ${getAnalytics.data![i].values![j].time ?? ''}',
                  double.parse(getAnalytics
                      .data![i].values![j].measurements!.upperBound!),
                ),
              );
              lowerBond.add(
                GraphData(
                  '${getAnalytics.data![i].label ?? ''} ${getAnalytics.data![i].values![j].time ?? ''}',
                  double.parse(getAnalytics
                      .data![i].values![j].measurements!.lowerBound!),
                ),
              );
            } else if (getAnalytics.data![i].values![j].category == "Pulse") {
              graphValue.add(
                GraphData(
                  '${getAnalytics.data![i].label ?? ''} ${getAnalytics.data![i].values![j].time ?? ''}',
                  double.parse(getAnalytics
                      .data![i].values![j].measurements!.pulseRate!),
                ),
              );
            } else if (getAnalytics.data![i].values![j].category == "Weight") {
              graphValue.add(
                GraphData(
                  '${getAnalytics.data![i].label ?? ''} ${getAnalytics.data![i].values![j].time ?? ''}',
                  double.parse(
                      getAnalytics.data![i].values![j].measurements!.weight!),
                ),
              );
            } else if (getAnalytics.data![i].values![j].category == "Sugar") {
              GraphData(
                '${getAnalytics.data![i].label ?? ''} ${getAnalytics.data![i].values![j].time ?? ''}',
                double.parse(
                    getAnalytics.data![i].values![j].measurements!.sugarLavel!),
              );
            }
          }
        }
      }
    } else {
      analyticsData = [];
    }
    notifyListeners();
  }
}
