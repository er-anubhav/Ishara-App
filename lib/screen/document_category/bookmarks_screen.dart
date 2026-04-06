import 'package:docuhealth/screen/files/files_screen.dart';
import 'package:docuhealth/screen/document_category/share_document_dialog.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/image_preview_screen.dart';
import '../../components/pdf_preview.dart';
import '../../contstants/app_colors.dart';

class BookMarksScreen extends StatefulWidget {
  final String operationType;
  final int? fileId;
  final String documentType;
  final String appBarTitle;
  final String categoryName;
  const BookMarksScreen({
    super.key,
    this.fileId,
    required this.documentType,
    required this.appBarTitle,
    required this.categoryName,
    required this.operationType,
  });

  @override
  State<BookMarksScreen> createState() => _PharmacyRecordState();
}

class _PharmacyRecordState extends State<BookMarksScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  BaseClient baseClient = BaseClient();
  List listData = [];
  List folders = [];
  List files = [];
  bool isOpened = false;
  String searchKey = '';
  String sortBy = '';
  AnimationController? _animationController;
  // Animation<Color?>? _buttonColor;
  // Animation<double>? _animateIcon;
  // Animation<double>? _translateButton;
  // var dropDownValue;
  int currentPage = 1;
  int totalpage = 1;
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  TextEditingController nameController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  Future<dynamic> getData(BuildContext context, int currentPage) async {
    isLoading = true;
    setState(() {});
    final resp = await baseClient.get(
        'bookmark/get?sort_by=$sortBy&page=$currentPage&search=$searchKey',
        true);
    if (resp['success']) {
      if (resp["data"]["data_records"] != null) {
        double pageCount = resp["data"]["data_records"]['total_records'] /
            resp["data"]["data_records"]['limit'];

        totalpage = pageCount.ceil();
      }
      return resp['data']['data'];
    }
    isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    var data = await getData(context, currentPage);
    listData = data;
    if (mounted) setState(() {});
    refreshController.refreshCompleted();
  }

  void _onLoading() async {
    currentPage++;
    if (currentPage > totalpage) {
      refreshController.loadNoData();
    } else {
      var data = await getData(context, currentPage);
      for (var i = 0; i < data.length; i++) {
        if (data[i]['tag'] != 'folder') {
          listData.add(data[i]);
        }
      }
      if (mounted) setState(() {});
      refreshController.loadComplete();
    }
  }

  Future<bool> ondeleteFilePress(int id, buttonType) async {
    final resp = await baseClient.get("$buttonType/delete/$id", true);
    if (resp['success']) {
      if (mounted) getData(context, currentPage);
      Get.snackbar('Success', '${resp['message']}',
          backgroundColor: Colors.green);
      return true;
    } else {
      Get.snackbar('Failed', '${resp['message']}', backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> onRenamePress(int id, buttonType, nameController) async {
    var data = buttonType == "folder"
        ? {"folder_id": id.toString(), "name": nameController}
        : {
            "file_id": id.toString(),
            "name": nameController,
            'remarks': remarkController.text
          };
    final resp = await baseClient.post("$buttonType/rename", data, true);
    if (resp['success']) {
      if (mounted) getData(context, currentPage);
      return true;
    } else {
      Get.snackbar('Failed', resp['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  Future<bool> onPasteButtonPress() async {
    var data = widget.documentType == "folder"
        ? {"folder_id": "${widget.fileId}", "distination": widget.categoryName}
        : {"file_id": "${widget.fileId}", "distination": widget.categoryName};
    final response = await baseClient.post(
        '${widget.documentType}/${widget.operationType}', data, true);
    if (response['success']) {
      Get.snackbar('Success', response['message'],
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } else {
      Get.snackbar('Failed', response['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  Future<bool> onBookMarkButtonPress(int id, String operation, String documentType) async {
    final response = await baseClient.get(
        'bookmark/$operation?id=$id&type=$documentType', true);
    if (response['success']) {
      Get.snackbar('Success', response['message'],
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } else {
      Get.snackbar('Failed', response['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  void animate() {
    if (!isOpened) {
      _animationController!.forward();
    } else {
      _animationController!.reverse();
    }
    isOpened = !isOpened;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: AppColors.primaryColor,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 50.h),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: ((value) {
                      searchKey = value;
                      _onRefresh();
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
                            color: AppColors.selectedIconColor, width: 2.w),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: AppColors.whitebgColor,
                  ),
                  onSelected: (v) {
                    if (v == 1) {
                      sortBy = 'date';
                      _onRefresh();
                    } else if (v == 2) {
                      sortBy = 'name';
                      _onRefresh();
                    } else {
                      sortBy = '';
                      _onRefresh();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: 1,
                      child: Text('SORT BY DATE'),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('SORT BY NAME'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        title: Text(
          widget.appBarTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
      ),
      body: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        header: const WaterDropHeader(),
        controller: refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: listData.isEmpty
            ? const Center(
                child: Text(
                  "Data not found",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: listData.length,
                itemBuilder: (_, i) {
                  return Card(
                    color: AppColors.whitebgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ListTile(
                      onTap: () {
                        if (listData[i]['tag'] == "folder") {
                          Get.to(FilesScreen(
                            operationType: "",
                            redirectTo: "",
                            appBarTitle: listData[i]['name'],
                            folderId: listData[i]['id'],
                            fileId: widget.fileId,
                            categoryName: listData[i]['belongs_to'],
                            documentType: widget.documentType,
                          ));
                        } else if (listData[i]['file_type'] == "image") {
                          Get.to(ImagePreviewScreen(
                            imageUrl: listData[i]['file'],
                            fileId: listData[i]['id'],
                            fileName: listData[i]['name'] ?? '',
                            remarks: listData[i]['remarks'] ?? '',
                          ));
                        } else {
                          Get.to(PdfPreviewScreen(
                            isFromFile: false,
                            documentUrl: listData[i]['file'],
                            fileId: listData[i]['id'],
                            fileName: listData[i]['name'] ?? '',
                            remarks: listData[i]['remarks'] ?? '',
                            isNetworkImage: true,
                          ));
                        }
                      },
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15.h, horizontal: 5.w),
                      leading: Container(
                        height: 70.h,
                        width: 70.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          image: listData[i]['tag'] == "folder"
                              ? DecorationImage(
                                  image: AssetImage(widget.categoryName ==
                                          "DOCTOR_PRESCRIPTION"
                                      ? 'assets/images/person-image.png'
                                      : widget.categoryName == "HOSPITAL_BILLS"
                                          ? 'assets/icons/hospital-icon.png'
                                          : 'assets/icons/blood-pressure-file.png'),
                                )
                              : DecorationImage(
                                  image: NetworkImage(
                                      listData[i]['thumbnail_file']),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      title: Text(
                        listData[i]['name'],
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkGreyTextColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listData[i]['created_at'],
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          listData[i]['tag'] == "folder"
                              ? const SizedBox()
                              : Text(
                                  listData[i]['remarks'] ?? '',
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.lightGreyTextColor,
                                  ),
                                ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                if (listData[i]['tag'] == "folder") {
                                  if (listData[i]['bookmark'] == "No") {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                            listData[i]['folder_id'],
                                            'add',
                                            'folder'),
                                        message: const Text(
                                          'Please wait...',
                                        ),
                                      ),
                                    ).whenComplete(() => _onRefresh());
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                          listData[i]['folder_id'],
                                          'remove',
                                          'folder',
                                        ),
                                        message: const Text(
                                          'Please wait...',
                                        ),
                                      ),
                                    ).whenComplete(() => _onRefresh());
                                  }
                                } else {
                                  if (listData[i]['bookmark'] == "No") {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                            listData[i]['file_id'],
                                            'add',
                                            'file'),
                                        message: const Text(
                                          'Please wait...',
                                        ),
                                      ),
                                    ).whenComplete(() => _onRefresh());
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                          listData[i]['file_id'],
                                          'remove',
                                          'file',
                                        ),
                                        message: const Text(
                                          'Please wait...',
                                        ),
                                      ),
                                    ).whenComplete(() => _onRefresh());
                                  }
                                }
                              },
                              icon: listData[i]['bookmark'] == "No"
                                  ? const Icon(
                                      Icons.bookmark_outline,
                                    )
                                  : const Icon(
                                      Icons.bookmark,
                                    ),
                            ),
                            PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert,
                              ),
                              elevation: 2,
                              onSelected: (v) async {
                                if (listData[i]['tag'] == "folder") {
                                  if (v == 4) {
                                    Get.defaultDialog(
                                      title: "Warning !",
                                      middleText:
                                          "Are you sure you want to delete this file",
                                      confirm: SizedBox(
                                        height: 35.h,
                                        width: Get.width / 3,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  FutureProgressDialog(
                                                ondeleteFilePress(
                                                  listData[i]['folder_id'],
                                                  'folder',
                                                ),
                                                message: const Text(
                                                  'Please wait...',
                                                ),
                                              ),
                                            ).whenComplete(() => _onRefresh());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryColor,
                                          ),
                                          child: const Text('Yes'),
                                        ),
                                      ),
                                      cancel: SizedBox(
                                        height: 35.h,
                                        width: Get.width / 3,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey.shade400,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      radius: 10,
                                    );
                                  } else if (v == 5) {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20)),
                                      ),
                                      builder: (context) {
                                        return ShareDocumentDialog(
                                          itemID: listData[i]['folder_id'],
                                          itemType: 'folder',
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  if (v == 4) {
                                    Get.defaultDialog(
                                      title: "Warning !",
                                      middleText:
                                          "Are you sure you want to delete this file",
                                      confirm: SizedBox(
                                        height: 35.h,
                                        width: Get.width / 3,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  FutureProgressDialog(
                                                ondeleteFilePress(
                                                  listData[i]['file_id'],
                                                  'file',
                                                ),
                                                message: const Text(
                                                  'Please wait...',
                                                ),
                                              ),
                                            ).whenComplete(() => _onRefresh());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryColor,
                                          ),
                                          child: const Text('Yes'),
                                        ),
                                      ),
                                      cancel: SizedBox(
                                        height: 35.h,
                                        width: Get.width / 3,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey.shade400,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      radius: 10,
                                    );
                                  } else if (v == 5) {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20)),
                                      ),
                                      builder: (context) {
                                        return ShareDocumentDialog(
                                          itemID: listData[i]['file_id'],
                                          itemType: 'file',
                                        );
                                      },
                                    );
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry>[
                                const PopupMenuItem(
                                  value: 4,
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 5,
                                  child: Text('Share'),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
