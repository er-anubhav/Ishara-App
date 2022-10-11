import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/image_preview_screen.dart';
import '../../components/knowledge_card.dart';
import '../../components/pdf_preview.dart';
import '../files/files_screen.dart';
import '../knowledge_details_screen.dart';
import '../nearby/doctor_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  BaseClient baseClient = BaseClient();
  bool isLoading = true;
  List searchData = [];

  getSearchData(searchKey) async {
    final response = await baseClient.get('search?name=$searchKey', true);
    if (response['success']) {
      searchData = response['data'];
    } else {
      searchData = [];
    }
    isLoading = false;
    setState(() {});
  }

  Widget getBodyFromTag(tag, i) {
    switch (tag) {
      case "folder":
        return Card(
          color: AppColors.whitebgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ListTile(
            onTap: () {
              if (searchData[i]['tag'] == "folder") {
                Get.to(FilesScreen(
                  operationType: "",
                  redirectTo: "",
                  appBarTitle: searchData[i]['name'],
                  folderId: searchData[i]['id'],
                  fileId: 0,
                  categoryName: searchData[i]['belongs_to'],
                  documentType: "",
                ));
              }
            },
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.h, horizontal: 5.w),
            leading: Container(
              height: 70.h,
              width: 70.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                image: searchData[i]['tag'] == "folder"
                    ? DecorationImage(
                        image: AssetImage(
                            searchData[i]['category'] == "DOCTOR_PRESCRIPTION"
                                ? 'assets/images/person-image.png'
                                : searchData[i]['category'] == "HOSPITAL_BILLS"
                                    ? 'assets/icons/hospital-icon.png'
                                    : 'assets/icons/blood-pressure-file.png'),
                      )
                    : DecorationImage(
                        image: NetworkImage(searchData[i]['thumbnail_file']),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Text(
              searchData[i]['name'],
              maxLines: 1,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGreyTextColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  searchData[i]['created_at'],
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                searchData[i]['tag'] == "folder"
                    ? const SizedBox()
                    : Text(
                        searchData[i]['remarks'] ?? '',
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightGreyTextColor,
                        ),
                      ),
              ],
            ),
          ),
        );
      case "file":
        return Card(
          color: AppColors.whitebgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ListTile(
            onTap: () {
              if (searchData[i]['file_type'] == "image") {
                Get.to(ImagePreviewScreen(
                  imageUrl: searchData[i]['file'],
                  fileId: searchData[i]['id'],
                  fileName: searchData[i]['name'] ?? '',
                  remarks: searchData[i]['remarks'] ?? '',
                ));
              } else {
                Get.to(PdfPreviewScreen(
                  isFromFile: false,
                  documentUrl: searchData[i]['file'],
                  isNetworkImage: true,
                  fileId: searchData[i]['id'],
                  fileName: searchData[i]['name'] ?? '',
                  remarks: searchData[i]['remarks'] ?? '',
                ));
              }
            },
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.h, horizontal: 5.w),
            leading: Container(
              height: 70.h,
              width: 70.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                image: searchData[i]['tag'] == "folder"
                    ? DecorationImage(
                        image: AssetImage(
                            searchData[i]['category'] == "DOCTOR_PRESCRIPTION"
                                ? 'assets/images/person-image.png'
                                : searchData[i]['category'] == "HOSPITAL_BILLS"
                                    ? 'assets/icons/hospital-icon.png'
                                    : 'assets/icons/blood-pressure-file.png'),
                      )
                    : DecorationImage(
                        image: NetworkImage(searchData[i]['thumbnail_file']),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Text(
              searchData[i]['name'],
              maxLines: 1,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGreyTextColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  searchData[i]['created_at'],
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                searchData[i]['tag'] == "folder"
                    ? const SizedBox()
                    : Text(
                        searchData[i]['remarks'] ?? '',
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightGreyTextColor,
                        ),
                      ),
              ],
            ),
          ),
        );
      case "Doctor":
        return InkWell(
          onTap: () {
            Get.to(
              DoctorDeatailsScreen(
                doctorID: searchData[i]['id'],
                doctorNAme: searchData[i]['name'],
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
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
                  child: searchData[i]['icon'] == null ||
                          searchData[i]['icon'] == ""
                      ? Image.asset('assets/images/doctor-image.png')
                      : Image.network(
                          searchData[i]['icon'],
                          fit: BoxFit.cover,
                        ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${searchData[i]['name'] ?? ''}",
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
                        searchData[i]['degree'] == null ||
                                searchData[i]['degree'] == ""
                            ? const SizedBox()
                            : Container(
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
                                      "${searchData[i]['degree'] ?? ''}",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        searchData[i]['degree'] == null ||
                                searchData[i]['degree'] == ""
                            ? const SizedBox()
                            : SizedBox(
                                width: 10.w,
                              ),
                        searchData[i]['specializations'] == null ||
                                searchData[i]['specializations'] == ""
                            ? const SizedBox()
                            : Container(
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
                                      "${searchData[i]['specializations'] ?? ''}",
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
                    searchData[i]['specializations'] == null ||
                            searchData[i]['specializations'] == ""
                        ? const SizedBox()
                        : SizedBox(
                            height: 5.h,
                          ),
                    searchData[i]['experience'] == null ||
                            searchData[i]['experience'] == ""
                        ? const SizedBox()
                        : Container(
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
                                  "${searchData[i]['experience'] ?? ''} overall",
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
      case "post":
        return KnowledgeCard(
          title: "${searchData[i]['heading']}",
          subtitle: "${searchData[i]['description']}",
          node: '',
          node1: '',
          path: '${searchData[i]['image']}',
          onPress: () {
            Get.to(KnowledgeDetails(id: searchData[i]['id']));
          },
        );

      default:
        return const SizedBox();
    }
  }

  @override
  void initState() {
    getSearchData('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitebgColor,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.whitebgColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleSpacing: 5.w,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Docuhealth",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: AppColors.greyButtonColor,
        ),
        backgroundColor: AppColors.whitebgColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: ((value) {
                      getSearchData(value);
                    }),
                    enabled: true,
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
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: searchData.length,
              itemBuilder: (_, i) {
                return getBodyFromTag(searchData[i]['tag'], i);
              },
            ),
    );
  }
}
