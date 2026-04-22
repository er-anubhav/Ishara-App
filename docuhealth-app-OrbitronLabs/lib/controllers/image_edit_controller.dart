import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';

import '../screen/scanner/image_preview_edit_screen.dart';

class ImageEditController extends ChangeNotifier {
  Uint8List? blackAndWhite, magicColor, original;
  Future<bool> loadFilter(int currentPage) async {
    original = await Cv2.bilateralFilter(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: finalImages[currentPage].path,
      diameter: 20,
      sigmaColor: 75,
      sigmaSpace: 75,
      borderType: Cv2.BORDER_DEFAULT,
    );

    magicColor = await Cv2.pyrMeanShiftFiltering(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: finalImages[currentPage].path,
      spatialWindowRadius: 20,
      colorWindowRadius: 20,
    );

    blackAndWhite = await Cv2.cvtColor(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: finalImages[currentPage].path,
      outputType: Cv2.COLOR_BGR2GRAY,
    );

    notifyListeners();
    return true;
  }
}
