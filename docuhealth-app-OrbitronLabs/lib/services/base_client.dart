import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';
import 'app_exception.dart';

class BaseClient {
  static const int timeOutDuration = 20;
  static const String _jsonContentType = 'application/json; charset=UTF-8';
  static const String _jsonAccept = 'application/json';

  Future<dynamic> get(String api, bool isSecured, {bool showSnackbar = true}) async {
    var uri = Uri.parse(baseUrl + api);
    debugPrint('$uri');
    try {
      var response = isSecured
          ? await http.get(
              uri,
              headers: <String, String>{
                'Content-Type': _jsonContentType,
                'Accept': _jsonAccept,
                'Authorization': 'Bearer ${box.read('access_token')}'
              },
            ).timeout(const Duration(seconds: timeOutDuration))
          : await http.get(
              uri,
              headers: <String, String>{
                'Content-Type': _jsonContentType,
                'Accept': _jsonAccept,
              },
            ).timeout(const Duration(seconds: timeOutDuration));

      // print(response.body);
      return _processResponse(response, showSnackbar: showSnackbar);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  //POST
  Future<dynamic> post(String api, dynamic payloadObj, bool isSecured) async {
    var uri = Uri.parse(baseUrl + api);
    var payload = json.encode(payloadObj);
    debugPrint('$uri');
    debugPrint(payload);
    try {
      final response = isSecured
          ? await http
              .post(uri,
                  headers: <String, String>{
                    'Content-Type': _jsonContentType,
                    'Accept': _jsonAccept,
                    'Authorization': 'Bearer ${box.read('access_token')}'
                  },
                  body: payload)
              .timeout(const Duration(seconds: timeOutDuration))
          : await http
              .post(uri,
                  headers: <String, String>{
                    'Content-Type': _jsonContentType,
                    'Accept': _jsonAccept,
                  },
                  body: payload)
              .timeout(const Duration(seconds: timeOutDuration));

      _logResponseSummary(response);

      return _processResponse(response);
    } on SocketException {
      Get.showSnackbar(
        const GetSnackBar(
          message: "No Internet connection",
          isDismissible: true,
          duration: Duration(seconds: 2),
        ),
      );
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      Get.showSnackbar(
        const GetSnackBar(
          message: "API not responded in time",
          isDismissible: true,
          duration: Duration(seconds: 2),
        ),
      );
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  // Image Upload

  Future<dynamic> uploadDocument(
      String api, String targetPath, String filePath, bool isSecured) async {
    var uri = Uri.parse(baseUrl + api);
    debugPrint('$uri');
    try {
      var headers = {
        'Authorization': 'Bearer ${box.read('access_token')}',
        'Accept': _jsonAccept
      };
      var request = http.MultipartRequest('POST', uri);
      request.fields.addAll({'target_path': targetPath});
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        return await response.stream.bytesToString();
      } else {
        return false;
      }
    } on SocketException {
      Get.showSnackbar(
        const GetSnackBar(
          message: "No Internet connection",
          isDismissible: true,
          duration: Duration(seconds: 2),
        ),
      );
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      Get.showSnackbar(
        const GetSnackBar(
          message: "API not responded in time",
          isDismissible: true,
          duration: Duration(seconds: 2),
        ),
      );
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  Future<dynamic> uploadProfilePicture(
      String api, String filePath, bool isSecured) async {
    var uri = Uri.parse(baseUrl + api);
    try {
      var headers = {
        'Authorization': 'Bearer ${box.read('access_token')}',
        'Accept': _jsonAccept
      };
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        return await response.stream.bytesToString();
      } else {
        return false;
      }
    } on SocketException {
      Get.showSnackbar(
        const GetSnackBar(
          message: "No Internet connection",
          isDismissible: true,
          duration: Duration(seconds: 2),
        ),
      );
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      Get.showSnackbar(
        const GetSnackBar(
          message: "API not responded in time",
          isDismissible: true,
          duration: Duration(seconds: 2),
        ),
      );
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  Future<dynamic> dataWithAttachment(
      String api, dynamic payloadObj, String filePath, bool isSecured) async {
    var uri = Uri.parse(baseUrl + api);
    try {
      var headers = {
        'Authorization': 'Bearer ${box.read('access_token')}',
        'Accept': _jsonAccept
      };
      var request = http.MultipartRequest('POST', uri);
      debugPrint('$request');
      request.fields.addAll(payloadObj);
      request.files
          .add(await http.MultipartFile.fromPath('attachment', filePath));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        return false;
      }
    } on SocketException {
      Get.showSnackbar(
        const GetSnackBar(
          message: "No Internet connection",
          isDismissible: true,
          duration: Duration(seconds: 2),
        ),
      );
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      Get.showSnackbar(
        const GetSnackBar(
          message: "API not responded in time",
          isDismissible: true,
          duration: Duration(seconds: 2),
        ),
      );
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  dynamic _processResponse(http.Response response, {bool showSnackbar = true}) {
    final rawBody = utf8.decode(response.bodyBytes);

    switch (response.statusCode) {
      case 200:
        if (_looksLikeHtml(rawBody)) {
          throw FetchDataException('Server returned HTML instead of JSON',
              response.request!.url.toString());
        }

        dynamic data;
        try {
          data = jsonDecode(rawBody);
        } on FormatException {
          throw FetchDataException('Invalid JSON response from server',
              response.request!.url.toString());
        }

        if (data is Map<String, dynamic> && data["errorType"] == 'Error') {
          if (showSnackbar) {
            Get.showSnackbar(
              GetSnackBar(
                message: data['errorMessage'].toString(),
                isDismissible: true,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }

        return data;

      case 201:
        var responseJson = utf8.decode(response.bodyBytes);
        return responseJson;

      case 400:
        if (showSnackbar) {
          Get.showSnackbar(
            const GetSnackBar(
              message: "Oops! something went wrong",
              isDismissible: true,
              duration: Duration(seconds: 2),
            ),
          );
        }
        throw BadRequestException(
            _extractErrorMessage(rawBody, response.statusCode),
            response.request!.url.toString());

      case 401:
      case 403:
        if (showSnackbar) {
          Get.showSnackbar(
            const GetSnackBar(
              message: "Unauthorised User",
              isDismissible: true,
              duration: Duration(seconds: 2),
            ),
          );
        }
        throw UnAuthorizedException(
            _extractErrorMessage(rawBody, response.statusCode),
            response.request!.url.toString());
      case 422:
        if (showSnackbar) {
          Get.showSnackbar(
            const GetSnackBar(
              message: "Oops! something went wrong",
              isDismissible: true,
              duration: Duration(seconds: 2),
            ),
          );
        }
        throw BadRequestException(
            _extractErrorMessage(rawBody, response.statusCode),
            response.request!.url.toString());
      case 500:
      default:
        if (showSnackbar) {
          Get.showSnackbar(
            const GetSnackBar(
              message: "Oops! something went wrong",
              isDismissible: true,
              duration: Duration(seconds: 2),
            ),
          );
        }
        throw FetchDataException(
            _extractErrorMessage(rawBody, response.statusCode),
            response.request!.url.toString());
    }
  }

  void _logResponseSummary(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (_looksLikeHtml(body)) {
      debugPrint(
          'HTTP ${response.statusCode} ${response.request?.url} returned HTML response.');
      return;
    }

    const maxLen = 400;
    final snippet =
        body.length > maxLen ? '${body.substring(0, maxLen)}...(truncated)' : body;
    debugPrint(snippet);
  }

  bool _looksLikeHtml(String body) {
    final trimmed = body.trimLeft().toLowerCase();
    return trimmed.startsWith('<!doctype html') || trimmed.startsWith('<html');
  }

  String _extractErrorMessage(String rawBody, int statusCode) {
    if (_looksLikeHtml(rawBody)) {
      return 'Server error ($statusCode). Backend returned HTML exception page.';
    }

    try {
      final parsed = jsonDecode(rawBody);
      if (parsed is Map<String, dynamic>) {
        final message = parsed['message'] ?? parsed['errorMessage'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {
      // Use fallback below.
    }

    return rawBody.isNotEmpty
        ? rawBody
        : 'Error occured with code : $statusCode';
  }
}
