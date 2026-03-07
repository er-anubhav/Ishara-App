/* 
 * Copyright (c) 2021 fgsoruco.
 * See LICENSE for more details.
 */
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/factory/utils.dart';

///Class for process [MorphologyEx]
class MorphologyExFactory {
  static const platform = MethodChannel('opencv_4');

  static Future<Uint8List?> morphologyEx({
    required CVPathFrom pathFrom,
    required String pathString,
    required int operation,
    required List<int> kernelSize,
  }) async {
    File file;
    Uint8List fileAssets;

    Uint8List? result;
    List<int> kernelSizeTemp = Utils.verKernelSizeInt(kernelSize);
    int operationTemp = (operation < 0)
        ? 0
        : (operation > 6)
            ? 6
            : operation;

    switch (pathFrom) {
      case CVPathFrom.GALLERY_CAMERA:
        result = await platform.invokeMethod(
          'morphologyEx',
          {
            "pathType": 1,
            'pathString': pathString,
            "data": Uint8List(0),
            'operation': operationTemp,
            'kernelSize': kernelSizeTemp,
          },
        );
        break;
      case CVPathFrom.URL:
        file = await DefaultCacheManager().getSingleFile(pathString);
        result = await platform.invokeMethod(
          'morphologyEx',
          {
            "pathType": 2,
            "pathString": '',
            "data": await file.readAsBytes(),
            'operation': operationTemp,
            'kernelSize': kernelSizeTemp,
          },
        );

        break;
      case CVPathFrom.ASSETS:
        fileAssets = await Utils.imgAssets2Uint8List(pathString);
        result = await platform.invokeMethod(
          'morphologyEx',
          {
            "pathType": 3,
            "pathString": '',
            "data": fileAssets,
            'operation': operationTemp,
            'kernelSize': kernelSizeTemp,
          },
        );
        break;
    }
    return result;
  }
}
