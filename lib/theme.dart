import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'contstants/app_colors.dart';

class AppTheme {
  static InputDecoration defaultInputFieldDecoration(hintText, icon) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.whitebgColor,
      contentPadding: EdgeInsets.all(15.r),
      prefixIcon: Container(
        width: 50.w,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.whitebgColor,
          border: Border(
            right: BorderSide(width: 0.5.w, color: AppColors.greyButtonColor),
          ),
        ),
        child: Icon(icon),
      ),
      hintStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.greyTextColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }

  static InputDecoration defaultDescriptionInputFieldDecoration(
      hintText, icon) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.whitebgColor,
      contentPadding: EdgeInsets.all(20.r),
      counterText: "",
      hintStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.greyTextColor,
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.lightGreyTextColor)),
    );
  }
}
