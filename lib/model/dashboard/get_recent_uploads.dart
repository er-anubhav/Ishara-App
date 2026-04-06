// To parse this JSON data, do
//
//     final getRecentUploads = getRecentUploadsFromJson(jsonString);

import 'dart:convert';

import '../documents/documents_data_model.dart';

GetRecentUploads getRecentUploadsFromJson(String str) =>
    GetRecentUploads.fromJson(json.decode(str));

String getRecentUploadsToJson(GetRecentUploads data) =>
    json.encode(data.toJson());

class GetRecentUploads {
  GetRecentUploads({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  List<DocumentData>? data;

  factory GetRecentUploads.fromJson(Map<String, dynamic> json) =>
      GetRecentUploads(
        success: json["success"],
        message: json["message"],
        data: List<DocumentData>.from(
            json["data"].map((x) => DocumentData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
