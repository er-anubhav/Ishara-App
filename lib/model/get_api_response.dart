// To parse this JSON data, do
//
//     final getApiResponse = getApiResponseFromJson(jsonString);

import 'dart:convert';

GetApiResponse getApiResponseFromJson(String str) =>
    GetApiResponse.fromJson(json.decode(str));

String getApiResponseToJson(GetApiResponse data) => json.encode(data.toJson());

class GetApiResponse {
  GetApiResponse({
    this.success,
    this.message,
  });

  bool? success;
  String? message;

  factory GetApiResponse.fromJson(Map<String, dynamic> json) => GetApiResponse(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
