import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = true;
  List notification = [];

  getNotification(context) async {
    final response = await BaseClient().get('notifications', true);
    if (response['success']) {
      notification = response['data'];
    } else {
      notification = [];
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getNotification(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text('Notifications'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: ListView.builder(
                itemCount: notification.length,
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  return Card(
                    margin: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
                    color: Colors.grey.shade100,
                    child: ListTile(
                      leading: Container(
                        height: 50.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.r),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.message,
                          size: 40,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      trailing: Text(notification[i]['created_at']),
                      title: Text("${notification[i]['title']}"),
                      subtitle: Text("${notification[i]['message']}"),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
