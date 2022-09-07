import 'dart:io';
import 'dart:typed_data';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/screen/scanner/camera_screen.dart';
import 'package:docuhealth/screen/scanner/select_folder_category.dart';
import 'package:docuhealth/screen/scanner/upload_document.dart';
import 'package:docuhealth/utils/create_pdf.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:path_provider/path_provider.dart';
import '../../components/pdf_preview.dart';

List<XFile> finalImages = [];

class ImagePreviewEditScreen extends StatefulWidget {
  final List<XFile> images;
  final String? categoryName;
  final String redirectTo;
  final int? selectedFolder;
  const ImagePreviewEditScreen(
      {Key? key,
      required this.images,
      required this.categoryName,
      required this.redirectTo,
      required this.selectedFolder})
      : super(key: key);

  @override
  State<ImagePreviewEditScreen> createState() => _ImagePreviewEditScreenState();
}

class _ImagePreviewEditScreenState extends State<ImagePreviewEditScreen> {
  PageController controller = PageController();
  bool isLoading = false;
  var currentPageValue = 0.0;
  Uint8List? blackAndWhite, magicColor, original;
  String versionOpenCV = 'OpenCV';
  bool visible = false;

  @override
  void initState() {
    finalImages.insertAll(0, widget.images);
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page!;
      });
    });
    loadFilter();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<CroppedFile?> cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    return croppedFile;
  }

  loadFilter() async {
    original = await Cv2.bilateralFilter(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: finalImages[currentPageValue.toInt()].path,
      diameter: 20,
      sigmaColor: 75,
      sigmaSpace: 75,
      borderType: Cv2.BORDER_DEFAULT,
    );

    magicColor = await Cv2.pyrMeanShiftFiltering(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: finalImages[currentPageValue.toInt()].path,
      spatialWindowRadius: 20,
      colorWindowRadius: 20,
    );

    blackAndWhite = await Cv2.cvtColor(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: finalImages[currentPageValue.toInt()].path,
      outputType: Cv2.COLOR_BGR2GRAY,
    );

    visible = true;
    isLoading = false;
    setState(() {});
  }

  Widget _indicator(bool isActive) {
    return SizedBox(
      height: 10,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 10 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: const Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : const BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? const Color(0XFF6BC4C9) : const Color(0XFFEAEAEA),
        ),
      ),
    );
  }

  Widget bottomSheetFilterWidget(context, imageIndex) {
    return SizedBox(
      height: 180,
      child: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  Directory tempDir = await getTemporaryDirectory();
                  File file = File('${tempDir.path}/image.jpeg');
                  File newFile = await file.writeAsBytes(original!);
                  print(newFile.path);
                  finalImages[currentPageValue.toInt()] = XFile(newFile.path);
                  setState(() {});
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: original != null
                      ? Image.memory(
                          original!,
                          fit: BoxFit.fill,
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  Directory tempDir = await getTemporaryDirectory();
                  File file = File('${tempDir.path}/blackAndWhite.jpeg');
                  File newFile = await file.writeAsBytes(blackAndWhite!);
                  print(newFile.path);
                  finalImages[currentPageValue.toInt()] = XFile(newFile.path);
                  setState(() {});
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: blackAndWhite != null
                      ? Image.memory(
                          blackAndWhite!,
                          fit: BoxFit.fill,
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  Directory tempDir = await getTemporaryDirectory();
                  File file = File('${tempDir.path}/magicColor.jpeg');
                  File newFile = await file.writeAsBytes(magicColor!);
                  print(newFile.path);
                  finalImages[currentPageValue.toInt()] = XFile(newFile.path);
                  setState(() {});
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: magicColor != null
                      ? Image.memory(
                          magicColor!,
                          fit: BoxFit.fill,
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Edit image",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (finalImages.length > 1) {
                final file = await CreatePdf().createPdfFile(finalImages);
                Get.to(PdfPreviewScreen(
                  documentUrl: file,
                  isFromFile: true,
                  selectedCategory: widget.categoryName,
                  isNetworkImage: false,
                ));
              } else {
                Get.to(
                  widget.categoryName == null
                      ? SelectFolderCategory(
                          images: finalImages,
                          selectedFolder: widget.selectedFolder,
                          ispdf: false,
                        )
                      : UploadDcoumnetScreen(
                          uploadIMages: finalImages,
                          selectedCategory: widget.categoryName!,
                          appBarTitle: '',
                          redirectTo: widget.redirectTo,
                          selectedFolder: widget.selectedFolder,
                        ),
                );
              }
              finalImages = [];
            },
            style: ElevatedButton.styleFrom(primary: AppColors.primaryColor),
            child: Text(finalImages.length > 1 ? "Create pdf" : "Save"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_a_photo),
        onPressed: () {
          Get.to(
            const CameraScreen(
              appBarTitle: '',
            ),
          );
        },
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: PageView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(
                              File(finalImages[index].path),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: finalImages
                            .map((e) =>
                                _indicator(index == currentPageValue.toInt()))
                            .toList(),
                      ),
                    )
                  ],
                );
              },
              itemCount: finalImages.length,
            )),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) async {
          if (index == 0) {
            final croppedFile = await cropImage(
              File(finalImages[currentPageValue.toInt()].path),
            );
            finalImages[currentPageValue.toInt()] = XFile(croppedFile!.path);
            setState(() {});
          } else if (index == 1) {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return bottomSheetFilterWidget(
                  context,
                  currentPageValue.toInt(),
                );
              },
            );
          } else if (index == 2) {
            finalImages.remove(finalImages[currentPageValue.toInt()]);
            setState(() {});
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.crop), label: 'Crop'),
          BottomNavigationBarItem(
              icon: Icon(Icons.filter_frames_sharp), label: 'Filter'),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Delete',
          )
        ],
      ),
    );
  }
}
