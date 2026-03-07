import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:docuhealth/screen/scanner/upload_pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../main.dart';
import 'image_preview_edit_screen.dart';

class CameraScreen extends StatefulWidget {
  final String appBarTitle;
  final String? selectedCategory;
  final String? redirectTo;
  final int? selectedFolder;
  const CameraScreen(
      {super.key,
      required this.appBarTitle,
      this.redirectTo,
      this.selectedCategory,
      this.selectedFolder});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<XFile> images = [];
  File? _imageFile;
  bool _isRearCameraSelected = true;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _controller;
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController.dispose();

    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  CameraPreview(_controller),
                  Expanded(
                      child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              onNewCameraSelected(
                                  cameras[_isRearCameraSelected ? 1 : 0]);
                              setState(() {
                                _isRearCameraSelected = !_isRearCameraSelected;
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.black38,
                                  size: 60,
                                ),
                                Icon(
                                  _isRearCameraSelected
                                      ? Icons.camera_front
                                      : Icons.camera_rear,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              XFile rawImage = await _controller.takePicture();

                              File? imageFile = File(rawImage.path);

                              // int currentUnix =
                              //     DateTime.now().millisecondsSinceEpoch;

                              // final directory =
                              //     await getApplicationDocumentsDirectory();

                              // String fileFormat =
                              //     imageFile.path.split('.').last;

                              // print(fileFormat);

                              // await imageFile.copy(
                              //   '${directory.path}/$currentUnix.$fileFormat',
                              // );

                              // print(imageFile.path);
                              // images.insert(0, XFile(imageFile.path));
                              images.add(XFile(imageFile.path));
                              if (!mounted) return;

                              Get.to(ImagePreviewEditScreen(
                                categoryName: widget.selectedCategory,
                                images: images,
                                redirectTo: widget.redirectTo ?? "",
                                selectedFolder: widget.selectedFolder,
                              ));
                            },
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 80,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowMultiple: true,
                                allowedExtensions: ['jpg', 'pdf', 'png'],
                              );
                              if (result != null) {
                                images.addAll(result.paths
                                    .map((path) => XFile(path!))
                                    .toList());
                              }
                              for (var i = 0; i < images.length; i++) {
                                if (images[i].path.split('.').last == "pdf") {
                                  Get.to(
                                    UploadPdf(
                                      appBarTitle: "Upload document",
                                      redirectTo: widget.redirectTo ?? '',
                                      selectedCategory: widget.selectedCategory,
                                      selectedFolder: widget.selectedFolder,
                                      upload: File(images.first.path),
                                    ),
                                  );
                                } else {
                                  Get.to(ImagePreviewEditScreen(
                                    categoryName: widget.selectedCategory,
                                    images: images,
                                    redirectTo: widget.redirectTo ?? '',
                                    selectedFolder: widget.selectedFolder,
                                  ));
                                }
                              }
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                image: _imageFile != null
                                    ? DecorationImage(
                                        image: FileImage(_imageFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
