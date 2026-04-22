import 'dart:async';
import 'package:docuhealth/components/default_button.dart';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:docuhealth/screen/home_screen.dart';
import 'package:docuhealth/screen/user/select_user_scrren.dart';
import 'package:docuhealth/screen/user/user_registration.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import '../../contstants/app_colors.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String mobileNUmber;
  const VerifyOtpScreen({super.key, required this.mobileNUmber});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  TextEditingController textEditingController = TextEditingController();
  OtpTimerButtonController otpController = OtpTimerButtonController();
  StreamController<ErrorAnimationType>? errorController;
  BaseClient baseClient = BaseClient();
  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  Future<bool> onResendOtpPress() async {
    var data = {"phone": widget.mobileNUmber};

    final response = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(
          baseClient.post('login', data, false),
          message: const Text('Loading...')),
    );
    if (response['success']) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  // snackBar Widget
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.greyButtonColor,
        ),
        backgroundColor: AppColors.whitebgColor,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          children: [
            SizedBox(
              height: 20.h,
            ),
            SizedBox(
              width: 320.w,
              child: Text(
                "Enter the 6-digit OTP sent to",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 320.w,
              child: Text(
                "+91 ${widget.mobileNUmber}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Form(
              key: formKey,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme.defaults(
                      fieldHeight: 60.h,
                      fieldWidth: 40.w,
                      inactiveColor: Colors.grey,
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    cursorColor: AppColors.primaryColor,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: false,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    onCompleted: (v) {
                      debugPrint("Completed");
                    },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      return true;
                    },
                  )),
            ),
            SizedBox(
              width: 320.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.greyTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      OtpTimerButton(
                        controller: otpController,
                        buttonType: ButtonType.text_button,
                        backgroundColor: AppColors.primarybgColor,
                        textColor: AppColors.primaryColor,
                        loadingIndicator: const CircularProgressIndicator(),
                        onPressed: () async {
                          final resp = await onResendOtpPress();
                          if (resp) {
                            otpController.startTimer();
                          }
                        },
                        text: Text(
                          "RESEND",
                          style: TextStyle(
                            color: const Color(0xFF91D3B3),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        duration: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 169.h,
            ),
            DefaultButton(
              buttonText: "Continue",
              onPress: () async {
                formKey.currentState!.validate();
                if (currentText.length != 6 || currentText != "123456") {
                  errorController!.add(ErrorAnimationType.shake);
                  setState(
                    () => hasError = true,
                  );
                } else {
                  var data = {"phone": widget.mobileNUmber, "otp": currentText};

                  final response = await showDialog(
                    context: context,
                    builder: (context) => FutureProgressDialog(
                        baseClient.post('verify/otp', data, false),
                        message: const Text('Loading...')),
                  );

                  debugPrint('OTP verify response: $response');
                  if (response['success']) {
                    final userData =
                        (response['data'] is List && response['data'].isNotEmpty)
                            ? Map<String, dynamic>.from(response['data'][0])
                            : <String, dynamic>{};
                    final action = (response['action'] ?? '').toString();
                    final hasProfileContext =
                        action != 'go_to_register' && action != 'go_to_profiles';

                    setState(
                      () {
                        hasError = false;
                        snackBar("OTP Verified!");
                        GetStorageHelper.setdata(
                          (userData['id'] ?? '').toString(),
                          (userData['name'] ?? '').toString(),
                          (userData['phone'] ?? '').toString(),
                          (userData['email'] ?? '').toString(),
                          '',
                          (response['token'] ?? '').toString(),
                          hasProfileContext: hasProfileContext,
                        );
                      },
                    );
                    if (action == 'go_to_register') {
                      Get.off(const UserRegistrationScreen());
                    } else if (action == 'go_to_profiles') {
                      Get.off(const SelectUserScreen());
                    } else {
                      Get.off(const HomePage(
                        currentIndex: 0,
                      ));
                    }
                  } else {
                    snackBar(response['message']);
                  }
                }
              },
            ),
          ],
        )),
      ),
    );
  }
}
