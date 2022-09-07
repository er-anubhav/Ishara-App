import 'package:cached_network_image/cached_network_image.dart';
import 'package:docuhealth/components/pdf_card.dart';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:docuhealth/screen/dashboard/profile.dart';
import 'package:docuhealth/screen/search/search_screen.dart';
import 'package:docuhealth/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controllers.dart';
import '../../contstants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../nearby/doctor_details_screen.dart';
import '../notification_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashBoardController dashBoardController = DashBoardController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      dashBoardController =
          Provider.of<DashBoardController>(context, listen: false);
      dashBoardController.getBannersData(context);
      dashBoardController.getRecentUpload(context);
      dashBoardController.getFeaturedDoctorsData(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DashBoardController dashBoardController =
        Provider.of<DashBoardController>(context);
    var recentUploadList = dashBoardController.recentUploads;
    var banners = dashBoardController.bannersList;
    var doctors = dashBoardController.featuredDoctorLIst;

    return Scaffold(
      backgroundColor: AppColors.whitebgColor,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.whitebgColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w, top: 5.h, bottom: 5.h),
          child: Image.asset('assets/images/logo.png'),
        ),
        titleSpacing: 5.w,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Docuhealth",
              style: TextStyle(
                fontSize: 23.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            // Text(
            //   "Tagline",
            //   style: TextStyle(
            //     fontSize: 12.sp,
            //     color: AppColors.primaryColor,
            //   ),
            // ),
          ],
        ),
        iconTheme: IconThemeData(
          color: AppColors.greyButtonColor,
        ),
        backgroundColor: AppColors.whitebgColor,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(const NotificationScreen());
            },
            icon: Icon(
              Icons.notifications,
              size: 30.r,
              color: AppColors.selectedIconColor,
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(const ProfileScreen());
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: box.read('imagePath') == ""
                  ? Icon(
                      Icons.person,
                      color: AppColors.primaryColor,
                      size: 30.r,
                    )
                  : CircleAvatar(
                      child: CachedNetworkImage(
                          imageUrl: "${box.read('imagePath')}"),
                    ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
            child: InkWell(
                onTap: () {
                  Get.to(const SearchScreen());
                },
                child: Container(
                  height: 50.h,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.selectedIconColor,
                      width: 1.5.w,
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: AppColors.selectedIconColor,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        "Search Doctor & Medicopoint",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.lightGreyTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              recentUploadList.isEmpty
                  ? const SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(left: 15.w, right: 15.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Uploaded",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreyTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
              recentUploadList.isEmpty
                  ? const SizedBox()
                  : Container(
                      height: 170.h,
                      padding: EdgeInsets.only(left: 15.w),
                      width: double.infinity,
                      child: Center(
                        child: ListView.builder(
                          itemCount: recentUploadList.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, i) {
                            return Padding(
                              padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                              child: PdfCard(
                                imageURl: recentUploadList[i].file ?? "",
                                thumbnilUrl:
                                    recentUploadList[i].thumbnailFile ?? "",
                                fileType: recentUploadList[i].fileType!,
                                fileNAme: recentUploadList[i].name ?? "",
                                createdAt: recentUploadList[i].createdAt ?? "",
                                fileId: recentUploadList[i].id!,
                                remarks: recentUploadList[i].remarks ?? '',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
              Padding(
                padding: EdgeInsets.only(
                  left: 15.w,
                ),
                child: Text(
                  "Manage your Medical Report",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyTextColor,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(15.r),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  mainAxisExtent: 110.h,
                ),
                itemCount: homeGrid.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Get.toNamed(homeGrid[index]['route']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryLinearGradient,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            homeGrid[index]['image-url'],
                            color: AppColors.primaryColor,
                            height: 50.h,
                            width: 50.w,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 10.h, left: 5.w, right: 5.w),
                            child: Text(
                              homeGrid[index]['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.selectedIconColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Divider(
                thickness: 0.5,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                height: 120.h,
                child: Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: horizontallistItems.length,
                    itemBuilder: (_, i) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(horizontallistItems[i]['route']);
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28.r,
                                backgroundImage: AssetImage(
                                    horizontallistItems[i]['image-url']),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                horizontallistItems[i]['title'],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.selectedIconColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Divider(
                thickness: 0.5,
                color: AppColors.lightGreyTextColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                ),
                child: FlutterCarousel(
                  options: CarouselOptions(
                      height: 150.h,
                      showIndicator: true,
                      autoPlayInterval: const Duration(seconds: 2),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      pageSnapping: true,
                      pauseAutoPlayOnTouch: true,
                      pauseAutoPlayOnManualNavigate: true,
                      pauseAutoPlayInFiniteScroll: false,
                      slideIndicator: CircularSlideIndicator(
                          currentIndicatorColor: AppColors.primaryColor,
                          indicatorBackgroundColor:
                              AppColors.lightGreyTextColor,
                          alignment: Alignment.bottomCenter,
                          indicatorRadius: 4.r),
                      initialPage: 0),
                  items: banners.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return InkWell(
                          onTap: () async {
                            Utils.launchInBrowser(Uri.parse(i.url!));
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 5.w),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              image: DecorationImage(
                                image: NetworkImage(
                                  i.image ?? "",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              doctors.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: 10.w,
                        top: 15.h,
                        bottom: 5.h,
                      ),
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreyTextColor,
                        ),
                      ),
                    )
                  : const SizedBox(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 50.h),
                itemCount: doctors.length,
                itemBuilder: (_, i) {
                  return InkWell(
                    onTap: () {
                      Get.to(
                        DoctorDeatailsScreen(
                          doctorID: doctors[i].id!,
                          doctorNAme: doctors[i].name ?? "",
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: 10.w, right: 10.w, bottom: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lightGreyTextColor,
                            blurRadius: 4,
                            offset: const Offset(
                              -2,
                              2,
                            ),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 100.h,
                            width: 100.w,
                            margin: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: Colors.white,
                            ),
                            child: doctors[i].icon == null ||
                                    doctors[i].icon == ""
                                ? Image.asset('assets/images/doctor-image.png')
                                : Image.network(
                                    doctors[i].icon!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctors[i].name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGreyTextColor,
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        color: Colors.grey.shade100),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/icons/degree.png',
                                          height: 20.h,
                                          width: 20.w,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(
                                          width: 5.w,
                                        ),
                                        Text(
                                          doctors[i].degree ?? '',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        color: Colors.grey.shade100),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/icons/badge.png',
                                          height: 20.h,
                                          width: 20.w,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(
                                          width: 5.w,
                                        ),
                                        Text(
                                          doctors[i].specializations ?? '',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: Colors.grey.shade100),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/experience.png',
                                      height: 20.h,
                                      width: 20.w,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Text(
                                      "${doctors[i].experience ?? ''} overall",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
