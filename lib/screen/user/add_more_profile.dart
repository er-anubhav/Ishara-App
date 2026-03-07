import 'package:docuhealth/contstants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddMoreProfile extends StatefulWidget {
  const AddMoreProfile({super.key});

  @override
  State<AddMoreProfile> createState() => _AddMoreProfileState();
}

class _AddMoreProfileState extends State<AddMoreProfile> {
  List profileItem = [
    {
      'image': 'assets/icons/doctor-prescription.png',
      'title': 'Doctor Prescription'
    },
    {'image': 'assets/icons/pharmacy-records.png', 'title': 'Pharmacy Records'},
    {'image': 'assets/icons/daily-remainder.png', 'title': 'Daily Reminders'},
    {  
      'image': 'assets/icons/hospital-bill.png',
      'title': 'Hospital Bill Management'
    },
    {'image': 'assets/icons/test-report.png', 'title': 'Test Reports'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitebgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: profileItem.length,
          itemBuilder: (_, i) {
            return ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              leading: Image.asset(
                profileItem[i]['image'],
                height: 30.h,
                width: 30.w,
              ),
              title: Text(
                profileItem[i]['title'],
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
