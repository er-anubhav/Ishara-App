import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class KnowledgeDetails extends StatefulWidget {
  final int id;
  const KnowledgeDetails({super.key, required this.id});

  @override
  State<KnowledgeDetails> createState() => _KnowledgeDetailsState();
}

class _KnowledgeDetailsState extends State<KnowledgeDetails> {
  late ScrollController _scrollController;
  BaseClient baseClient = BaseClient();
  List blogData = [];
  bool isLoading = true;

  Future<void> getData() async {
    final response = await baseClient.get('blog/view/${widget.id}', true);
    if (response['success']) {
      blogData = response["data"];
    } else {
      blogData = [];
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {}
        });
      });
    getData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: const Color.fromARGB(88, 32, 6, 69),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        '${blogData[0]['heading']}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 10.h, horizontal: 10.w),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryLinearGradient,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        "${blogData[0]['category_name']}",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      child: Hero(
                        transitionOnUserGestures: true,
                        tag: 'assets/image/mobile.png',
                        child: Image(
                          height: 150.h,
                          image: NetworkImage('${blogData[0]["image"]}'),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Html(
                        data: """${blogData[0]["content"]}""",
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
