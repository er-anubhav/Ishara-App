import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../contstants/app_colors.dart';

class DoctorWiseDocuments extends StatefulWidget {
  final String title;
  const DoctorWiseDocuments({super.key, required this.title});

  @override
  State<DoctorWiseDocuments> createState() => _DoctorWiseDocumentsState();
}

class _DoctorWiseDocumentsState extends State<DoctorWiseDocuments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
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
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(
                      Icons.filter_list,
                    ),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      const PopupMenuItem(
                        value: 1,
                        child: Text('Working a lot harder'),
                      ),
                      const PopupMenuItem(
                        value: 2,
                        child: Text('Being a lot smarter'),
                      ),
                      const PopupMenuItem(
                        value: 3,
                        child: Text('Being a self-starter'),
                      ),
                      const PopupMenuItem(
                        value: 4,
                        child: Text('Placed in charge of trading charter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, i) {
                return Card(
                  color: AppColors.primarybgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  margin:
                      EdgeInsets.only(left: 15.w, right: 15.w, bottom: 12.h),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: ListTile(
                      leading: SizedBox(
                        height: 40.h,
                        width: 40.w,
                        child: Image.asset('assets/icons/document-icon.png'),
                      ),
                      title: Text(
                        'Mar 23,2022',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          'at 01:20 PM in spring Hill Hospital Allergy shot',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreyTextColor,
                          ),
                        ),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          const PopupMenuItem(
                            value: 1,
                            child: Text('Working a lot harder'),
                          ),
                          const PopupMenuItem(
                            value: 2,
                            child: Text('Being a lot smarter'),
                          ),
                          const PopupMenuItem(
                            value: 3,
                            child: Text('Being a self-starter'),
                          ),
                          const PopupMenuItem(
                            value: 4,
                            child: Text('Placed in charge of trading charter'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
