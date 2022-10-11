// To parse this JSON data, do
//
//     final getDailyReminders = getDailyRemindersFromJson(jsonString);

import 'dart:convert';

import 'package:docuhealth/model/daily_reminders/reminder_data.dart';

GetDailyReminders getDailyRemindersFromJson(String str) =>
    GetDailyReminders.fromJson(json.decode(str));

String getDailyRemindersToJson(GetDailyReminders data) =>
    json.encode(data.toJson());

class GetDailyReminders {
  GetDailyReminders({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  List<ReminderData>? data;

  factory GetDailyReminders.fromJson(Map<String, dynamic> json) =>
      GetDailyReminders(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<ReminderData>.from(
                json["data"].map((x) => ReminderData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
