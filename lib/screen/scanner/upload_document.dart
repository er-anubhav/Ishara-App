import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:docuhealth/components/default_button.dart';
import 'package:docuhealth/screen/folders/create_folder_dialog.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:docuhealth/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../contstants/app_colors.dart';

class UploadDcoumnetScreen extends StatefulWidget {
  final List<XFile> uploadIMages;
  final String selectedCategory;
  final String appBarTitle;
  final String redirectTo;
  final int? selectedFolder;
  const UploadDcoumnetScreen(
      {super.key,
      required this.uploadIMages,
      required this.selectedCategory,
      required this.appBarTitle,
      required this.selectedFolder,
      required this.redirectTo});

  @override
  State<UploadDcoumnetScreen> createState() => _UploadDcoumnetScreenState();
}

class _UploadDcoumnetScreenState extends State<UploadDcoumnetScreen> {
  BaseClient baseClient = BaseClient();
  TextEditingController remarksController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  String inputHintText = "";
  String? dropdownvalue;
  var items = [];
  List<String> uploadedImagesPath = [];

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
    debugPrint(widget.selectedCategory);
    final response = await baseClient.get(
        'folder/get?category=${widget.selectedCategory}', true);

    if (response['success']) {
      items = response['data'];
      setState(() {});
    }
  }

  Future<bool> onUploadDocumentPress() async {
    for (var i = 0; i < widget.uploadIMages.length; i++) {
      final response = await baseClient.uploadDocument(
          'file/uploader', '', widget.uploadIMages[i].path, true);
      debugPrint(response);
      var respData = jsonDecode(response);
      if (respData['success']) {
        uploadedImagesPath.add(respData['data'][0]['file_name'].toString());
      }
    }
    Timer(
      const Duration(seconds: 2),
      () {},
    );
    var data = {
      "files_name": uploadedImagesPath.join(','),
      "files_rename": fileNameController.text,
      "destination": dropdownvalue ?? widget.selectedCategory,
      "remarks": remarksController.text
    };
    final response = await baseClient.post('file', data, true);
    if (response['success']) {
      return true;
    } else {
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        childAspectRatio: 3 / 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 150,
                      ),
                      itemCount: widget.uploadIMages.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(
                                File(
                                  widget.uploadIMages[index].path,
                                ),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }),
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
            debugPrint('$resp');
            if (resp) {
              Get.snackbar(
                'Success',
                'Uploaded successfully!',
              );
              widget.redirectTo == ""
                  ? Get.offAllNamed('/Dashboard')
                  : Get.offNamedUntil(widget.redirectTo, (route) => false);
            }
          },
        ),
      ),
    );
  }
}
