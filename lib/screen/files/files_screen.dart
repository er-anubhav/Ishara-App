import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/image_preview_screen.dart';
import '../../components/pdf_preview.dart';
import '../../contstants/app_colors.dart';
import '../../main.dart';
import '../../services/base_client.dart';
import '../../theme.dart';
import '../document_category/my_documents.dart';
import '../document_category/share_document_dialog.dart';
import '../scanner/camera_screen.dart';

class FilesScreen extends StatefulWidget {
  final String operationType;
  final int? fileId;
  final String documentType;
  final String appBarTitle;
  final String categoryName;
  final String redirectTo;
  final int folderId;
  const FilesScreen(
      {Key? key,
      required this.appBarTitle,
      required this.categoryName,
      required this.documentType,
      required this.fileId,
      required this.operationType,
      required this.folderId,
      required this.redirectTo})
      : super(key: key);

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  BaseClient baseClient = BaseClient();
  List files = [];
  bool isOpened = false;
  String searchKey = '';
  String sortBy = '';
  AnimationController? _animationController;
  Animation<Color?>? _buttonColor;
  Animation<double>? _animateIcon;
  Animation<double>? _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;
  int currentPage = 1;
  int totalpage = 1;
  TextEditingController remarkController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  getData(context, currentPage) async {
    isLoading = true;
    setState(() {});
    final resp = await baseClient.get(
        'file/get?folder=${widget.folderId}&page=$currentPage&search=$searchKey',
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
    files = data;
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
          files.add(data[i]);
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
      floatingActionButton:
          widget.operationType == "copy" || widget.operationType == "move"
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
                              selectedFolder: widget.folderId,
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
        child: files.isEmpty
            ? const Center(
                child: Text("Nothing to show"),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: files.length,
                itemBuilder: (_, i) {
                  print(files);
                  return Card(
                    color: AppColors.whitebgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ListTile(
                      onTap: () {
                        if (files[i]['tag'] == "folder") {
                          Get.to(FilesScreen(
                            operationType: "",
                            redirectTo: widget.redirectTo,
                            appBarTitle: files[i]['name'],
                            folderId: files[i]['id'],
                            fileId: widget.fileId,
                            categoryName: files[i]['belongs_to'],
                            documentType: widget.documentType,
                          ));
                        } else if (files[i]['file_type'] == "image") {
                          Get.to(ImagePreviewScreen(
                            imageUrl: files[i]['file'],
                            fileId: files[i]['id'],
                            fileName: files[i]['name'] ?? '',
                            remarks: files[i]['remarks'] ?? '',
                          ));
                        } else {
                          Get.to(PdfPreviewScreen(
                            isFromFile: false,
                            documentUrl: files[i]['file'],
                            isNetworkImage: true,
                            fileId: files[i]['id'],
                            fileName: files[i]['name'] ?? '',
                            remarks: files[i]['remarks'] ?? '',
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
                          image: DecorationImage(
                            image: NetworkImage(files[i]['thumbnail_file']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        files[i]['name'],
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
                            files[i]['created_at'],
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
                          files[i]['tag'] == "folder"
                              ? const SizedBox()
                              : Text(
                                  files[i]['remarks'] ?? '',
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
                                if (files[i]['tag'] == "folder") {
                                  if (files[i]['bookmark'] == "No") {
                                    final resp = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                            files[i]['id'], 'add', 'folder'),
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
                                          files[i]['id'],
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
                                  if (files[i]['bookmark'] == "No") {
                                    final resp = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        onBookMarkButtonPress(
                                            files[i]['id'], 'add', 'file'),
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
                                          files[i]['id'],
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
                              icon: files[i]['bookmark'] == "No"
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
                                if (files[i]['tag'] == "folder") {
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
                                                  files[i]['id'],
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
                                    nameController.text = files[i]['name'];
                                    Get.defaultDialog(
                                      title: "Rename",
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: TextFormField(
                                          controller: nameController,
                                          decoration: AppTheme
                                              .defaultDescriptionInputFieldDecoration(
                                            "${files[i]['name']}",
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
                                                  files[i]['id'],
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
                                          itemID: files[i]['id'],
                                          itemType: 'folder',
                                        );
                                      },
                                    );
                                  } else if (v == 1) {
                                    Get.to(
                                      MyDocumnets(
                                        operationType: 'copy',
                                        fileId: files[i]['id'],
                                        documentType: 'folder',
                                      ),
                                    );
                                  } else if (v == 3) {
                                    Get.to(
                                      MyDocumnets(
                                        operationType: 'move',
                                        fileId: files[i]['id'],
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
                                                  files[i]['id'],
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
                                    nameController.text = files[i]['name'];
                                    remarkController.text =
                                        files[i]['remarks'] ?? '';
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
                                                "${files[i]['name'] ?? 'File name'}",
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
                                                "${files[i]['remarks'] ?? 'Remarks'}",
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
                                                  files[i]['id'],
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
                                          itemID: files[i]['id'],
                                          itemType: 'file',
                                        );
                                      },
                                    );
                                  } else if (v == 1) {
                                    Get.to(MyDocumnets(
                                      operationType: 'copy',
                                      fileId: files[i]['id'],
                                      documentType: 'file',
                                    ));
                                  } else if (v == 3) {
                                    Get.to(MyDocumnets(
                                      operationType: 'move',
                                      fileId: files[i]['id'],
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
