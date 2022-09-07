import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../contstants/app_colors.dart';

class CmsScreen extends StatefulWidget {
  final String url;
  final String appBarTitle;
  const CmsScreen({Key? key, required this.url, required this.appBarTitle})
      : super(key: key);

  @override
  State<CmsScreen> createState() => _CmsScreenState();
}

class _CmsScreenState extends State<CmsScreen> {
  bool isLoading = true;
  BaseClient baseClient = BaseClient();
  var htmlData;

  getCmsData() async {
    final response = await baseClient.get(widget.url, false);
    if (response['success']) {
      htmlData = response['data']['content'];
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getCmsData();
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
          widget.appBarTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : htmlData == null
              ? Center(
                  child: Text(
                    'Content not found!',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyTextColor,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: HtmlWidget(
                    htmlData,
                    enableCaching: true,
                  ),
                ),
    );
  }
}
