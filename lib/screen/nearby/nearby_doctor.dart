import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/screen/nearby/filter_screen.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'doctor_details_screen.dart';

class NearNyDoctor extends StatefulWidget {
  final int categoryId;
  final String appBarTitle;
  const NearNyDoctor(
      {super.key, required this.categoryId, required this.appBarTitle});

  @override
  State<NearNyDoctor> createState() => _NearNyDoctorState();
}

class _NearNyDoctorState extends State<NearNyDoctor> {
  BaseClient baseClient = BaseClient();
  bool isLoading = true;
  String searchKey = '';
  int currentPage = 1;
  int totalpage = 1;
  List doctor = [];
  List filterListData = [];
  String filterText = "";
  String filterVariable = "";

  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  Future<void> getNearByDoctor() async {
    final filterResponse = await baseClient.get('filters', true);
    if (filterResponse['success']) {
      filterListData = filterResponse['data'];
      isLoading = false;
      setState(() {});
    }
  }

  Future<dynamic> getData(BuildContext context, int currentPage) async {
    final resp = await baseClient.get(
      'medico-search?name=$searchKey&category=${widget.categoryId}&$filterVariable=$filterText&page=$currentPage',
      true,
    );
    debugPrint(resp["data"]["data_records"].toString());
    if (resp['success']) {
      if (resp["data"]["data_records"] != null) {
        double pageCount = resp["data"]["data_records"]['total_records'] /
            resp["data"]["data_records"]['limit'];

        totalpage = pageCount.ceil();
      }
      return resp['data']['data'];
    }
  }

  Future<void> _onRefresh() async {
    var data = await getData(context, currentPage);
    doctor = data;
    if (mounted) setState(() {});
    refreshController.refreshCompleted();
  }

  void _onLoading() async {
    currentPage++;
    if (currentPage > totalpage) {
      refreshController.loadNoData();
    } else {
      var data = await getData(context, currentPage);
      for (var i = 0; i < data.length; i++) {
        if (data[i]['tag'] != 'folder') {
          doctor.add(data[i]);
        }
      }
      if (mounted) setState(() {});
      refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    getNearByDoctor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: AppColors.primaryColor,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 50.h),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: ((value) {
                      searchKey = value;
                      _onRefresh();
                    }),
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
                IconButton(
                  onPressed: () async {
                    final response = await Get.to(
                      FilterScreen(filterListData: filterListData),
                    );
                    filterVariable = response['filter_var'];
                    filterText = response['filter_data'];

                    if (response != null && response != "" && mounted) {
                      await showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) => FutureProgressDialog(
                          _onRefresh(),
                          message: const Text(
                            'Filtering data please wait...',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.filter_alt,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
        title: Text(
          widget.appBarTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
      ),
      body: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        header: const WaterDropHeader(),
        controller: refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: doctor.isEmpty
            ? const Center(
                child: Text("Nothing to show"),
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10.h),
                itemCount: doctor.length,
                itemBuilder: (_, i) {
                  return InkWell(
                    onTap: () {
                      Get.to(
                        DoctorDeatailsScreen(
                          doctorID: doctor[i]['id'],
                          doctorNAme: doctor[i]['name'],
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
                            child: doctor[i]['icon'] == null ||
                                    doctor[i]['icon'] == ""
                                ? Image.asset('assets/images/doctor-image.png')
                                : Image.network(
                                    doctor[i]['icon'],
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${doctor[i]['name'] ?? ''}",
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
                                          "${doctor[i]['degree'] ?? ''}",
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
                                          "${doctor[i]['specializations'] ?? ''}",
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
                                      "${doctor[i]['experience'] ?? ''} overall",
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
              ),
      ),
    );
  }
}
