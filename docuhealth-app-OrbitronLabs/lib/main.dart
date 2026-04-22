import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_storage/get_storage.dart';
import 'my_app.dart';
import 'services/awsome_notifications.dart';

List<CameraDescription> cameras = [];
dynamic deviceToken;
bool firebaseAvailable = false;

const bool verboseLogs =
    bool.fromEnvironment('VERBOSE_LOGS', defaultValue: false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!verboseLogs) {
    // Silence verbose debug logs unless explicitly enabled with
    // --dart-define=VERBOSE_LOGS=true.
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  await GetStorage.init();
  GetStorageHelper.setinitialdata();
  await FlutterDownloader.initialize(debug: false);
  try {
    await Firebase.initializeApp();
    firebaseAvailable = true;
    deviceToken = await FirebaseMessaging.instance.getToken(
      vapidKey:
          "AAAArUCPiK8:APA91bF2XNI56bVuKLAozsc9hHCXk4jTLQAiGVlqm1V36BYsicSJ2uFyIYUQU2VxgU5wBThDuNXTZFeA0GV_rQtqjzJusou3XbAL-PfB-E7w4m2Z2ofyTUlnP4XrKr7ZJ9u7xmpzdEqF",
    );
  } catch (e, st) {
    deviceToken = null;
    debugPrint('Firebase initialization skipped: $e');
    debugPrintStack(stackTrace: st);
  }
  LocalNotificationService.initialize;
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error in fetching the cameras: $e');
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: AppColors.whitebgColor,
    systemNavigationBarColor: Colors.black,
    statusBarIconBrightness: Brightness.dark,
  ));
  await AwesomeNotifications().initialize(
    'resource://drawable/ic_launcher',
    [
      NotificationChannel(
        channelGroupKey: 'testChannel',
        channelKey: 'alarm1',
        channelName: 'Notification',
        channelDescription: 'The Test Notifications',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        playSound: true,
        soundSource: 'resource://raw/alarm2',
        defaultRingtoneType: DefaultRingtoneType.Notification,
        enableLights: true,
        channelShowBadge: true,
        criticalAlerts: true,
        importance: NotificationImportance.Max,
        enableVibration: true,
      ),
      NotificationChannel(
        channelGroupKey: 'testChannel',
        channelKey: 'alarm2',
        channelName: 'Reminders',
        channelDescription: 'The Test Reminders',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        playSound: true,
        soundSource: 'resource://raw/remindertune',
        defaultRingtoneType: DefaultRingtoneType.Alarm,
        enableLights: true,
        channelShowBadge: true,
        criticalAlerts: true,
        importance: NotificationImportance.Max,
        enableVibration: true,
      ),
    ],
  );
  runApp(const MyApp());
}
