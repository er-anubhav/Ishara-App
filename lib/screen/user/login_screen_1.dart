import 'package:docuhealth/screen/cms_screen.dart';
import 'package:docuhealth/screen/login/verify_otp_screen.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import '../../components/default_button.dart';
import '../../contstants/app_colors.dart';

class LoginScreenNext extends StatefulWidget {
  const LoginScreenNext({Key? key}) : super(key: key);

  @override
  State<LoginScreenNext> createState() => _LoginScreenNextState();
}

class _LoginScreenNextState extends State<LoginScreenNext> {
  TextEditingController phoneNUmberCOntroller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  BaseClient baseClient = BaseClient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitebgColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.greyButtonColor,
        ),
        backgroundColor: AppColors.whitebgColor,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      "Enter your Mobile number",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      child: TextFormField(
                        autofocus: true,
                        controller: phoneNUmberCOntroller,
                        validator: (mynumber) {
                          if (mynumber!.isEmpty) {
                            return 'Phone number is Required*';
                          } else if (mynumber.length != 10) {
                            return 'Please enter 10 digit mobile number ';
                          }
                          return null;
                        },
                        maxLength: 10,
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
                          counterText: "",
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
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      "By continuing, you agree to our",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.greyButtonColor,
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    InkWell(
                      onTap: () => Get.to(const CmsScreen(
                        url: "cms/terms-and-conditions",
                        appBarTitle: "Terms & Conditions",
                      )),
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.greyTextColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190.h,
              ),
              DefaultButton(
                buttonText: "Continue",
                onPress: () async {
                  if (formKey.currentState!.validate()) {
                    var data = {"phone": phoneNUmberCOntroller.text};

                    final response = await showDialog(
                      context: context,
                      builder: (context) => FutureProgressDialog(
                          baseClient.post('login', data, false),
                          message: const Text('Loading...')),
                    );

                    if (response['success']) {
                      Get.off(
                        VerifyOtpScreen(
                          mobileNUmber: phoneNUmberCOntroller.text,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      )),
    );
  }
}
