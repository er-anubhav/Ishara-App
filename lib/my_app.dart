import 'package:docuhealth/controllers/image_edit_controller.dart';
import 'package:docuhealth/screen/document_category/bookmarks_screen.dart';
import 'package:docuhealth/screen/document_category/daily_measurements.dart';
import 'package:docuhealth/screen/document_category/daily_remainder.dart';
import 'package:docuhealth/screen/document_category/my_documents.dart';
import 'package:docuhealth/screen/document_category/shared_documents.dart';
import 'package:docuhealth/screen/home_screen.dart';
import 'package:docuhealth/screen/splash.dart';
import 'package:docuhealth/screen/device_connection_screen.dart';
import 'package:flutter/material.dart';
import 'package:docuhealth/controllers/dashboard_controllers.dart';
import 'package:docuhealth/controllers/document_controller.dart';
import 'package:provider/provider.dart';
import 'controllers/daily_measurement_controller.dart';
import 'controllers/daily_reminder_controller.dart';
import 'services/ble_service.dart';
import 'contstants/app_colors.dart';
import 'screen/document_category/test_reports.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (create) => DocumentController()),
        ChangeNotifierProvider(create: (create) => DashBoardController()),
        ChangeNotifierProvider(
            create: (create) => DailyMeasurementController()),
        ChangeNotifierProvider(create: (create) => DailyReminderController()),
        ChangeNotifierProvider(create: (create) => ImageEditController()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return Listener(
            onPointerDown: (_) => BleService().resetIdleTimer(),
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Docuhealth',
              theme: ThemeData(primaryColor: AppColors.primaryColor),
              home: const Splash(),
              routes: {
                '/Splash': (BuildContext context) => const Splash(),
                '/Dashboard': (BuildContext context) =>
                    const HomePage(currentIndex: 1),
                '/Doctor_Prescription': (BuildContext context) =>
                    const TestReports(
                      operationType: '',
                      appBarTitle: "Doctor Prescription",
                      categoryName: "DOCTOR_PRESCRIPTION",
                      documentType: '',
                      redirectTo: '/Doctor_Prescription',
                    ),
                '/Hospital_Management': (BuildContext context) =>
                    const TestReports(
                      operationType: '',
                      appBarTitle: "Hospital management",
                      categoryName: "HOSPITAL_BILLS",
                      documentType: '',
                      redirectTo: '/Hospital_Management',
                    ),
                '/Pharmacy_Record': (BuildContext context) => const TestReports(
                      operationType: '',
                      appBarTitle: "Pharmacy Record",
                      categoryName: "PHARMACY_RECORDS",
                      documentType: '',
                      redirectTo: '/Pharmacy_Record',
                    ),
                '/Genral_Documents': (BuildContext context) => const TestReports(
                      operationType: '',
                      appBarTitle: "General Documents",
                      categoryName: "GENERAL_DOCS",
                      documentType: '',
                      redirectTo: '/Genral_Documents',
                    ),
                '/Test_Reports': (BuildContext context) => const TestReports(
                      operationType: '',
                      appBarTitle: "Test Reports",
                      categoryName: "TEST_REPORTS",
                      documentType: '',
                      redirectTo: '/Test_Reports',
                    ),
                '/My_Documents': (BuildContext context) => const MyDocumnets(
                      operationType: '',
                      documentType: '',
                    ),
                '/daily_Measurements': (BuildContext context) =>
                    const DailyMeasurements(title: "Daily Measurements"),
                '/Book_Marks': (BuildContext context) => const BookMarksScreen(
                      operationType: '',
                      appBarTitle: "Bookmarks",
                      categoryName: "TEST_REPORTS",
                      documentType: '',
                    ),
                '/Shared_Documents': (BuildContext context) =>
                    const SharedDocuments(title: "Shared Documents"),
                '/daily_remainder': (BuildContext context) =>
                    const DailyReminder(title: "Daily Remainder"),
                  '/Device_Connections': (BuildContext context) =>
                    DeviceConnectionScreen(),
              },
            ),
          );
        },
      ),
    );
  }
}
