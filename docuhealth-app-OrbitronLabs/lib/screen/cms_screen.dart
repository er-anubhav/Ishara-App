import 'package:docuhealth/app_config.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:docuhealth/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../contstants/app_colors.dart';

class CmsScreen extends StatefulWidget {
  final String url;
  final String appBarTitle;
  const CmsScreen({super.key, required this.url, required this.appBarTitle});

  @override
  State<CmsScreen> createState() => _CmsScreenState();
}

class _CmsScreenState extends State<CmsScreen> {
  bool isLoading = true;
  BaseClient baseClient = BaseClient();
  String? htmlData;

  Future<void> getCmsData() async {
    final response = await baseClient.get(widget.url, false);
    if (response['success']) {
      htmlData = response['data']['content'];
    }
    if (!mounted) {
      return;
    }
    isLoading = false;
    setState(() {});
  }

  Uri _resolveCmsUri(String url) {
    final apiUri = Uri.parse(baseUrl);
    final publicBaseUri = Uri(
      scheme: apiUri.scheme,
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
    );
    return publicBaseUri.resolve(url);
  }

  void _openCmsLink(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return;
    }

    try {
      await Utils.launchInBrowser(_resolveCmsUri(url));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link.'),
        ),
      );
    }
  }

  Map<String, Style> _htmlStyles() {
    final bodyTextStyle = TextStyle(
      fontSize: 15.sp,
      height: 1.65,
      color: AppColors.darkGreyTextColor,
    );

    return {
      'html': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
      ),
      'body': Style.fromTextStyle(bodyTextStyle).copyWith(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
      ),
      'p': Style.fromTextStyle(bodyTextStyle).copyWith(
        margin: Margins.only(bottom: 16),
      ),
      'h1': Style.fromTextStyle(
        TextStyle(
          fontSize: 28.sp,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: AppColors.selectedIconColor,
        ),
      ).copyWith(
        margin: Margins.only(top: 4, bottom: 18),
      ),
      'h2': Style.fromTextStyle(
        TextStyle(
          fontSize: 22.sp,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: AppColors.selectedIconColor,
        ),
      ).copyWith(
        margin: Margins.only(top: 12, bottom: 14),
      ),
      'h3': Style.fromTextStyle(
        TextStyle(
          fontSize: 18.sp,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreyTextColor,
        ),
      ).copyWith(
        margin: Margins.only(top: 10, bottom: 12),
      ),
      'ul': Style(
        margin: Margins.only(bottom: 18),
        padding: HtmlPaddings.only(left: 18),
      ),
      'ol': Style(
        margin: Margins.only(bottom: 18),
        padding: HtmlPaddings.only(left: 18),
      ),
      'li': Style.fromTextStyle(bodyTextStyle).copyWith(
        margin: Margins.only(bottom: 10),
      ),
      'a': Style(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
        textDecoration: TextDecoration.underline,
      ),
      'strong': Style(
        color: AppColors.darkGreyTextColor,
        fontWeight: FontWeight.w700,
      ),
      'blockquote': Style(
        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),
        color: AppColors.darkGreyTextColor,
        margin: Margins.only(top: 10, bottom: 18),
        padding: HtmlPaddings.symmetric(horizontal: 14, vertical: 12),
      ),
    };
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
              : htmlData == null || htmlData!.trim().isEmpty
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
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.whitebgColor,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryLinearGradient,
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            widget.appBarTitle,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.selectedIconColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Html(
                          data: htmlData ?? '',
                          shrinkWrap: true,
                          style: _htmlStyles(),
                          onLinkTap: (url, attributes, element) {
                            _openCmsLink(url);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
