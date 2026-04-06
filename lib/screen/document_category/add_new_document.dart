import 'package:docuhealth/components/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../contstants/app_colors.dart';
import '../../theme.dart';

class AddNewDocument extends StatefulWidget {
  const AddNewDocument({super.key});

  @override
  State<AddNewDocument> createState() => _AddNewDocumentState();
}

class _AddNewDocumentState extends State<AddNewDocument> {
  String? dropdownValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitebgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.r),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                mainAxisExtent: 102,
              ),
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 102.h,
                  width: 102.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGreyTextColor),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50.h,
                        child: Icon(
                          Icons.add_circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "Add document",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(
              height: 15.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: const Color.fromRGBO(255, 255, 255, 1),
                border: Border.all(
                  color: const Color.fromRGBO(187, 187, 187, 1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 30.r,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      hint: Text(
                        "Select doctor",
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>[
                        'Dr. Mayank Tripathi',
                        'Dr. Mayank Tripathi 01',
                        'Dr. Mayank Tripathi 02',
                        'Dr. Mayank Tripathi 03'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Text(
              "Remarks",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            TextFormField(
              maxLines: 5,
              decoration: AppTheme.defaultDescriptionInputFieldDecoration(
                "Write your remarks here ...",
                Icons.email,
              ),
            ),
            SizedBox(
              height: 30.h,
            ),
            DefaultButton(
              buttonText: "Save",
              onPress: () {},
            )
          ],
        ),
      )),
    );
  }
}
