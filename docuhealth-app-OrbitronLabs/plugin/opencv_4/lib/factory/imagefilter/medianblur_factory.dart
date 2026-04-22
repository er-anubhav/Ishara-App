/* 
 * Copyright (c) 2021 fgsoruco.
 * See LICENSE for more details.
 */
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/factory/utils.dart';

///Class for process [MedianBlur]
class MedianBlurFactory {
  static const platform = MethodChannel('opencv_4');

  static Future<Uint8List?> medianBlur({
    required CVPathFrom pathFrom,
    required String pathString,
    required int kernelSize,
  }) async {
    File file;
    Uint8List fileAssets;

    Uint8List? result;
    int kernelSizeTemp = (kernelSize <= 0) ? 1 : kernelSize;

    switch (pathFrom) {
      case CVPathFrom.GALLERY_CAMERA:
        result = await platform.invokeMethod(
          'medianBlur',
          {
            "pathType": 1,
            'pathString': pathString,
            "data": Uint8List(0),
            'kernelSize': kernelSizeTemp,
          },
        );
        break;
      case CVPathFrom.URL:
        file = await DefaultCacheManager().getSingleFile(pathString);
        result = await platform.invokeMethod(
          'medianBlur',
          {
            "pathType": 2,
            "pathString": '',
            "data": await file.readAsBytes(),
            'kernelSize': kernelSizeTemp,
          },
        );

        break;
      case CVPathFrom.ASSETS:
        fileAssets = await Utils.imgAssets2Uint8List(pathString);
        result = await platform.invokeMethod(
          'medianBlur',
          {
            "pathType": 3,
            "pathString": '',
            "data": fileAssets,
            'kernelSize': kernelSizeTemp,
          },
        );
        break;
      default:
        fileAssets = await Utils.imgAssets2Uint8List(pathString);
        result = await platform.invokeMethod(
          'medianBlur',
          {
            "pathType": 3,
            "pathString": '',
            "data": fileAssets,
            'kernelSize': kernelSize,
          },
        );
    }
    return result;
  }
}
