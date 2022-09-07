import 'package:flutter/material.dart';

class AppColors {
  static Color primaryColor = const Color(0xff01C273);
  static Color selectedIconColor = const Color(0xff247432);
  static Color whitebgColor = Colors.white;
  static Color primarybgColor = Colors.grey.shade100;
  static Color greyButtonColor = const Color(0xff979797);
  static Color whiteTextColor = Colors.white;
  static Color lightGreyTextColor = Colors.grey.shade400;
  static Color greyTextColor = Colors.grey.shade600;
  static Color darkGreyTextColor = Colors.grey.shade800;
  static Gradient primaryLinearGradient = const LinearGradient(
    colors: [
      Color(0xffE7FFF2),
      Color(0xffCAFFEA),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
