import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:docuhealth/components/pdf_preview.dart';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import '../../components/default_button.dart';
import '../../contstants/app_colors.dart';
import '../../services/base_client.dart';
import '../../theme.dart';
import '../folders/create_folder_dialog.dart';

class UploadPdf extends StatefulWidget {
  final File upload;
  final String? selectedCategory;
  final String? appBarTitle;
  final String? redirectTo;
  final int? selectedFolder;
  const UploadPdf(
      {super.key,
      required this.appBarTitle,
      this.redirectTo,
      this.selectedCategory,
      this.selectedFolder,
      required this.upload});

  @override
  State<UploadPdf> createState() => _UploadPdfState();
}

class _UploadPdfState extends State<UploadPdf> {
  BaseClient baseClient = BaseClient();
  static const String _localUploadsKey = 'local_uploaded_documents';
  TextEditingController remarksController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();

  String inputHintText = "";
  String? dropdownvalue;
  var items = [];
  List<String> uploadedImagesPath = [];
  bool _lastUploadWasLocal = false;

  Future<void> getFolderCategoryType() async {
    switch (widget.selectedCategory) {
      case "TEST_REPORTS":
        inputHintText = "Select report";
        break;
      case "DOCTOR_PRESCRIPTION":
        inputHintText = "Select Doctor";
        break;
      case "DAILY_MEASUREMENTS":
        inputHintText = "Select Measurements";
        break;
      case "HOSPITAL_BILLS":
        inputHintText = "Select Hospital";
        break;
      case "PHARMACY_RECORDS":
        inputHintText = "Select Pharmacy";
        break;
      default:
    }
  }

  Future<void> getFolderList() async {
    final response = await baseClient.get(
        'folder/get?category=${widget.selectedCategory}', true);

    if (response['success']) {
      items = response['data'];
      setState(() {});
    }
  }

  Future<bool> onUploadDocumentPress() async {
    uploadedImagesPath = [];
    _lastUploadWasLocal = false;

    try {
      final response = await baseClient.uploadDocument(
        'file/uploader',
        '',
        widget.upload.path,
        true,
      );

      dynamic respData;
      if (response is String && response.isNotEmpty) {
        respData = jsonDecode(response);
      } else if (response is Map) {
        respData = response;
      } else {
        respData = null;
      }

      final uploadSuccess = respData is Map &&
          respData['success'] == true &&
          respData['data'] is List;

      if (uploadSuccess) {
        final fileName = ((respData['data'] as List).isNotEmpty
                ? respData['data'][0]['file_name']
                : null)
            ?.toString();
        if (fileName != null && fileName.isNotEmpty) {
          uploadedImagesPath.add(fileName);
        }
      } else {
        return _saveUploadLocally();
      }

      var data = {
        "files_name": uploadedImagesPath.join(','),
        "files_rename": fileNameController.text,
        "destination": dropdownvalue ?? widget.selectedCategory ?? 'DOCUMENTS',
        "remarks": remarksController.text
      };

      final apiresponse = await baseClient.post('file', data, true);
      final postSuccess = apiresponse is Map && apiresponse['success'] == true;
      if (postSuccess) {
        return true;
      }

      return _saveUploadLocally();
    } catch (_) {
      return _saveUploadLocally();
    }
  }

  bool _saveUploadLocally() {
    try {
      final existing = (box.read(_localUploadsKey) as List?) ?? <dynamic>[];
      final localRecord = <String, dynamic>{
        'id': DateTime.now().millisecondsSinceEpoch,
        'category': widget.selectedCategory ?? 'DOCUMENTS',
        'title': fileNameController.text.trim().isEmpty
            ? 'Local PDF Document'
            : fileNameController.text.trim(),
        'remarks': remarksController.text.trim(),
        'destination': dropdownvalue ?? widget.selectedCategory ?? 'DOCUMENTS',
        'files': <String>[widget.upload.path],
        'created_at': DateTime.now().toIso8601String(),
        'sync_status': 'local_only',
      };

      final merged = <dynamic>[localRecord, ...existing];
      box.write(_localUploadsKey, merged);
      _lastUploadWasLocal = true;
      return true;
    } catch (_) {
      _lastUploadWasLocal = false;
      return false;
    }
  }

  @override
  void initState() {
    getFolderCategoryType();
    if (widget.selectedFolder != null) {
      dropdownvalue = widget.selectedFolder.toString();
    }
    getFolderList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Upload Documents"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          Get.to(PdfPreviewScreen(
                            documentUrl: widget.upload,
                            isFromFile: true,
                            isNetworkImage: false,
                          ));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 10.h),
                          height: 160.h,
                          width: 145.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(
                                color: AppColors.primaryColor,
                              )),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.grey.shade100,
                                ),
                                child: Center(
                                  child: ClipRRect(
                                    child: Icon(
                                      Icons.picture_as_pdf,
                                      size: 100.r,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  height: 50.h,
                                  width: 145.w,
                                  padding:
                                      EdgeInsets.only(left: 15.w, right: 10.w),
                                  decoration: BoxDecoration(
                                      color: AppColors.whitebgColor,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.r),
                                          bottomRight: Radius.circular(10.r))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/icons/document-icon.png',
                                            height: 15.h,
                                            width: 15.w,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          SizedBox(
                                            width: 100.w,
                                            child: Text(
                                              widget.upload.path,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColors.greyTextColor),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Text(
                                        "${DateTime.now()}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.lightGreyTextColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                widget.selectedFolder != null
                    ? const SizedBox()
                    : items.isEmpty
                        ? SizedBox(
                            height: 50.h,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
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
                                      categoryName: widget.selectedCategory,
                                    );
                                  },
                                ).whenComplete(() => getFolderList());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                              ),
                              icon: const Icon(Icons.add),
                              label: Text(
                                "New",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField(
                                  decoration:
                                      AppTheme.defaultInputFieldDecoration(
                                    widget.selectedCategory ==
                                            "DOCTOR_PRESCRIPTION"
                                        ? "Select Doctor"
                                        : "Select Folder",
                                    widget.selectedCategory ==
                                            "DOCTOR_PRESCRIPTION"
                                        ? Icons.person
                                        : Icons.folder,
                                  ),
                                  initialValue: dropdownvalue,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: items.map((items) {
                                    return DropdownMenuItem(
                                      value: items['id'],
                                      child: Text(items['name']!),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    dropdownvalue = newValue.toString();
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              SizedBox(
                                height: 50.h,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
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
                                          categoryName: widget.selectedCategory,
                                        );
                                      },
                                    ).whenComplete(() => getFolderList());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    "New",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "File name",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyTextColor,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                TextFormField(
                  controller: fileNameController,
                  maxLines: 1,
                  decoration: AppTheme.defaultDescriptionInputFieldDecoration(
                      "Enter filename", null),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "Remarks",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyTextColor,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                TextFormField(
                  controller: remarksController,
                  maxLines: 5,
                  decoration: AppTheme.defaultDescriptionInputFieldDecoration(
                      "Remarks", null),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        width: double.infinity,
        child: DefaultButton(
          buttonText: "Upload Document",
          onPress: () async {
            final resp = await showDialog(
              context: context,
              builder: (context) => FutureProgressDialog(
                onUploadDocumentPress(),
                message: const Text('Uploading...'),
              ),
            );
            debugPrint(resp.toString());
            if (resp == true) {
              Get.snackbar(
                _lastUploadWasLocal ? 'Saved Locally' : 'Success',
                _lastUploadWasLocal
                    ? 'Network issue detected. PDF saved locally.'
                    : 'Uploaded successfully!',
              );
              widget.redirectTo == ""
                  ? Get.offAllNamed('/Dashboard')
                  : Get.offNamedUntil(widget.redirectTo!, (route) => false);
            } else {
              Get.snackbar(
                'Upload Failed',
                'Could not upload or save locally. Please try again.',
              );
            }
          },
        ),
      ),
    );
  }
}
