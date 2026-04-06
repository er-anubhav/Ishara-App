// import 'package:docuhealth/screen/nearby/nearby_doctor.dart';
import 'package:docuhealth/screen/search/search_screen.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart';
import '../../contstants/app_colors.dart';
import '../nearby/nearby_doctor.dart';
import '../user/select_user_scrren.dart';

class NearByScreen extends StatefulWidget {
  const NearByScreen({super.key});

  @override
  State<NearByScreen> createState() => _NearByScreenState();
}

class _NearByScreenState extends State<NearByScreen> {
  BaseClient baseClient = BaseClient();
  List specialization = [];
  bool isLoading = true;
  String? errorMessage;
  bool requiresProfileSelection = false;

  Future<void> getSpecialization(BuildContext context) async {
    errorMessage = null;
    requiresProfileSelection = false;
    try {
      final response = await baseClient.get('categories', true);

      if (response is Map && response['success'] == true) {
        specialization = (response['data'] as List?) ?? [];
        if (specialization.isEmpty) {
          errorMessage =
              "No nearby categories available yet. Please try again later.";
        }
      } else {
        specialization = [];
        final message =
            (response is Map ? response['message'] : null)?.toString() ??
                "Unable to load nearby categories";
        if (message.toLowerCase().contains('unauthorised profile access')) {
          requiresProfileSelection = true;
          errorMessage =
              "Please select your profile first to use Nearby Doctors & Pharmacist.";
        } else {
          errorMessage = message;
        }
      }
    } catch (_) {
      specialization = [];
      errorMessage =
          "Unable to load nearby categories right now. Please try again.";
    } finally {
      if (mounted) {
        isLoading = false;
        setState(() {});
      }
      if (mounted && requiresProfileSelection) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Get.snackbar(
            "Profile required",
            "Select a profile to continue",
            duration: const Duration(seconds: 3),
          );
        });
      }
    }
  }

  @override
  void initState() {
    getSpecialization(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Nearby Doctors & Pharmacist',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 50.h),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.to(const SearchScreen());
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.whitebgColor,
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.selectedIconColor,
                          ),
                          hintText: "Search",
                          hintStyle: TextStyle(
                            fontSize: 18.sp,
                            color: AppColors.lightGreyTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.selectedIconColor, width: 2.w),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: specialization.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  errorMessage ?? "Nothing to show",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.darkGreyTextColor,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                if (requiresProfileSelection)
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.to(const SelectUserScreen());
                                    },
                                    child: const Text("Select profile"),
                                  ),
                                if (!requiresProfileSelection)
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      getSpecialization(context);
                                    },
                                    child: const Text("Retry"),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15.w, top: 10.h, bottom: 5.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Not feeling too well ?",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreyTextColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Text(
                                  "Treat common symptoms instantly via video consultation",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.greyTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(15.r),
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 120,
                            ),
                            itemCount: specialization.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: (() => Get.to(
                                      NearNyDoctor(
                                        categoryId: specialization[index]['id'],
                                        appBarTitle: specialization[index]
                                            ['name'],
                                      ),
                                    )),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 70.h,
                                      child: Image.network(
                                        specialization[index]['icon'],
                                        width: double.infinity,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25.h,
                                      child: Text(
                                        specialization[index]['name'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.greyTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ),
    );
  }
}
