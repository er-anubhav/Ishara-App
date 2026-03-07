import 'package:docuhealth/main.dart';
import 'package:docuhealth/screen/user/select_user_scrren.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:docuhealth/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import '../../components/default_button.dart';
import '../../contstants/app_colors.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();
  BaseClient baseClient = BaseClient();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> onCOntinuePress() async {
    if (_formKey.currentState!.validate()) {
      if (isChecked) {
        var data = {
          "name": nameController.text,
          "email": emailController.text,
          "device_token": deviceToken
        };

        final response = await showDialog(
          context: context,
          builder: (context) => FutureProgressDialog(
              baseClient.post('register', data, true),
              message: const Text('Loading...')),
        );

        if (response['success']) {
          Get.snackbar(
            'Success',
            response['message'],
          );
          Get.off(const SelectUserScreen());
        } else {
          Get.snackbar(
            'Failed',
            response['message'],
          );
        }
      } else {
        Get.snackbar(
          'Failed',
          "Please accept terms and conditions",
        );
      }
    }
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
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      "Hi",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 28.h,
                    ),
                    Text(
                      "What’s your name?",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 18.h,
                    ),
                    TextFormField(
                        controller: nameController,
                        validator: (v) {
                          if (v!.isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[ a-zA-Z]")),
                        ],
                        decoration: AppTheme.defaultInputFieldDecoration(
                          "Enter your name",
                          Icons.person,
                        )),
                    SizedBox(
                      height: 24.h,
                    ),
                    Text(
                      "What’s your email id?",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    TextFormField(
                      controller: emailController,
                      validator: (v) {
                        if (v!.isEmpty) {
                          return "Email is required";
                        }
                        return null;
                      },
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.allow(RegExp(
                      //       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")),
                      // ],
                      decoration: AppTheme.defaultInputFieldDecoration(
                        "Enter your email",
                        Icons.email,
                      ),
                    ),
                    SizedBox(
                      height: 68.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (v) {
                            setState(() {
                              isChecked = v!;
                            });
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "By continuing, you agree to our",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.greyButtonColor,
                              ),
                            ),
                            Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.greyButtonColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24.h,
              ),
              DefaultButton(
                buttonText: "Continue",
                onPress: onCOntinuePress,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
