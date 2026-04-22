// To parse this JSON data, do
//
//     final getAnalytics = getAnalyticsFromJson(jsonString);

import 'dart:convert';

import 'analytics_data.dart';

GetAnalytics getAnalyticsFromJson(String str) =>
    GetAnalytics.fromJson(json.decode(str));

String getAnalyticsToJson(GetAnalytics data) => json.encode(data.toJson());

class GetAnalytics {
  GetAnalytics({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  List<AnalyticsData>? data;

  factory GetAnalytics.fromJson(Map<String, dynamic> json) => GetAnalytics(
        success: json["success"],
        message: json["message"],
        data: List<AnalyticsData>.from(
            json["data"].map((x) => AnalyticsData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
