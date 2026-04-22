import 'package:docuhealth/components/knowledge_card.dart';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/screen/knowledge_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../services/base_client.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({
    super.key,
  });

  @override
  KnowledgeScreenState createState() => KnowledgeScreenState();
}

class KnowledgeScreenState extends State<KnowledgeScreen>
    with SingleTickerProviderStateMixin {
  BaseClient baseClient = BaseClient();
  TabController? _tabController;
  bool isLoading = true;
  List categories = [];

  Future<void> getCategories(BuildContext context) async {
    try {
      final response = await baseClient.get('blogs/categories', true);
      debugPrint(response.toString());

      if (response is Map && response['success'] == true) {
        categories = (response['data'] as List?) ?? [];

        _tabController?.removeListener(_handleTabIndex);
        _tabController?.dispose();

        if (categories.isNotEmpty) {
          _tabController = TabController(
              length: categories.length, vsync: this, initialIndex: 0);
          _tabController!.addListener(_handleTabIndex);
        } else {
          _tabController = null;
        }
      } else {
        categories = [];
      }
    } catch (_) {
      categories = [];
    } finally {
      if (mounted) {
        isLoading = false;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCategories(context);
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabIndex);
    _tabController?.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : categories.isNotEmpty
            ? DefaultTabController(
                length: categories.length,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: AppColors.primaryColor,
                    title: const Text('Knowledge Section'),
                    bottom: PreferredSize(
                      preferredSize:
                          Size(MediaQuery.of(context).size.width, 100.h),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    onChanged: ((value) {
                                      // searchKey = value;
                                      // _onRefresh();
                                    }),
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
                                            color: AppColors.selectedIconColor,
                                            width: 2.w),
                                        borderRadius:
                                            BorderRadius.circular(50.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabs: categories
                                .map((e) => Tab(
                                      child: Row(
                                        children: [
                                          e['icon'] == null
                                              ? const SizedBox()
                                              : Image.network(
                                                  "${e['icon']}",
                                                  height: 20.h,
                                                  width: 20.w,
                                                  fit: BoxFit.cover,
                                                ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          Text(
                                            e['name'],
                                            style: TextStyle(
                                              color: AppColors.whiteTextColor,
                                            ),
                                          )
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    children: categories
                        .map(
                          (e) => TabBody(
                            categoryId: e['id'],
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
            : Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          child: Image.asset('assets/images/nodata.png'),
                        ),
                        const Text(
                          "Nothing to show!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
              );
  }
}

class TabBody extends StatefulWidget {
  final dynamic categoryId;
  const TabBody({super.key, required this.categoryId});

  @override
  State<TabBody> createState() => _TabBodyState();
}

class _TabBodyState extends State<TabBody> {
  List listData = [];
  int currentPage = 1;
  int totalpage = 1;
  String searchKey = '';
  BaseClient baseClient = BaseClient();
  bool isLoading = true;

  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  Future<dynamic> getData(BuildContext context, int currentPage) async {
    isLoading = true;
    setState(() {});
    try {
      final resp = await baseClient.get(
          'blogs?category=${widget.categoryId}&search=$searchKey&page=$currentPage',
          true);
      if (resp is Map && resp['success'] == true && resp['data'] is Map) {
        final records = (resp["data"] as Map)["data_records"];
        if (records is Map &&
            records['total_records'] != null &&
            records['limit'] != null &&
            records['limit'] != 0) {
          double pageCount = records['total_records'] / records['limit'];
          totalpage = pageCount.ceil();
        }
        return (resp['data'] as Map)['data'] ?? [];
      }
      return [];
    } catch (_) {
      return [];
    } finally {
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _onRefresh() async {
    var data = await getData(context, currentPage);
    listData = data ?? [];
    if (mounted) setState(() {});
    refreshController.refreshCompleted();
  }

  void _onLoading() async {
    currentPage++;
    if (currentPage > totalpage) {
      refreshController.loadNoData();
    } else {
      var data = await getData(context, currentPage);
      if (data is List) {
        for (var i = 0; i < data.length; i++) {
          if (data[i]['tag'] != 'folder') {
            listData.add(data[i]);
          }
        }
      }
      if (mounted) setState(() {});
      refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullUp: true,
      enablePullDown: true,
      header: const WaterDropHeader(),
      controller: refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: listData.isEmpty
          ? const Center(
              child: Text("Nothing to show"),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: listData.length,
              itemBuilder: (_, i) {
                return KnowledgeCard(
                  title: "${listData[i]['heading']}",
                  subtitle: "${listData[i]['description']}",
                  node: '',
                  node1: '',
                  path: '${listData[i]['image']}',
                  onPress: () {
                    Get.to(KnowledgeDetails(id: listData[i]['id']));
                  },
                );
              },
            ),
    );
  }
}
