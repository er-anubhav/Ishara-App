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

  // Month abbreviation to number mapping
  static const Map<String, String> _monthMap = {
    'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
    'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
    'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12',
  };

  // Format date from "dd MMM" (like "05 Mar") to dd/MM
  String _formatDateLabel(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      // Handle "dd MMM" format (e.g., "05 Mar")
      final parts = dateStr.trim().split(' ');
      if (parts.length >= 2) {
        final day = parts[0].padLeft(2, '0');
        final monthAbbr = parts[1];
        final monthNum = _monthMap[monthAbbr];
        if (monthNum != null) {
          return '$day/$monthNum';
        }
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

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
    try {
      final response = await baseClient.get(
        'measurements?date=${DateFormat('dd-MM-yyyy').format(selectedPickerDate)}&category=$selectedCategory',
        true,
        showSnackbar: false,
      );
      var apiResponse = jsonEncode(response);
      final getDailyMeasurements = getDailyMeasurementsFromJson(apiResponse);
      if (getDailyMeasurements.success!) {
        measurementData = getDailyMeasurements.data;
      } else {
        measurementData = [];
      }
    } catch (e) {
      debugPrint('getMeasurementsData error: $e');
      measurementData = [];
    }
    notifyListeners();
  }

  Future onDeleteButtonPress(int recordId) async {
    try {
      final response =
          await baseClient.get('measurements/delete/$recordId', true);
      return response['success'];
    } catch (e) {
      debugPrint('onDeleteButtonPress error: $e');
      return false;
    }
  }

  Future<void> getAnalyticsData(String timeFilter, String category) async {
    try {
      final response = await baseClient.get(
        'measurements/analytics?date=$timeFilter&category=$category',
        true,
        showSnackbar: false,
      );
      debugPrint('Analytics API Response for $category: $response');
      var apiResponse = jsonEncode(response);
      getAnalytics = getAnalyticsFromJson(apiResponse);
      if (getAnalytics.success!) {
        analyticsData = getAnalytics.data;
        debugPrint('Analytics data count: ${analyticsData?.length ?? 0}');
        if (getAnalytics.success!) {
          graphValue = [];
          upperBond = [];
          lowerBond = [];
          for (var i = 0; i < getAnalytics.data!.length; i++) {
            debugPrint('Processing label: ${getAnalytics.data![i].label}, values count: ${getAnalytics.data![i].values?.length ?? 0}');
            for (var j = 0; j < getAnalytics.data![i].values!.length; j++) {
              final value = getAnalytics.data![i].values![j];
              final formattedDate = _formatDateLabel(getAnalytics.data![i].label);
              final label = '$formattedDate ${value.time ?? ''}';
              final measurements = value.measurements;
              debugPrint('Value category: ${value.category}, measurements: ${measurements?.toJson()}');
              
              try {
                if (value.category == "BP" && measurements?.upperBound != null && measurements?.lowerBound != null) {
                  upperBond.add(GraphData(label, double.parse(measurements!.upperBound!)));
                  lowerBond.add(GraphData(label, double.parse(measurements.lowerBound!)));
                } else if (value.category == "Pulse" && measurements?.pulseRate != null) {
                  // Strip any units and parse numeric value
                  final pulseStr = measurements!.pulseRate!.replaceAll(RegExp(r'[^0-9.]'), '');
                  graphValue.add(GraphData(label, double.parse(pulseStr)));
                  debugPrint('Added Pulse: ${measurements.pulseRate} -> $pulseStr');
                } else if (value.category == "Weight" && measurements?.weight != null) {
                  // Strip any units (Kg, lbs, etc) and parse numeric value
                  final weightStr = measurements!.weight!.replaceAll(RegExp(r'[^0-9.]'), '');
                  graphValue.add(GraphData(label, double.parse(weightStr)));
                  debugPrint('Added Weight: ${measurements.weight} -> $weightStr');
                } else if (value.category == "Sugar" && measurements?.sugarLavel != null) {
                  // Strip any units and parse numeric value
                  final sugarStr = measurements!.sugarLavel!.replaceAll(RegExp(r'[^0-9.]'), '');
                  graphValue.add(GraphData(label, double.parse(sugarStr)));
                  debugPrint('Added Sugar: ${measurements.sugarLavel} -> $sugarStr');
                } else if (value.category == "Temperature" && measurements?.temperature != null) {
                  // Check if it's explicitly in Celsius
                  final tempString = measurements!.temperature!.toUpperCase();
                  final isCelsius = tempString.contains('C');
                  
                  // Strip any units (°F, °C, etc) and parse numeric value
                  final tempStr = measurements.temperature!.replaceAll(RegExp(r'[^0-9.]'), '');
                  double tempValue = double.parse(tempStr);
                  
                  // Convert to Fahrenheit if needed so the graph is uniform
                  if (isCelsius) {
                    tempValue = (tempValue * 9 / 5) + 32;
                    // Round to 2 decimal places
                    tempValue = double.parse(tempValue.toStringAsFixed(2));
                  }
                  
                  graphValue.add(GraphData(label, tempValue));
                  debugPrint('Added Temperature: ${measurements.temperature} -> plotted as $tempValue °F');
                } else if (value.category == "SpO2" && measurements?.spo2 != null) {
                  // Strip any units (%, etc) and parse numeric value
                  final spo2Str = measurements!.spo2!.replaceAll(RegExp(r'[^0-9.]'), '');
                  graphValue.add(GraphData(label, double.parse(spo2Str)));
                  debugPrint('Added SpO2: ${measurements.spo2} -> $spo2Str');
                }
              } catch (parseError) {
                debugPrint('Error parsing measurement for ${value.category}: $parseError');
              }
            }
          }
          debugPrint('Final graphValue count: ${graphValue.length}, upperBond: ${upperBond.length}, lowerBond: ${lowerBond.length}');
        }
      } else {
        analyticsData = [];
      }
    } catch (e) {
      debugPrint('getAnalyticsData error: $e');
      analyticsData = [];
      graphValue = [];
      upperBond = [];
      lowerBond = [];
    }
    notifyListeners();
  }
}
