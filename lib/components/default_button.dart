import 'package:docuhealth/contstants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPress;
  const DefaultButton(
      {Key? key, required this.buttonText, required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 30.w),
      child: ButtonTheme(
        height: 50.h,
        child: TextButton(
          onPressed: onPress,
          child: Center(
              child: Text(
            buttonText,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
          )),
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
              color: Colors.green.shade200,
              offset: const Offset(1, -2),
              blurRadius: 5.r),
          BoxShadow(
              color: Colors.green.shade200,
              offset: const Offset(-1, 2),
              blurRadius: 5)
        ],
      ),
    );
  }
}
