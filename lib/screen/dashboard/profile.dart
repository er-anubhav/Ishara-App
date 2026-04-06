import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/main.dart';
import 'package:docuhealth/screen/cms_screen.dart';
import 'package:docuhealth/screen/user/add_more_family_member.dart';
import 'package:docuhealth/screen/user/my_profile.dart';
import 'package:docuhealth/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import '../../helper/get_storage_helper.dart';
import '../../app_config.dart';
import '../../services/base_client.dart';
import '../home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  BaseClient baseClient = BaseClient();
  List profiles = [];

  Future<void> getUserProfile(BuildContext context) async {
    try {
      final response = await baseClient.get('profiles', true);
      if (response is Map && response['success'] == true) {
        final data = response['data'];
        if (data is Map && data['profiles'] is List) {
          profiles = data['profiles'];
        } else if (data is List) {
          profiles = data;
        } else {
          profiles = [];
        }
      } else {
        profiles = [];
      }
    } catch (_) {
      profiles = [];
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<bool> onProfileTap(int profileId) async {
    var data = {"profile_id": "$profileId", "device_token": deviceToken};
    try {
      final response = await baseClient.post('profile-login', data, true);
      if (response is Map && response['success'] == true) {
        box.write('id', response['data']['id']);
        box.write('username', response['data']['name']);
        box.write('mobileno', response['data']['phone']);
        box.write('email', response['data']['email']);
        box.write('imagePath', response['data']['icon']);
        box.write('access_token', response['token']);
        box.write('has_profile_context', true);
        if (mounted) getUserProfile(context);
        Get.snackbar("Success", response['message']);
        return true;
      }
      if (response is Map) {
        Get.snackbar("Failed", response['message']?.toString() ?? "Failed");
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _resetSession() async {
    await box.erase();
    GetStorageHelper.setinitialdata();
    box.write('is_logged_in', false);
    if (!mounted) return;
    Get.offNamedUntil('/Splash', (route) => false);
  }

  Future<void> _openDeletionHelpPage() async {
    try {
      await Utils.launchInBrowser(Uri.parse(accountDeletionUrl));
    } catch (_) {
      Get.snackbar(
        "Failed",
        "Unable to open the deletion help page right now.",
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final response = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => FutureProgressDialog(
          baseClient.post('delete-account', {}, true),
          message: const Text('Deleting account...'),
        ),
      );

      if (response is Map && response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message']?.toString() ?? "Account deleted successfully.",
        );
        await _resetSession();
        return;
      }

      Get.snackbar(
        "Failed",
        response is Map
            ? response['message']?.toString() ?? "Unable to delete account."
            : "Unable to delete account.",
      );
    } catch (_) {
      Get.snackbar(
        "Failed",
        "Unable to delete account right now. You can use the deletion help page instead.",
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete account"),
        content: const Text(
          "This permanently deletes your account, profiles, and associated data. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop('help');
            },
            child: const Text("Help page"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop('delete');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (action == 'help') {
      await _openDeletionHelpPage();
    } else if (action == 'delete') {
      await _deleteAccount();
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
                              () {
                                // ignore: use_build_context_synchronously
                                if (mounted) getUserProfile(context);
                              },
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
                            if (response == true) {
                              Get.off(const HomePage(
                                currentIndex: 0,
                              ));
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            padding: profiles[i]['active'] == true
                                ? EdgeInsets.all(15.r)
                                : EdgeInsets.all(5.r),
                            decoration: profiles[i]['active'] == true
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
                                  backgroundImage: (() {
                                    final iconUrl =
                                        (profiles[i]['icon'] ?? '').toString();
                                    if (iconUrl.isEmpty ||
                                        iconUrl == 'null' ||
                                        !iconUrl.startsWith('http')) {
                                      return null;
                                    }
                                    return NetworkImage(iconUrl);
                                  })(),
                                  child: (() {
                                    final iconUrl =
                                        (profiles[i]['icon'] ?? '').toString();
                                    if (iconUrl.isEmpty ||
                                        iconUrl == 'null' ||
                                        !iconUrl.startsWith('http')) {
                                      return Icon(
                                        Icons.person,
                                        color: AppColors.primaryColor,
                                      );
                                    }
                                    return null;
                                  })(),
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
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      ),
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
                      backgroundColor: Colors.grey.shade100,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      ),
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
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.lock_person,
                        color: AppColors.primaryColor,
                      ),
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
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.privacy_tip,
                        color: AppColors.primaryColor,
                      ),
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
                              backgroundColor: AppColors.primaryColor,
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
                              backgroundColor: Colors.grey.shade400,
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        radius: 10,
                      );
                    },
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                      Icons.logout,
                      color: AppColors.primaryColor,
                    ),
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
                  ListTile(
                    onTap: _showDeleteAccountDialog,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.red.shade50,
                      child: Icon(
                        Icons.delete_forever,
                        color: Colors.red.shade700,
                      ),
                    ),
                    title: Text(
                      "Delete account",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    subtitle: Text(
                      "Permanently delete your account and data",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreyTextColor,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.red.shade700,
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
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.message,
                        color: AppColors.primaryColor,
                      ),
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
