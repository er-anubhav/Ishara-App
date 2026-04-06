import 'package:docuhealth/components/image_preview_screen.dart';
import 'package:docuhealth/components/pdf_preview.dart';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PdfCard extends StatelessWidget {
  final String createdAt;
  final String fileNAme;
  final String imageURl;
  final String thumbnilUrl;
  final String fileType;
  final int fileId;
  final String remarks;
  const PdfCard(
      {super.key,
      required this.createdAt,
      required this.fileNAme,
      required this.thumbnilUrl,
      required this.fileType,
      required this.fileId,
      required this.remarks,
      required this.imageURl});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (fileType == "image") {
          Get.to(ImagePreviewScreen(
            imageUrl: imageURl,
            fileId: fileId,
            fileName: fileNAme,
            remarks: remarks,
          ));
        } else {
          Get.to(PdfPreviewScreen(
            isFromFile: false,
            isNetworkImage: false,
            fileId: fileId,
            fileName: fileNAme,
            remarks: remarks,
            documentUrl: imageURl,
          ));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        height: 160.h,
        width: 145.w,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(
              color: AppColors.primaryColor,
            )),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey.shade100,
              ),
              child: Center(
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    thumbnilUrl,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 50.h,
                width: 145.w,
                padding: EdgeInsets.only(left: 15.w, right: 10.w),
                decoration: BoxDecoration(
                    color: AppColors.whitebgColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.r),
                        bottomRight: Radius.circular(10.r))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/document-icon.png',
                          height: 15.h,
                          width: 15.w,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            fileNAme,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.greyTextColor),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      createdAt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGreyTextColor,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
