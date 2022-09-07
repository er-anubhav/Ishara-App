// To parse this JSON data, do
//
//     final getDailyMeasurements = getDailyMeasurementsFromJson(jsonString);

import 'dart:convert';
import 'package:docuhealth/model/daily_measurement/measurement_data.dart';

GetDailyMeasurements getDailyMeasurementsFromJson(String str) =>
    GetDailyMeasurements.fromJson(json.decode(str));

String getDailyMeasurementsToJson(GetDailyMeasurements data) =>
    json.encode(data.toJson());

class GetDailyMeasurements {
  GetDailyMeasurements({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  List<MeasurementData>? data;

  factory GetDailyMeasurements.fromJson(Map<String, dynamic> json) =>
      GetDailyMeasurements(
        success: json["success"],
        message: json["message"],
        data: List<MeasurementData>.from(
            json["data"].map((x) => MeasurementData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
