import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/screen/scanner/upload_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../screen/document_category/my_documents.dart';
import '../screen/document_category/share_document_dialog.dart';
import '../screen/scanner/select_folder_category.dart';
import '../services/base_client.dart';
import '../theme.dart';

class PdfPreviewScreen extends StatefulWidget {
  final dynamic documentUrl;
  final int? fileId;
  final String? fileName;
  final String? selectedCategory;
  final String? remarks;
  final bool isFromFile;
  final bool isNetworkImage;
  final int? selectedFolder;
  const PdfPreviewScreen({
    super.key,
    required this.documentUrl,
    required this.isFromFile,
    required this.isNetworkImage,
    this.fileName,
    this.remarks,
    this.fileId,
    this.selectedFolder,
    this.selectedCategory,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  TextEditingController nameController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  BaseClient baseClient = BaseClient();

  Future<bool> ondeleteFilePress(int id, buttonType) async {
    final resp = await baseClient.get("$buttonType/delete/$id", true);
    if (resp['success']) {
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
      return true;
    } else {
      Get.snackbar('Failed', resp['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
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
        title: const Text('Document Preview'),
        actions: [
          !widget.isFromFile || widget.isNetworkImage
              ? PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                  elevation: 2,
                  onSelected: (v) async {
                    if (v == 4) {
                      Get.defaultDialog(
                        title: "Warning !",
                        middleText: "Are you sure you want to delete this file",
                        confirm: SizedBox(
                          height: 35.h,
                          width: Get.width / 3,
                          child: ElevatedButton(
                            onPressed: () async {
                              Get.back();
                              await showDialog(
                                context: context,
                                builder: (context) => FutureProgressDialog(
                                  ondeleteFilePress(
                                    widget.fileId!,
                                    'file',
                                  ),
                                  message: const Text(
                                    'Please wait...',
                                  ),
                                ),
                              ).whenComplete(() => Get.back());
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
                    } else if (v == 2) {
                      nameController.text = widget.fileName!;
                      remarkController.text = widget.remarks!;
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
                                  widget.fileName,
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
                                  widget.remarks,
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
                                builder: (context) => FutureProgressDialog(
                                  onRenamePress(
                                    widget.fileId!,
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
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
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
                            itemID: widget.fileId!,
                            itemType: 'file',
                          );
                        },
                      );
                    } else if (v == 1) {
                      Get.to(MyDocumnets(
                        operationType: 'copy',
                        fileId: widget.fileId,
                        documentType: 'file',
                      ));
                    } else if (v == 3) {
                      Get.to(MyDocumnets(
                        operationType: 'move',
                        fileId: widget.fileId,
                        documentType: 'file',
                      ));
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
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
                )
              : ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                  onPressed: () {
                    Get.to(widget.selectedCategory == null
                        ? SelectFolderCategory(
                            images: widget.documentUrl,
                            selectedFolder: widget.selectedFolder,
                            ispdf: true,
                          )
                        : Get.to(UploadPdf(
                            upload: widget.documentUrl,
                            appBarTitle: "Upload Documents",
                            redirectTo: "",
                            selectedCategory: widget.selectedCategory ?? '',
                            selectedFolder: widget.selectedFolder,
                          )));
                  },
                  child: const Text("Save"),
                )
        ],
        backgroundColor: AppColors.primaryColor,
      ),
      body: widget.isFromFile && !widget.isNetworkImage
          ? SfPdfViewer.file(
              widget.documentUrl,
              key: _pdfViewerKey,
            )
          : SfPdfViewer.network(
              widget.documentUrl,
              key: _pdfViewerKey,
            ),
    );
  }
}
