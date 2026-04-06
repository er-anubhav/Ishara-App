import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:map_launcher/map_launcher.dart';
import '../../contstants/app_colors.dart';

class DoctorDeatailsScreen extends StatefulWidget {
  final int doctorID;
  final String doctorNAme;
  const DoctorDeatailsScreen(
      {super.key, required this.doctorID, required this.doctorNAme});

  @override
  State<DoctorDeatailsScreen> createState() => _DoctorDeatailsScreenState();
}

class _DoctorDeatailsScreenState extends State<DoctorDeatailsScreen> {
  BaseClient baseClient = BaseClient();
  bool isLoading = true;
  dynamic doctorDetails;

  Future<void> getDoctorDetails(BuildContext context) async {
    final response = await baseClient.get(
        'medico-search-details?id=${widget.doctorID}', true);
    if (response['success']) {
      doctorDetails = response['data'][0];
      debugPrint(doctorDetails.toString());
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    getDoctorDetails(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarybgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          widget.doctorNAme,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(color: AppColors.whitebgColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 100.h,
                          width: 100.w,
                          margin: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            color: Colors.white,
                          ),
                          child: doctorDetails['icon'] == null ||
                                  doctorDetails['icon'] == ""
                              ? Image.asset('assets/images/doctor-image.png')
                              : Image.network(
                                  doctorDetails['icon'],
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${doctorDetails['name'] ?? ''}",
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
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
                                        "${doctorDetails['degree'] ?? ''}",
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
                                      borderRadius: BorderRadius.circular(10.r),
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
                                        "${doctorDetails['specializations'] ?? ''}",
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
                                    "${doctorDetails['experience'] ?? ''} overall",
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
                    Container(
                      margin: EdgeInsets.only(
                          left: 10.w, right: 10.w, bottom: 10.h),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  doctorDetails['description'] == null ||
                                          doctorDetails['description'] == ""
                                      ? const SizedBox()
                                      : Text(
                                          'About',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                  doctorDetails['description'] == null ||
                                          doctorDetails['description'] == ""
                                      ? const SizedBox()
                                      : SizedBox(
                                          height: 5.h,
                                        ),
                                  doctorDetails['description'] == null ||
                                          doctorDetails['description'] == ""
                                      ? const SizedBox()
                                      : Text(
                                          '${doctorDetails['description']}',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Text(
                                    'Clinick Details',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )),
                          ListView.builder(
                            itemCount: doctorDetails['addresses'].length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (_, i) {
                              return Container(
                                margin: EdgeInsets.only(
                                    left: 10.w, right: 10.w, top: 10.h),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.lightGreyTextColor),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Timing",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  AppColors.darkGreyTextColor,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            decoration: BoxDecoration(
                                                gradient: AppColors
                                                    .primaryLinearGradient,
                                                borderRadius:
                                                    BorderRadius.circular(5.r)),
                                            child: Text(
                                              "${doctorDetails['addresses'][i]['status']}",
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AppColors.darkGreyTextColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Text(
                                        "${doctorDetails['addresses'][i]['time_from']} - ${doctorDetails['addresses'][i]['time_to']} (${doctorDetails['addresses'][i]['open_days']})",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.darkGreyTextColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        "${doctorDetails['addresses'][i]['addr1']}",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.darkGreyTextColor,
                                        ),
                                      ),
                                      doctorDetails['addresses'][i]
                                                  ['latitude'] ==
                                              null
                                          ? const SizedBox()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.all(15.r),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      130,
                                                  child: OutlinedButton(
                                                    onPressed: () async {
                                                      final availableMaps =
                                                          await MapLauncher
                                                              .installedMaps;
                                                      await availableMaps.first
                                                          .showMarker(
                                                        coords: Coords(
                                                            double.parse(doctorDetails[
                                                                    'addresses']
                                                                [
                                                                i]['latitude']),
                                                            double.parse(doctorDetails[
                                                                    'addresses']
                                                                [
                                                                i]['longitude'])),
                                                        title: "Clinick",
                                                      );
                                                    },
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                            foregroundColor: AppColors
                                                                .primaryColor),
                                                    child: Text(
                                                      "Get directions",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
    );
  }
}
