import 'dart:convert';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:docuhealth/model/daily_reminders/get_daily_reminders.dart';
import 'package:docuhealth/model/daily_reminders/reminder_data.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyReminderController extends ChangeNotifier {
  static const String _localRemindersKey = 'local_reminders';
  BaseClient baseClient = BaseClient();
  GetDailyReminders getDailyReminders = GetDailyReminders();
  List<ReminderData> allReminders = [];
  List<ReminderData> datewiseReminders = [];
  bool isLoading = false;

  List<ReminderData> _readLocalReminders() {
    final raw = box.read(_localRemindersKey);
    if (raw is! List) return [];

    final List<ReminderData> reminders = [];
    for (final item in raw) {
      if (item is Map) {
        try {
          reminders.add(ReminderData.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Skip invalid local entries.
        }
      }
    }
    return reminders;
  }

  Future<void> _writeLocalReminders(List<ReminderData> reminders) async {
    final payload = reminders.map((e) => e.toJson()).toList();
    await box.write(_localRemindersKey, payload);
  }

  List<ReminderData> _mergeServerAndLocal(List<ReminderData> serverReminders) {
    final localReminders = _readLocalReminders();
    return [...localReminders, ...serverReminders];
  }

  bool _matchesDate(ReminderData reminder, DateTime selectedDate) {
    final type = reminder.eventType ?? '';
    final eventAt = reminder.eventAt ?? [];
    final selectedDateStr = DateFormat('dd-MM-yyyy').format(selectedDate);

    if (type == 'Daily') {
      return true;
    }

    if (type == 'Weekly') {
      final dayName = DateFormat('EEEE').format(selectedDate);
      return eventAt.contains(dayName);
    }

    if (type == 'Date Range' && eventAt.length >= 2) {
      try {
        final from = DateFormat('dd-MM-yyyy').parseStrict(eventAt[0]);
        final to = DateFormat('dd-MM-yyyy').parseStrict(eventAt[1]);
        final selected = DateFormat('dd-MM-yyyy').parseStrict(selectedDateStr);
        return !selected.isBefore(from) && !selected.isAfter(to);
      } catch (_) {
        return false;
      }
    }

    return eventAt.contains(selectedDateStr);
  }

  Future<bool> saveReminderLocally({
    required String name,
    required String time,
    required String eventType,
    required List<String> eventAt,
    required bool snooze,
    required String interval,
    required String repeat,
  }) async {
    try {
      final localReminders = _readLocalReminders();
      final reminder = ReminderData(
        id: -DateTime.now().millisecondsSinceEpoch,
        profileId: 0,
        name: name,
        time: time,
        eventType: eventType,
        eventAt: eventAt,
        snooze: snooze ? 1 : 0,
        snoozeInterval: interval,
        snoozeRepeat: repeat,
        status: true,
        updatedAt: DateTime.now().toIso8601String(),
      );

      localReminders.insert(0, reminder);
      await _writeLocalReminders(localReminders);
      return true;
    } catch (e) {
      debugPrint('saveReminderLocally error: $e');
      return false;
    }
  }

  Future<void> getDailyReminder() async {
    isLoading = true;
    notifyListeners();

    List<ReminderData> serverReminders = [];
    try {
      final response =
          await baseClient.get('reminders', true, showSnackbar: false);
      final apiResponse = jsonEncode(response);
      final remindersResponse = getDailyRemindersFromJson(apiResponse);

      if (remindersResponse.success == true) {
        serverReminders = remindersResponse.data ?? [];
      }
    } catch (e) {
      debugPrint('getDailyReminder error: $e');
    } finally {
      allReminders = _mergeServerAndLocal(serverReminders);
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDateWiseReminder(DateTime selectedDate) async {
    isLoading = true;
    notifyListeners();

    List<ReminderData> serverReminders = [];
    try {
      final response = await baseClient.get(
        'reminders?date=${DateFormat('dd-MM-yyyy').format(selectedDate)}',
        true,
        showSnackbar: false,
      );
      final apiResponse = jsonEncode(response);
      final remindersResponse = getDailyRemindersFromJson(apiResponse);

      if (remindersResponse.success == true) {
        serverReminders = remindersResponse.data ?? [];
      }
    } catch (e) {
      debugPrint('getDateWiseReminder error: $e');
    } finally {
      final merged = _mergeServerAndLocal(serverReminders);
      datewiseReminders = merged
          .where((reminder) => _matchesDate(reminder, selectedDate))
          .toList();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> onSwitchPress(int id, bool status) async {
    if (id < 0) {
      try {
        final localReminders = _readLocalReminders();
        final index = localReminders.indexWhere((e) => e.id == id);
        if (index == -1) return false;
        localReminders[index].status = status;
        await _writeLocalReminders(localReminders);
        await getDailyReminder();
        return true;
      } catch (e) {
        debugPrint('onSwitchPress local error: $e');
        return false;
      }
    }

    try {
      final response = await baseClient.post(
          'reminders/status', {"id": "$id", "status": status}, true);

      if (response['success'] == true) {
        await getDailyReminder();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('onSwitchPress error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> onDeleteButtonPress(int id) async {
    if (id < 0) {
      try {
        final localReminders = _readLocalReminders();
        localReminders.removeWhere((e) => e.id == id);
        await _writeLocalReminders(localReminders);
        await getDailyReminder();
        return true;
      } catch (e) {
        debugPrint('onDeleteButtonPress local error: $e');
        return false;
      }
    }

    try {
      final response = await baseClient.get('reminders/delete/$id', true);
      if (response['success'] == true) {
        await getDailyReminder();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('onDeleteButtonPress error: $e');
      notifyListeners();
      return false;
    }
  }
}
