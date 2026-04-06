import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reminder_app/controller/reminder_controller.dart';

class LocalNotificationService {
  // ReminderController reminderController = Get.put(ReminderController());
  static Future onBackgroundMessage({required BuildContext context}) async {
    FirebaseMessaging.onBackgroundMessage(firebaseBGHandler);
  }

  static Future firebaseBGHandler(RemoteMessage message) async {
    debugPrint("A Big  message just Shown : ${message.messageId}");

    debugPrint(message.notification.toString());
    // var data = jsonDecode(message.notification?.body ?? '');
    // print(data);
    // showImageNotification(
    //     title: message.notification?.title,
    //     body: message.notification?.body,
    //     imageUrl: data['image']);
    await AwesomeNotifications().createNotificationFromJsonData(message.data);
  }

  static Future getInitialMessage({required BuildContext context}) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        )
        .then((value) => debugPrint("setForegroundNotificationPresentationOptions"));
    return FirebaseMessaging.instance.getInitialMessage().then((message) {
      debugPrint("FirebaseMessaging.instance.getInitialMessage");
      if (message != null) {
        // var data = jsonDecode(message.notification?.body ?? '');
        // print(data);
        debugPrint(message.notification.toString());
        showImageNotification(
            title: message.notification?.title,
            body: message.notification?.body,
            imageUrl: message.data['image_url'],
            sound: message.data["redirect_to"] == "reminders",
            actionButton: message.data["redirect_to"] == "reminders");
        debugPrint("New Notification");
        // String? redirectTo = message.data["redirect_to"] ?? "reminders";
        // redirectToScreen(redirectTo: redirectTo, context: context);
      }
    });
  }

  static Future onMessageOpenedApp({required BuildContext context}) async {
    return FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        debugPrint("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          String? redirectTo = message.data["redirect_to"] ?? "notifications";
          // ignore: use_build_context_synchronously
          if (!context.mounted) return;
          // ignore: use_build_context_synchronously
          redirectToScreen(redirectTo: redirectTo, context: context);
        }
      },
    );
  }

  Future<void> onMessage({required BuildContext context}) async {
    FirebaseMessaging.onMessage.listen(
      (message) async {
        debugPrint("FirebaseMessaging.onMessage.listen");
        debugPrint(message.notification.toString());
        if (message.notification != null) {
          // showNotification(
          //   title: message.notification!.title,
          //   body: message.notification!.body,
          //   payload: {
          //     "target_id": message.data["target_id"] ?? "0",
          //     "redirect_to": message.data["redirect_to"] ?? "notifications",
          //   },
          // );
          // var data = jsonDecode(message.notification?.body ?? '');
          // print(data);
          showImageNotification(
              title: message.notification?.title,
              body: message.notification?.body,
              imageUrl: message.data['image_url'],
              sound: message.data["redirect_to"] == "reminders",
              actionButton:
                  message.data["redirect_to"] == "reminders" ? true : false);

          debugPrint(message.notification?.body);
          debugPrint(message.notification.toString());
          debugPrint(message.data['redirect_to']);
          // Note: Action button handling should be set up once during app initialization
          // using AwesomeNotifications().setListeners() with onActionReceivedMethod callback
          // rather than subscribing to streams for each notification
          // String? redirectTo = message.data["redirect_to"] ?? "reminders";
          // AwesomeNotifications()
          //     .actionStream
          //     .listen((ReceivedNotification receivedNotification) {
          //   redirectToScreen(redirectTo: redirectTo, context: context);
          // });
        }
      },
    );
  }

  // apiCall(message) {
  //   reminderController.notificationSendStatus(
  //       id: message.data['target_id'], status: 'Accepted');
  // }

  static Future showNotification({
    required String? title,
    required String? body,
    String? imageUrl,
    Map<String, String>? payload,
  }) async {
    return await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: Random().nextInt(100000),
            channelKey: 'testChannel',
            title: title,
            body: body,
            payload: payload,
            displayOnBackground: true,
            displayOnForeground: true,
            bigPicture: imageUrl),
        actionButtons: [
          NotificationActionButton(
            label: 'TEST',
            enabled: true,
            actionType: ActionType.Default,
            key: 'test',
          ),
          NotificationActionButton(
            label: 'Cancel',
            enabled: true,
            actionType: ActionType.Default,
            key: 'test',
          ),
        ]);
  }

  static Future showImageNotification({
    required String? title,
    required String? body,
    bool? actionButton,
    bool? sound,
    String? imageUrl,
    Map<String, String>? payload,
  }) async {
    return await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(100000),
          channelKey: 'testChannel',
          title: title,
          body: body,
          customSound: sound == true
              ? 'resource://raw/notification'
              : 'resource://raw/alarm',
          payload: payload,
          displayOnBackground: true,
          displayOnForeground: true,
          bigPicture: imageUrl,
          criticalAlert: true,
          fullScreenIntent: true,
          notificationLayout: NotificationLayout.BigPicture,
        ),
        actionButtons: actionButton == true
            ? [
                NotificationActionButton(
                  label: 'ACCEPT',
                  enabled: true,
                  actionType: ActionType.Default,
                  key: 'ACCEPT',
                ),
                NotificationActionButton(
                  label: 'SNOOZE',
                  enabled: true,
                  actionType: ActionType.Default,
                  key: 'SNOOZE',
                ),
              ]
            : []);
  }

  static Future initialize(BuildContext context) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        )
        .then((value) => debugPrint("setForegroundNotificationPresentationOptions"));

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  static Future redirectToScreen(
      {required String? redirectTo, required BuildContext context}) async {
    debugPrint("On Notification Click");
    debugPrint(redirectTo);
    if (redirectTo == "vouchers") {
      debugPrint("Redirecting to $redirectTo");
      Navigator.pushNamed(context, "/vouchers");
    } else if (redirectTo.toString() == "transactions") {
      debugPrint("Redirecting to $redirectTo");
      Navigator.pushNamed(context, "/transactions");
    } else if (redirectTo.toString() == "bookings") {
      debugPrint("Redirecting to $redirectTo");
      Navigator.pushNamed(context, "/bookings");
    } else if (redirectTo == "notifications") {
      debugPrint("Redirecting to $redirectTo");
      Navigator.pushNamed(context, "/notifications");
    }
  }
}
