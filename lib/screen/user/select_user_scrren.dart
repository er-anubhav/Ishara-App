import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:docuhealth/main.dart';
import 'package:docuhealth/screen/home_screen.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';

import 'add_more_family_member.dart';

class SelectUserScreen extends StatefulWidget {
  const SelectUserScreen({Key? key}) : super(key: key);

  @override
  State<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  BaseClient baseClient = BaseClient();
  List profiles = [];
  getUserProfile(context) async {
    final response = await baseClient.get('profiles', true);
    print(response);
    profiles = response['data']['profiles'];
    setState(() {});
  }

  onProfileTap(profileId) async {
    var data = {"profile_id": "$profileId", "device_token": deviceToken};
    final response = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(
          baseClient.post('profile-login', data, true),
          message: const Text('Switching profile...')),
    );

    print(response);

    if (response['success']) {
      GetStorageHelper.setdata(
        response['data']['id'],
        response['data']['name'],
        response['data']['phone'],
        response['data']['email'],
        '',
        response['token'],
      );
      Get.to(const HomePage(
        currentIndex: 0,
      ));
    }
  }

  @override
  void initState() {
    getUserProfile(context);
    super.initState();
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
          "Want to Add your family member",
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.darkGreyTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.whitebgColor,
      ),
      body: SafeArea(
          child: GridView.builder(
        padding: EdgeInsets.only(top: 10.h, left: 10.w, right: 10.w),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          childAspectRatio: 3 / 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 150,
        ),
        itemCount: profiles.length + 1,
        itemBuilder: (BuildContext context, int index) {
          return index == profiles.length
              ? InkWell(
                  onTap: (() {
                    Get.to(
                      const AddNewFamilyMember(),
                    )!
                        .whenComplete(() => getUserProfile(context));
                  }),
                  child: Column(
                    children: [
                      Container(
                        height: 95.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add_circle,
                            size: 40.r,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        "Add profile",
                        style: TextStyle(
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: () {
                    onProfileTap(profiles[index]['id']);
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 95.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(10.r)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            profiles[index]['icon'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        '${profiles[index]['name']} (${profiles[index]['type']})',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                );
        },
      )),
    );
  }
}
