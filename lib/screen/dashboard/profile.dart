import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/main.dart';
import 'package:docuhealth/screen/cms_screen.dart';
import 'package:docuhealth/screen/user/add_more_family_member.dart';
import 'package:docuhealth/screen/user/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import '../../helper/get_storage_helper.dart';
import '../../services/base_client.dart';
import '../home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  BaseClient baseClient = BaseClient();
  List profiles = [];

  getUserProfile(context) async {
    final response = await baseClient.get('profiles', true);
    profiles = response['data']['profiles'];
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> onProfileTap(profileId) async {
    var data = {"profile_id": "$profileId", "device_token": deviceToken};
    final response = await baseClient.post('profile-login', data, true);

    if (response['success']) {
      box.write('id', response['data']['id']);
      box.write('username', response['data']['name']);
      box.write('mobileno', response['data']['phone']);
      box.write('email', response['data']['email']);
      box.write('imagePath', response['data']['icon']);
      box.write('access_token', response['token']);
      getUserProfile(context);
      Get.snackbar("Success", response['message']);
      return true;
    } else {
      Get.snackbar("Failed", response['message']);
      return false;
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
      backgroundColor: AppColors.primarybgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.h,
            ),
            Container(
              height: 110.h,
              padding: EdgeInsets.only(left: 10.w),
              child: ListView.builder(
                itemCount: profiles.length + 1,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  int newIndex = profiles.length;
                  return i == newIndex
                      ? InkWell(
                          onTap: () async {
                            Get.to(const AddNewFamilyMember())!.whenComplete(
                              () => getUserProfile(context),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            padding: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(
                              color: AppColors.whitebgColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 25.r,
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 30.r,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                SizedBox(
                                  width: 70.w,
                                  child: Text(
                                    'Add profile',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.darkGreyTextColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () async {
                            final response = await showDialog(
                              context: context,
                              builder: (context) => FutureProgressDialog(
                                onProfileTap(profiles[i]['id']),
                                message: const Text(
                                  'Switching profile...',
                                ),
                              ),
                            );
                            if (response) {
                              Get.off(const HomePage(
                                currentIndex: 0,
                              ));
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            padding: profiles[i]['active']
                                ? EdgeInsets.all(15.r)
                                : EdgeInsets.all(5.r),
                            decoration: profiles[i]['active']
                                ? BoxDecoration(
                                    color: AppColors.whitebgColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: AppColors.primaryColor,
                                      width: 3,
                                    ),
                                  )
                                : BoxDecoration(
                                    color: AppColors.whitebgColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 25.r,
                                  backgroundImage:
                                      NetworkImage(profiles[i]['icon']),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                SizedBox(
                                  width: 70.w,
                                  child: Text(
                                    '${profiles[i]['name']} (${profiles[i]['type']})',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.darkGreyTextColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                },
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              margin: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.h),
              decoration: BoxDecoration(
                  color: AppColors.whitebgColor,
                  borderRadius: BorderRadius.circular(10.r)),
              child: Column(
                children: [
                  ListTile(
                    onTap: (() {
                      Get.to(const MyProfileEdit());
                    }),
                    leading: CircleAvatar(
                      radius: 20,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    title: Text(
                      "My Account",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                    subtitle: Text(
                      "Make changes to your account",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreyTextColor,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.to(
                        const CmsScreen(
                          url: 'cms/contact-us',
                          appBarTitle: 'Contact Us',
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 20,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      ),
                      backgroundColor: Colors.grey.shade100,
                    ),
                    title: Text(
                      "Contact Us",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                    subtitle: Text(
                      "Manage your saved account",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreyTextColor,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.to(
                        const CmsScreen(
                          url: 'cms/terms-and-conditions',
                          appBarTitle: 'Term of uses',
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 20,
                      child: Icon(
                        Icons.lock_person,
                        color: AppColors.primaryColor,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    title: Text(
                      "Term of uses",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                    subtitle: Text(
                      "Manage your device security",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreyTextColor,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.to(const CmsScreen(
                          url: 'cms/privacy-policy',
                          appBarTitle: 'Privacy policy'));
                    },
                    leading: CircleAvatar(
                      radius: 20,
                      child: Icon(
                        Icons.privacy_tip,
                        color: AppColors.primaryColor,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    title: Text(
                      "Privacy policy",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                    subtitle: Text(
                      "Further secure your account for seafty",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreyTextColor,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.defaultDialog(
                        title: "Warning !",
                        middleText:
                            "Are you sure you want to logout your account",
                        confirm: SizedBox(
                          height: 35.h,
                          width: Get.width / 3,
                          child: ElevatedButton(
                            onPressed: () {
                              box.erase();
                              GetStorageHelper.setinitialdata();
                              box.write('is_logged_in', false);
                              Get.offNamedUntil('/Splash', (route) => false);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: AppColors.primaryColor,
                            ),
                            child: const Text('Continue'),
                          ),
                        ),
                        cancel: SizedBox(
                          height: 35.h,
                          width: Get.width / 3,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey.shade400,
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        radius: 10,
                      );
                    },
                    leading: CircleAvatar(
                      radius: 20,
                      child: Icon(
                        Icons.logout,
                        color: AppColors.primaryColor,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    title: Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                    subtitle: Text(
                      "Further secure your account for seafty",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreyTextColor,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.w, bottom: 5.h),
              child: Text(
                "More",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreyTextColor,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                  color: AppColors.whitebgColor,
                  borderRadius: BorderRadius.circular(10.r)),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Get.to(const CmsScreen(
                          url: 'cms/about', appBarTitle: 'About App'));
                    },
                    leading: CircleAvatar(
                      radius: 20,
                      child: Icon(
                        Icons.message,
                        color: AppColors.primaryColor,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    title: Text(
                      "FAQ's",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.to(const CmsScreen(
                          url: 'cms/about', appBarTitle: 'About App'));
                    },
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade100,
                      child: Icon(
                        Icons.info,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    title: Text(
                      "About App",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
