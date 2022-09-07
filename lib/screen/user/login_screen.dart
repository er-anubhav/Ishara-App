import 'package:docuhealth/contstants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'login_screen_1.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController controller = PageController();
  int currentPage = 0;

  List<Widget> buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < 2; i++) {
      list.add(i == currentPage ? indicator(true) : indicator(false));
    }
    return list;
  }

  Widget indicator(bool isActive) {
    return SizedBox(
      height: 10,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 10 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: const Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : const BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? const Color(0XFF6BC4C9) : const Color(0XFFEAEAEA),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 471.h,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  SizedBox(
                    width: 375.w,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.w, vertical: 20.h),
                      child: Text(
                        "docuhealth",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 25.sp,
                          color: AppColors.whiteTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      onPageChanged: (int page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      controller: controller,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(40.r),
                          child: Image.asset(
                            "assets/images/login-image.png",
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(40.r),
                          child: Image.asset(
                            "assets/images/login-image.png",
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(40.r),
                          child: Image.asset(
                            "assets/images/login-image.png",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.r),
                    child: Row(
                      children: buildPageIndicator(),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15.w, right: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 36.h,
                  ),
                  Text(
                    "Let’s get started! Enter your mobile number",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: InkWell(
                      onTap: () {
                        Get.to(const LoginScreenNext());
                      },
                      child: TextFormField(
                        enabled: false,
                        validator: (mynumber) {
                          if (mynumber!.isEmpty) {
                            return 'number is Required*';
                          } else if (mynumber.length != 10) {
                            return 'enter 10 number ';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(15.r),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.greyButtonColor,
                              width: 0.1.w,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          fillColor: AppColors.whitebgColor,
                          prefixIcon: Container(
                            width: 50.w,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.whitebgColor,
                              border: Border(
                                right: BorderSide(
                                    width: 0.5.w,
                                    color: AppColors.greyButtonColor),
                              ),
                            ),
                            child: const Center(child: Text('+91')),
                          ),
                          labelText: 'Phone Number',
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 10.h,
                  // ),
                  // Text(
                  //   "Trouble signing in ?",
                  //   style: TextStyle(
                  //     fontSize: 16.sp,
                  //     fontWeight: FontWeight.w400,
                  //     decoration: TextDecoration.underline,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
