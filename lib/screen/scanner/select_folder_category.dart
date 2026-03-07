import 'package:docuhealth/screen/scanner/upload_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../contstants/app_colors.dart';
import 'upload_document.dart';

class SelectFolderCategory extends StatefulWidget {
  final dynamic images;
  final int? selectedFolder;
  final bool ispdf;
  const SelectFolderCategory(
      {super.key,
      required this.images,
      required this.selectedFolder,
      required this.ispdf});

  @override
  State<SelectFolderCategory> createState() => _SelectFolderCategoryState();
}

class _SelectFolderCategoryState extends State<SelectFolderCategory> {
  List homeGrid = [
    {
      "image-url": "assets/images/lab-report.png",
      "title": "Test Reports",
      "category_name": "TEST_REPORTS",
      "redirect-to": "/Test_Reports"
    },
    {
      "image-url": "assets/images/doctor-icon.png",
      "title": "Doctor Prescription",
      "category_name": "DOCTOR_PRESCRIPTION",
      "redirect-to": "/Doctor_Prescription"
    },
    {
      "image-url": "assets/images/hospital-icon.png",
      "title": "Hospital Bills",
      "category_name": "HOSPITAL_BILLS",
      "redirect-to": "/Hospital_Management"
    },
    {
      "image-url": "assets/images/pharmacy-icon.png",
      "title": "Pharmacy Records",
      "category_name": "PHARMACY_RECORDS",
      "redirect-to": "/Pharmacy_Record"
    },
    {
      "image-url": "assets/images/folder.png",
      "title": "My Docs",
      "category_name": "MY_DOCS",
      "redirect-to": "/My_Documents"
    },
    {
      "image-url": "assets/images/file.png",
      "title": "Genral Docs",
      "category_name": "GENRAL_DOCS",
      "redirect-to": "/Genral_Documents"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text("Select category"),
      ),
      body: SafeArea(
        child: GridView.builder(
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
                if (widget.ispdf) {
                  Get.to(
                    UploadPdf(
                        appBarTitle: '',
                        redirectTo: homeGrid[index]["redirect-to"],
                        selectedCategory: homeGrid[index]['category_name'],
                        selectedFolder: widget.selectedFolder,
                        upload: widget.images),
                  );
                } else {
                  Get.to(
                    UploadDcoumnetScreen(
                      uploadIMages: widget.images,
                      selectedCategory: homeGrid[index]['category_name'],
                      appBarTitle: '',
                      redirectTo: homeGrid[index]["redirect-to"],
                      selectedFolder: widget.selectedFolder,
                    ),
                  );
                }
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
                      padding:
                          EdgeInsets.only(bottom: 10.h, left: 5.w, right: 5.w),
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
      ),
    );
  }
}
