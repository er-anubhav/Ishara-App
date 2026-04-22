// To parse this JSON data, do
//
//     final getFeaturedDoctors = getFeaturedDoctorsFromJson(jsonString);

import 'dart:convert';

import '../doctor_data.dart';

GetFeaturedDoctors getFeaturedDoctorsFromJson(String str) =>
    GetFeaturedDoctors.fromJson(json.decode(str));

String getFeaturedDoctorsToJson(GetFeaturedDoctors data) =>
    json.encode(data.toJson());

class GetFeaturedDoctors {
  GetFeaturedDoctors({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  List<DoctorData>? data;

  factory GetFeaturedDoctors.fromJson(Map<String, dynamic> json) =>
      GetFeaturedDoctors(
        success: json["success"],
        message: json["message"],
        data: List<DoctorData>.from(
            json["data"].map((x) => DoctorData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
