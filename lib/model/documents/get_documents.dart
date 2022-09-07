// To parse this JSON data, do
//
//     final getDocuments = getDocumentsFromJson(jsonString);

import 'dart:convert';
import '../data_records.dart';
import 'documents_data_model.dart';

GetDocuments getDocumentsFromJson(String str) =>
    GetDocuments.fromJson(json.decode(str));

String getDocumentsToJson(GetDocuments data) => json.encode(data.toJson());

class GetDocuments {
  GetDocuments({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  Data? data;

  factory GetDocuments.fromJson(Map<String, dynamic> json) => GetDocuments(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  Data({
    this.data,
    this.dataRecords,
  });

  List<DocumentData>? data;
  DataRecords? dataRecords;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        data: List<DocumentData>.from(
            json["data"].map((x) => DocumentData.fromJson(x))),
        dataRecords: DataRecords.fromJson(json["data_records"]),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "data_records": dataRecords?.toJson(),
      };
}
