/* 
 * Copyright (c) 2021 fgsoruco.
 * See LICENSE for more details.
 */
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/factory/utils.dart';

///Class for process [AdaptiveThreshol]
class AdaptiveThresholdFactory {
  static const platform = MethodChannel('opencv_4');

  static Future<Uint8List?> adaptiveThreshold({
    required CVPathFrom pathFrom,
    required String pathString,
    required double maxValue,
    required int adaptiveMethod,
    required int thresholdType,
    required int blockSize,
    required double constantValue,
  }) async {
    File file;
    Uint8List fileAssets;

    Uint8List? result;
    int adaptiveMethodTemp = (adaptiveMethod > 1)
        ? 1
        : (adaptiveMethod < 0)
            ? 0
            : adaptiveMethod;

    int thresholdTypeTemp = (thresholdType > 1)
        ? 1
        : (thresholdType < 0)
            ? 0
            : thresholdType;

    switch (pathFrom) {
      case CVPathFrom.GALLERY_CAMERA:
        result = await platform.invokeMethod('adaptiveThreshold', {
          "pathType": 1,
          "pathString": pathString,
          "data": Uint8List(0),
          'maxValue': maxValue,
          'adaptiveMethod': adaptiveMethodTemp,
          'thresholdType': thresholdTypeTemp,
          'blockSize': blockSize,
          'constantValue': constantValue,
        });
        break;
      case CVPathFrom.URL:
        file = await DefaultCacheManager().getSingleFile(pathString);
        result = await platform.invokeMethod('adaptiveThreshold', {
          "pathType": 2,
          "pathString": '',
          "data": await file.readAsBytes(),
          'maxValue': maxValue,
          'adaptiveMethod': adaptiveMethodTemp,
          'thresholdType': thresholdTypeTemp,
          'blockSize': blockSize,
          'constantValue': constantValue
        });

        break;
      case CVPathFrom.ASSETS:
        fileAssets = await Utils.imgAssets2Uint8List(pathString);
        result = await platform.invokeMethod('adaptiveThreshold', {
          "pathType": 3,
          "pathString": '',
          "data": fileAssets,
          'maxValue': maxValue,
          'adaptiveMethod': adaptiveMethodTemp,
          'thresholdType': thresholdTypeTemp,
          'blockSize': blockSize,
          'constantValue': constantValue
        });
        break;
    }

    return result;
  }
}
