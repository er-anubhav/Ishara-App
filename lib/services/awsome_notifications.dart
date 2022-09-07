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
    print("A Big  message just Shown : ${message.messageId}");

    print(message.notification);
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
        .then((value) => print("setForegroundNotificationPresentationOptions"));
    return FirebaseMessaging.instance.getInitialMessage().then((message) {
      print("FirebaseMessaging.instance.getInitialMessage");
      if (message != null) {
        // var data = jsonDecode(message.notification?.body ?? '');
        // print(data);
        print(message.notification);
        showImageNotification(
            title: message.notification?.title,
            body: message.notification?.body,
            imageUrl: message.data['image_url'],
            sound: message.data["redirect_to"] == "reminders",
            actionButton: message.data["redirect_to"] == "reminders");
        print("New Notification");
        // String? redirectTo = message.data["redirect_to"] ?? "reminders";
        // redirectToScreen(redirectTo: redirectTo, context: context);
      }
    });
  }

  static Future onMessageOpenedApp({required BuildContext context}) async {
    return FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          String? redirectTo = message.data["redirect_to"] ?? "notifications";
          redirectToScreen(redirectTo: redirectTo, context: context);
        }
      },
    );
  }

  onMessage({required BuildContext context}) async {
    FirebaseMessaging.onMessage.listen(
      (message) async {
        print("FirebaseMessaging.onMessage.listen");
        print(message.notification);
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

          print(message.notification?.body);
          print(message.notification);
          print(message.data['redirect_to']);
          AwesomeNotifications().actionStream.listen((action) {
            if (action.buttonKeyPressed == "ACCEPT") {
              // apiCall(message);
              // reminderController.notificationSendStatus(
              //     id: message.data['target_id'], status: 'Accepted');
              print("Open button is pressed");
            } else if (action.buttonKeyPressed == "SNOOZE") {
              // reminderController.notificationSendStatus(
              //     id: message.data['target_id'], status: 'Ignored');

              print("Delete button is pressed.");
            }
          });
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
            buttonType: ActionButtonType.Default,
            key: 'test',
          ),
          NotificationActionButton(
            label: 'Cancel',
            enabled: true,
            buttonType: ActionButtonType.Default,
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
                  buttonType: ActionButtonType.Default,
                  key: 'ACCEPT',
                ),
                NotificationActionButton(
                  label: 'SNOOZE',
                  enabled: true,
                  buttonType: ActionButtonType.Default,
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
        .then((value) => print("setForegroundNotificationPresentationOptions"));

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
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  static Future redirectToScreen(
      {required String? redirectTo, required BuildContext context}) async {
    print("On Notification Click");
    print(redirectTo);
    if (redirectTo == "vouchers") {
      print("Redirecting to $redirectTo");
      Navigator.pushNamed(context, "/vouchers");
    } else if (redirectTo.toString() == "transactions") {
      print("Redirecting to $redirectTo");
      Navigator.pushNamed(context, "/transactions");
    } else if (redirectTo.toString() == "bookings") {
      print("Redirecting to $redirectTo");
      Navigator.pushNamed(context, "/bookings");
    } else if (redirectTo == "notifications") {
      print("Redirecting to $redirectTo");
      Navigator.pushNamed(context, "/notifications");
    }
  }
}
