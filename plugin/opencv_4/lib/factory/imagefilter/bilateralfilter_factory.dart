/* 
 * Copyright (c) 2021 fgsoruco.
 * See LICENSE for more details.
 */
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/factory/utils.dart';

///Class for process [BilateralFilter]
class BilateralFilterFactory {
  static const platform = MethodChannel('opencv_4');

  static Future<Uint8List?> bilateralFilter({
    required CVPathFrom pathFrom,
    required String pathString,
    required int diameter,
    required int sigmaColor,
    required int sigmaSpace,
    required int borderType,
  }) async {
    File file;
    Uint8List fileAssets;

    Uint8List? result;

    int diameterTemp = (diameter >= 0)
        ? (diameter == 0)
            ? 1
            : diameter
        : -1 * diameter;
    int borderTypeTemp = Utils.verBorderType(borderType);

    switch (pathFrom) {
      case CVPathFrom.GALLERY_CAMERA:
        result = await platform.invokeMethod('bilateralFilter', {
          "pathType": 1,
          "pathString": pathString,
          "data": Uint8List(0),
          'diameter': diameterTemp,
          "sigmaColor": sigmaColor,
          "sigmaSpace": sigmaSpace,
          "borderType": borderTypeTemp,
        });
        break;
      case CVPathFrom.URL:
        file = await DefaultCacheManager().getSingleFile(pathString);
        result = await platform.invokeMethod('bilateralFilter', {
          "pathType": 2,
          "pathString": '',
          "data": await file.readAsBytes(),
          "diameter": diameterTemp,
          "sigmaColor": sigmaColor,
          "sigmaSpace": sigmaSpace,
          "borderType": borderTypeTemp,
        });

        break;
      case CVPathFrom.ASSETS:
        fileAssets = await Utils.imgAssets2Uint8List(pathString);
        result = await platform.invokeMethod('bilateralFilter', {
          "pathType": 3,
          "pathString": '',
          "data": fileAssets,
          "diameter": diameterTemp,
          "sigmaColor": sigmaColor,
          "sigmaSpace": sigmaSpace,
          "borderType": borderTypeTemp,
        });
        break;
    }

    return result;
  }
}
