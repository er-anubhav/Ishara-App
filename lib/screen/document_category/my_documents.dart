import 'package:docuhealth/screen/document_category/share_document_dialog.dart';
import 'package:docuhealth/screen/document_category/test_reports.dart';
import 'package:docuhealth/screen/files/files_screen.dart';
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
import '../../theme.dart';
import '../folders/create_folder_dialog.dart';
import '../scanner/camera_screen.dart';

class MyDocumnets extends StatefulWidget {
  final String operationType;
  final String documentType;
  final int? fileId;

  const MyDocumnets(
      {super.key,
      required this.operationType,
      this.fileId,
      required this.documentType});

  @override
  State<MyDocumnets> createState() => _MyDocumnetsState();
}

class _MyDocumnetsState extends State<MyDocumnets>
    with SingleTickerProviderStateMixin {
  BaseClient baseClient = BaseClient();
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);
  TextEditingController nameController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  AnimationController? _animationController;
  Animation<Color?>? _buttonColor;
  Animation<double>? _animateIcon;
  Animation<double>? _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;
  bool isLoading = true;
  bool isOpened = false;
  int currentPage = 1;
  int totalpage = 1;
  String searchKey = '';
  String sortBy = '';
  List listData = [];

  Future<List<dynamic>> getData(int currentPage) async {
    isLoading = true;
    if (mounted) {
      setState(() {});
    }

    try {
      final resp = await baseClient.get(
          'my-documents?sort_by=$sortBy&page=$currentPage&search=$searchKey',
          true);

      if (resp['success']) {
        if (resp["data"]["data_records"] != null) {
          double pageCount = resp["data"]["data_records"]['total_records'] /
              resp["data"]["data_records"]['limit'];

          totalpage = pageCount.ceil();
        }
        return (resp['data']['data'] as List?)?.cast<dynamic>() ?? <dynamic>[];
      }

      if (resp['message'] != null) {
        Get.snackbar('Failed', '${resp['message']}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      return <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    } finally {
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _onRefresh() async {
    currentPage = 1;
    var data = await getData(currentPage);
    listData = data;
    if (mounted) setState(() {});
    refreshController.refreshCompleted();
  }

  void _onLoading() async {
    currentPage++;
    if (currentPage > totalpage) {
      refreshController.loadNoData();
    } else {
      var data = await getData(currentPage);
      for (var i = 0; i < data.length; i++) {
        if (data[i]['tag'] != 'folder' && data[i]['tag'] != 'category') {
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
      getData(currentPage);
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
      getData(currentPage);
      return true;
    } else {
      Get.snackbar('Failed', resp['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  Future<bool> onPasteButtonPress() async {
    var data = widget.documentType == "folder"
        ? {"folder_id": "${widget.fileId}", "distination": ""}
        : {"file_id": "${widget.fileId}", "distination": ""};
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

  Future<bool> onBookMarkButtonPress(
      int id, String operation, String documentType) async {
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

  String getCategoryImage(String categoryType) {
    switch (categoryType) {
      case "TEST_REPORTS":
        return "assets/images/lab-report.png";
      case "DOCTOR_PRESCRIPTION":
        return "assets/images/doctor-icon.png";
      case "HOSPITAL_BILLS":
        return "assets/images/hospital-icon.png";
      case "PHARMACY_RECORDS":
        return "assets/images/pharmacy-icon.png";
      case "REMAINDERS":
        return "assets/images/remainder-icon.png";
      case "GENERAL_DOCS":
        return "assets/images/folder.png";
      case "DAILY_MEASUREMENTS":
        return "assets/images/daily-measurements.png";
      default:
        return "assets/images/paper-icon.png";
    }
  }

  String getRoute(String categoryType) {
    switch (categoryType) {
      case "TEST_REPORTS":
        return "/Test_Reports";
      case "DOCTOR_PRESCRIPTION":
        return "/Doctor_Prescription";
      case "HOSPITAL_BILLS":
        return "/Hospital_Management";
      case "PHARMACY_RECORDS":
        return "/Pharmacy_Record";
      case "GENERAL_DOCS":
        return "/Genral_Documents";
      default:
        return "/Test_Reports";
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _buttonColor = ColorTween(
      begin: Colors.green,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(
        0.0,
        0.5,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    getData(currentPage);
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
          "My documents",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
      ),
      floatingActionButton: widget.operationType != ''
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.paste),
              label: const Text('Paste'),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => FutureProgressDialog(
                      onPasteButtonPress(),
                      message: const Text('Please wait...')),
                ).whenComplete(() => getData(currentPage));
              },
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Transform(
                  transform: Matrix4.translationValues(
                    0.0,
                    _translateButton!.value * 2.0,
                    0.0,
                  ),
                  child: FloatingActionButton(
                    heroTag: "btn1",
                    onPressed: () async {
                      animate();
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return const CreateFolderDialog(
                            categoryName: "My documents",
                          );
                        },
                      ).whenComplete(() => getData(currentPage));
                    },
                    backgroundColor: Colors.white,
                    tooltip: 'Create new folder',
                    child: const Text('Folder',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Transform(
                  transform: Matrix4.translationValues(
                    0.0,
                    _translateButton!.value,
                    0.0,
                  ),
                  child: FloatingActionButton(
                    heroTag: "btn2",
                    onPressed: () {
                      animate();
                      Get.to(const CameraScreen(
                        selectedCategory: "My documents",
                        appBarTitle: '',
                      ));
                    },
                    backgroundColor: Colors.white,
                    tooltip: 'Scan Document',
                    child: const Text(
                      'Scan',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                FloatingActionButton(
                  heroTag: "btn3",
                  backgroundColor: _buttonColor!.value,
                  onPressed: animate,
                  tooltip: 'Toggle',
                  child: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animateIcon!,
                  ),
                ),
              ],
            ),
      body: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        header: const WaterDropHeader(),
        controller: refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
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
                      redirectTo: "",
                      appBarTitle: listData[i]['name'],
                      folderId: listData[i]['id'],
                      fileId: widget.fileId,
                      categoryName: listData[i]['belongs_to'],
                      documentType: listData[i]['tag'],
                      operationType: widget.operationType,
                    ));
                  } else if (listData[i]['tag'] == "category") {
                    Get.to(
                      TestReports(
                        documentType: widget.operationType != ''
                            ? widget.documentType
                            : listData[i]['value'],
                        appBarTitle: listData[i]['name'],
                        categoryName: listData[i]['value'],
                        fileId: widget.fileId,
                        operationType: widget.operationType,
                        redirectTo: getRoute(
                          listData[i]['value'],
                        ),
                      ),
                    );
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
                      fileName: listData[i]['name'],
                      remarks: listData[i]['remarks'],
                      isNetworkImage: true,
                    ));
                  }
                },
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.h, horizontal: 5.w),
                leading: Container(
                  height: 60.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryLinearGradient,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: listData[i]['tag'] == "category"
                      ? Image.asset(
                          getCategoryImage(listData[i]['value']),
                          color: AppColors.primaryColor,
                          fit: BoxFit.fill,
                        )
                      : listData[i]['tag'] == "folder"
                          ? Image.asset(
                              'assets/icons/blood-pressure-file.png',
                              fit: BoxFit.cover,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.network(
                                listData[i]['thumbnail_file'],
                                fit: BoxFit.cover,
                              ),
                            ),
                ),
                title: Text(
                  listData[i]['name'] ?? '',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGreyTextColor,
                  ),
                ),
                subtitle: Text(
                  listData[i]['created_at'] ?? '',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryColor,
                  ),
                ),
                trailing: listData[i]['tag'] == "category"
                    ? const SizedBox()
                    : SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                if (listData[i]['bookmark'] == "No") {
                                  final resp = await showDialog(
                                    context: context,
                                    builder: (context) => FutureProgressDialog(
                                      onBookMarkButtonPress(
                                          listData[i]['id'], 'add', 'folder'),
                                      message: const Text(
                                        'Please wait...',
                                      ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  if (resp) {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        getData(currentPage),
                                        message: const Text(
                                          'Please wait...',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  final resp = await showDialog(
                                    context: context,
                                    builder: (context) => FutureProgressDialog(
                                      onBookMarkButtonPress(
                                        listData[i]['id'],
                                        'remove',
                                        'folder',
                                      ),
                                      message: const Text(
                                        'Please wait...',
                                      ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  if (resp) {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        getData(currentPage),
                                        message: const Text(
                                          'Please wait...',
                                        ),
                                      ),
                                    );
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
                                                  listData[i]['id'],
                                                  'folder',
                                                ),
                                                message: const Text(
                                                  'Please wait...',
                                                ),
                                              ),
                                            ).whenComplete(() => _onRefresh());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryColor,
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
                                            backgroundColor:
                                                Colors.grey.shade400,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      radius: 10,
                                    );
                                  } else if (v == 2) {
                                    nameController.text = listData[i]['name'];
                                    Get.defaultDialog(
                                      title: "Rename",
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: TextFormField(
                                          controller: nameController,
                                          decoration: AppTheme
                                              .defaultDescriptionInputFieldDecoration(
                                            "${listData[i]['name']}",
                                            Icons.folder,
                                          ),
                                        ),
                                      ),
                                      confirm: SizedBox(
                                        height: 35.h,
                                        width: Get.width / 3,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final resp = await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  FutureProgressDialog(
                                                onRenamePress(
                                                  listData[i]['id'],
                                                  'folder',
                                                  nameController.text,
                                                ),
                                                message: const Text(
                                                  'Please wait...',
                                                ),
                                              ),
                                            );
                                            if (resp) {
                                              nameController.clear();
                                              Get.back();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryColor,
                                          ),
                                          child: const Text('Continue'),
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
                                            backgroundColor:
                                                Colors.grey.shade400,
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
                                          itemID: listData[i]['id'],
                                          itemType: 'folder',
                                        );
                                      },
                                    );
                                  } else if (v == 1) {
                                    Get.to(
                                      MyDocumnets(
                                        operationType: 'copy',
                                        fileId: listData[i]['id'],
                                        documentType: 'folder',
                                      ),
                                    );
                                  } else if (v == 3) {
                                    Get.to(
                                      MyDocumnets(
                                        operationType: 'move',
                                        fileId: listData[i]['id'],
                                        documentType: 'folder',
                                      ),
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
                                                  listData[i]['id'],
                                                  'file',
                                                ),
                                                message: const Text(
                                                  'Please wait...',
                                                ),
                                              ),
                                            ).whenComplete(() => _onRefresh());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryColor,
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
                                            backgroundColor:
                                                Colors.grey.shade400,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      radius: 10,
                                    );
                                  } else if (v == 2) {
                                    nameController.text = listData[i]['name'];
                                    remarkController.text =
                                        listData[i]['remarks'] ?? '';
                                    Get.defaultDialog(
                                      title: "Rename",
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: nameController,
                                              decoration: AppTheme
                                                  .defaultDescriptionInputFieldDecoration(
                                                "${listData[i]['name'] ?? 'File name'}",
                                                Icons.folder,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            TextFormField(
                                              controller: remarkController,
                                              decoration: AppTheme
                                                  .defaultDescriptionInputFieldDecoration(
                                                "${listData[i]['remarks'] ?? 'Remarks'}",
                                                Icons.folder,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      confirm: SizedBox(
                                        height: 35.h,
                                        width: Get.width / 3,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            final resp = await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  FutureProgressDialog(
                                                onRenamePress(
                                                  listData[i]['id'],
                                                  'file',
                                                  nameController.text,
                                                ),
                                                message: const Text(
                                                  'Please wait...',
                                                ),
                                              ),
                                            );
                                            if (resp) {
                                              nameController.clear();
                                              _onRefresh();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryColor,
                                          ),
                                          child: const Text('Continue'),
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
                                            backgroundColor:
                                                Colors.grey.shade400,
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
                                          itemID: listData[i]['id'],
                                          itemType: 'file',
                                        );
                                      },
                                    );
                                  } else if (v == 1) {
                                    Get.to(MyDocumnets(
                                      operationType: 'copy',
                                      fileId: listData[i]['id'],
                                      documentType: 'file',
                                    ));
                                  } else if (v == 3) {
                                    Get.to(MyDocumnets(
                                      operationType: 'move',
                                      fileId: listData[i]['id'],
                                      documentType: 'file',
                                    ));
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry>[
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text('Copy'),
                                ),
                                const PopupMenuItem(
                                  value: 4,
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 3,
                                  child: Text('Move'),
                                ),
                                const PopupMenuItem(
                                  value: 2,
                                  child: Text('Rename'),
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
