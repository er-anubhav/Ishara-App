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

class NearByScreen extends StatefulWidget {
  const NearByScreen({Key? key}) : super(key: key);

  @override
  State<NearByScreen> createState() => _NearByScreenState();
}

class _NearByScreenState extends State<NearByScreen> {
  BaseClient baseClient = BaseClient();
  List specialization = [];
  bool isLoading = true;

  getSpecialization(context) async {
    final response = await baseClient.get('categories', true);

    if (response['success']) {
      specialization = response['data'];
      isLoading = false;
      if (mounted) {
        setState(() {});
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
          preferredSize: Size(double.infinity, 50.h),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: 15.w, top: 10.h, bottom: 5.h),
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
                                  appBarTitle: specialization[index]['name'],
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
