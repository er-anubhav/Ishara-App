import 'package:docuhealth/screen/document_category/my_documents.dart';
import 'package:docuhealth/screen/files/files_screen.dart';
import 'package:docuhealth/screen/document_category/share_document_dialog.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:docuhealth/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/image_preview_screen.dart';
import '../../components/pdf_preview.dart';
import '../../contstants/app_colors.dart';
import '../home_screen.dart';
import '../scanner/camera_screen.dart';
import '../folders/create_folder_dialog.dart';

class TestReports extends StatefulWidget {
  final String operationType;
  final int? fileId;
  final String documentType;
  final String appBarTitle;
  final String categoryName;
  final String redirectTo;
  const TestReports(
      {Key? key,
      this.fileId,
      required this.documentType,
      required this.appBarTitle,
      required this.categoryName,
      required this.operationType,
      required this.redirectTo})
      : super(key: key);

  @override
  State<TestReports> createState() => _PharmacyRecordState();
}

class _PharmacyRecordState extends State<TestReports>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  BaseClient baseClient = BaseClient();
  List listData = [];
  bool isOpened = false;
  String searchKey = '';
  String sortBy = '';
  AnimationController? _animationController;
  Animation<Color?>? _buttonColor;
  Animation<double>? _animateIcon;
  Animation<double>? _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;
  var dropDownValue;
  int currentPage = 1;
  int totalpage = 1;
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  TextEditingController nameController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  getData(context, currentPage) async {
    isLoading = true;
    setState(() {});
    final resp = await baseClient.get(
        'folders-and-files?category=${widget.categoryName}&sort_by=$sortBy?page=$currentPage&search=$searchKey',
        true);
    print(resp["data"]["data_records"]);
    if (resp['success']) {
      if (resp["data"]["data_records"] != null) {
        double pageCount = resp["data"]["data_records"]['total_records'] /
            resp["data"]["data_records"]['limit'];

        totalpage = pageCount.ceil();
      }
      return resp['data']['data'];
    }
    isLoading = false;
    setState(() {});
  }

  _onRefresh() async {
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
      getData(context, currentPage);
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
      getData(context, currentPage);
      return true;
    } else {
      Get.snackbar('Failed', resp['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  onPasteButtonPress() async {
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

  onBookMarkButtonPress(int id, String operation, String documentType) async {
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

  @override
  void initState() {
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
    super.initState();
  }

  animate() {
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
        leading: IconButton(
          onPressed: () {
            Get.offAll(const HomePage(currentIndex: 1));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
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
          preferredSize: Size(double.infinity, 50.h),
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
      floatingActionButton: widget.operationType == "copy" ||
              widget.operationType == "move"
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
                ).whenComplete(() => _onRefresh());
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
                          return CreateFolderDialog(
                            categoryName: widget.categoryName,
                            isShowDropdown: false,
                          );
                        },
                      ).whenComplete(() => _onRefresh());
                    },
                    backgroundColor: Colors.white,
                    tooltip: widget.categoryName == "DOCTOR_PRESCRIPTION"
                        ? 'Create new Doctor'
                        : widget.categoryName == "HOSPITAL_BILLS"
                            ? 'Create new Hospital'
                            : 'Create new Folder',
                    child: SizedBox(
                      height: 40.h,
                      width: 40.w,
                      child: widget.categoryName == "DOCTOR_PRESCRIPTION"
                          ? Image.asset('assets/images/person-image.png')
                          : widget.categoryName == "HOSPITAL_BILLS"
                              ? Image.asset('assets/icons/hospital-icon.png')
                              : Icon(
                                  Icons.folder,
                                  color: AppColors.darkGreyTextColor,
                                ),
                    ),
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
                        Get.to(CameraScreen(
                          selectedCategory: widget.categoryName,
                          appBarTitle: widget.appBarTitle,
                          redirectTo: widget.redirectTo,
                        ));
                      },
                      backgroundColor: Colors.white,
                      tooltip: 'Scan Document',
                      child: Icon(
                        Icons.document_scanner,
                        color: AppColors.darkGreyTextColor,
                      )),
                ),
                FloatingActionButton(
                  heroTag: "btn3",
                  backgroundColor: _buttonColor!.value,
                  onPressed: animate,
                  tooltip: 'Toggle',
                  child: Icon(
                    Icons.add,
                    size: 30.r,
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
        child: listData.isEmpty
            ? const Center(
                child: Text("Nothing to show"),
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
                            operationType: widget.operationType,
                            redirectTo: widget.redirectTo,
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
                            maxLines: 2,
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
                                    final resp = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                            listData[i]['id'], 'add', 'folder'),
                                        message: const Text(
                                          'Please wait...',
                                        ),
                                      ),
                                    ).whenComplete(() => _onRefresh());
                                  } else {
                                    final resp = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                          listData[i]['id'],
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
                                    final resp = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                            listData[i]['id'], 'add', 'file'),
                                        message: const Text(
                                          'Please wait...',
                                        ),
                                      ),
                                    ).whenComplete(() => _onRefresh());
                                  } else {
                                    final resp = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                          listData[i]['id'],
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
                                            primary: AppColors.primaryColor,
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
                                            primary: Colors.grey.shade400,
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
                                            const Icon(Icons.folder),
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
                                            primary: AppColors.primaryColor,
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
                                            primary: Colors.grey.shade400,
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
                                            primary: AppColors.primaryColor,
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
                                            primary: Colors.grey.shade400,
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
                                                const Icon(Icons.folder),
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
                                                const Icon(Icons.folder),
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
                                            primary: AppColors.primaryColor,
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
                                            primary: Colors.grey.shade400,
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
                              itemBuilder: (BuildContext context) => listData[i]
                                          ['tag'] ==
                                      "folder"
                                  ? <PopupMenuEntry>[
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
                                    ]
                                  : <PopupMenuEntry>[
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
