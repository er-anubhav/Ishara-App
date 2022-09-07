import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import '../../components/default_button.dart';
import '../../contstants/app_colors.dart';
import '../../theme.dart';

class AddNewFamilyMember extends StatefulWidget {
  const AddNewFamilyMember({Key? key}) : super(key: key);

  @override
  State<AddNewFamilyMember> createState() => _AddNewFamilyMemberState();
}

class _AddNewFamilyMemberState extends State<AddNewFamilyMember> {
  final formkey = GlobalKey<FormState>();
  BaseClient baseClient = BaseClient();
  TextEditingController nameController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  String? dropdownvalue;
  var items = [
    'Brother',
    'Daughter',
    'Father',
    'Friend',
    'Grand Father',
    'Grand Mother',
    'Husband',
    'Mother',
    'Sister',
    'Son',
    'Wife',
  ];

  Future<bool> onRegisterPress(context) async {
    var data = {
      "name": nameController.text,
      "relation": relationController.text
    };
    final response = await baseClient.post('profile/create', data, true);
    if (response['success']) {
      return true;
    } else {
      return false;
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
        title: Text(
          "Add a new family member",
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.darkGreyTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.whitebgColor,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
          key: formkey,
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
                      "Name",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: AppTheme.defaultInputFieldDecoration(
                        "Enter full name",
                        Icons.person,
                      ),
                      validator: (v) {
                        if (v!.isEmpty) {
                          return "Name is required";
                        }
                      },
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      "Relation",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    DropdownButtonFormField(
                      decoration: AppTheme.defaultInputFieldDecoration(
                        "Select relation",
                        Icons.group,
                      ),
                      value: dropdownvalue,
                      validator: (v) {
                        if (relationController.text.isEmpty) {
                          return "Relation is required";
                        }
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                          relationController.text = dropdownvalue!;
                        });
                      },
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              DefaultButton(
                buttonText: "Register",
                onPress: () async {
                  if (formkey.currentState!.validate()) {
                    final resp = await showDialog(
                      context: context,
                      builder: (context) => FutureProgressDialog(
                        onRegisterPress(context),
                        message: const Text('Saving profile please wait...'),
                      ),
                    );
                    print(resp);
                    if (resp) {
                      Get.back();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Someting went wrong!"),
                          duration: Duration(seconds: 3),
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
