/* 
 * Copyright (c) 2021 fgsoruco.
 * See LICENSE for more details.
 */
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/factory/utils.dart';

///Class for process [PyrMeanShiftFiltering]
class PyrMeanShiftFilteringFactory {
  static const platform = MethodChannel('opencv_4');

  static Future<Uint8List?> pyrMeanShiftFiltering({
    required CVPathFrom pathFrom,
    required String pathString,
    required double spatialWindowRadius,
    required double colorWindowRadius,
  }) async {
    File file;
    Uint8List fileAssets;

    Uint8List? result;
    switch (pathFrom) {
      case CVPathFrom.GALLERY_CAMERA:
        result = await platform.invokeMethod(
          'pyrMeanShiftFiltering',
          {
            "pathType": 1,
            'pathString': pathString,
            "data": Uint8List(0),
            'spatialWindowRadius': spatialWindowRadius,
            'colorWindowRadius': colorWindowRadius,
          },
        );
        break;
      case CVPathFrom.URL:
        file = await DefaultCacheManager().getSingleFile(pathString);
        result = await platform.invokeMethod(
          'pyrMeanShiftFiltering',
          {
            "pathType": 2,
            "pathString": '',
            "data": await file.readAsBytes(),
            'spatialWindowRadius': spatialWindowRadius,
            'colorWindowRadius': colorWindowRadius,
          },
        );

        break;
      case CVPathFrom.ASSETS:
        fileAssets = await Utils.imgAssets2Uint8List(pathString);
        result = await platform.invokeMethod(
          'pyrMeanShiftFiltering',
          {
            "pathType": 3,
            "pathString": '',
            "data": fileAssets,
            'spatialWindowRadius': spatialWindowRadius,
            'colorWindowRadius': colorWindowRadius,
          },
        );
        break;
    }
    return result;
  }
}
