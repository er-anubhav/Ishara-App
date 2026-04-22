// To parse this JSON data, do
//
//     final getBanners = getBannersFromJson(jsonString);

import 'dart:convert';

import 'banners_data.dart';

GetBanners getBannersFromJson(String str) =>
    GetBanners.fromJson(json.decode(str));

String getBannersToJson(GetBanners data) => json.encode(data.toJson());

class GetBanners {
  GetBanners({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  List<BannerData>? data;

  factory GetBanners.fromJson(Map<String, dynamic> json) => GetBanners(
        success: json["success"],
        message: json["message"],
        data: List<BannerData>.from(
            json["data"].map((x) => BannerData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
