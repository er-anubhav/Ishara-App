import 'dart:async';
import 'package:docuhealth/screen/home_screen.dart';
import 'package:docuhealth/screen/user/select_user_scrren.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../helper/get_storage_helper.dart';
import 'user/login_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    Timer(
      const Duration(seconds: 2),
      () {
        final isLoggedIn = box.read('is_logged_in') == true ||
            box.read('is_logged_in').toString() == 'true';
        final hasProfileContext = box.read('has_profile_context') == true ||
            box.read('has_profile_context').toString() == 'true';

        if (isLoggedIn) {
          Get.off(hasProfileContext
              ? const HomePage(
                  currentIndex: 0,
                )
              : const SelectUserScreen());
        } else {
          Get.off(const LoginScreen());
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: 110.h,
            height: 139.3333282470703.w,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
