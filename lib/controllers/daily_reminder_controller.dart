import 'dart:convert';
import 'package:docuhealth/model/daily_reminders/get_daily_reminders.dart';
import 'package:docuhealth/model/daily_reminders/reminder_data.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyReminderController extends ChangeNotifier {
  BaseClient baseClient = BaseClient();
  GetDailyReminders getDailyReminders = GetDailyReminders();
  List<ReminderData> allReminders = [];
  List<ReminderData> datewiseReminders = [];
  bool isLoading = false;

  Future getDailyReminder() async {
    isLoading = true;
    notifyListeners();
    final response = await BaseClient().get('reminders', true);
    var apiResponse = jsonEncode(response);
    final getDailyReminders = getDailyRemindersFromJson(apiResponse);
    if (getDailyReminders.success!) {
      allReminders = getDailyReminders.data ?? [];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> getDateWiseReminder(DateTime selectedDate) async {
    isLoading = true;
    notifyListeners();
    final response = await BaseClient().get(
        'reminders?date=${DateFormat('dd-MM-yyyy').format(selectedDate)}',
        true);
    var apiResponse = jsonEncode(response);
    final getDailyReminders = getDailyRemindersFromJson(apiResponse);
    if (getDailyReminders.success!) {
      datewiseReminders = getDailyReminders.data ?? [];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> onSwitchPress(int id, bool status) async {
    final response = await BaseClient()
        .post('reminders/status', {"id": "$id", "status": status}, true);

    if (response['success']) {
      getDailyReminder();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  Future<bool> onDeleteButtonPress(int id) async {
    final response = await BaseClient().get('reminders/delete/$id', true);
    if (response['success']) {
      getDailyReminder();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }
}
