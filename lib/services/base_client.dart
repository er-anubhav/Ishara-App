import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';
import 'app_exception.dart';

class BaseClient {
  static const int timeOutDuration = 20;

  Future<dynamic> get(String api, bool isSecured) async {
    var uri = Uri.parse(baseUrl + api);
    print(uri);
    try {
      var response = isSecured
          ? await http.get(
              uri,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer ${box.read('access_token')}'
              },
            ).timeout(const Duration(seconds: timeOutDuration))
          : await http.get(
              uri,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
            ).timeout(const Duration(seconds: timeOutDuration));

      // print(response.body);
      return _processResponse(response);
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
    print(uri);
    print(payload);
    try {
      final response = isSecured
          ? await http
              .post(uri,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Authorization': 'Bearer ${box.read('access_token')}'
                  },
                  body: payload)
              .timeout(const Duration(seconds: timeOutDuration))
          : await http
              .post(uri,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: payload)
              .timeout(const Duration(seconds: timeOutDuration));

      print(response.body);

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
    print(uri);
    try {
      var headers = {'Authorization': 'Bearer ${box.read('access_token')}'};
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
      var headers = {'Authorization': 'Bearer ${box.read('access_token')}'};
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
      var headers = {'Authorization': 'Bearer ${box.read('access_token')}'};
      var request = http.MultipartRequest('POST', uri);
      print(request);
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

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        // var responseJson = utf8.decode(response.bodyBytes);
        var data = jsonDecode(response.body);

        if (data["errorType"] == 'Error') {
          Get.showSnackbar(
            GetSnackBar(
              message: data['errorMessage'].toString(),
              isDismissible: true,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        return data;

      case 201:
        var responseJson = utf8.decode(response.bodyBytes);
        return responseJson;

      case 400:
        Get.showSnackbar(
          const GetSnackBar(
            message: "Oops! something went wrong",
            isDismissible: true,
            duration: Duration(seconds: 2),
          ),
        );
        throw BadRequestException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());

      case 401:
      case 403:
        Get.showSnackbar(
          const GetSnackBar(
            message: "Unauthorised User",
            isDismissible: true,
            duration: Duration(seconds: 2),
          ),
        );
        throw UnAuthorizedException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 422:
        Get.showSnackbar(
          const GetSnackBar(
            message: "Oops! something went wrong",
            isDismissible: true,
            duration: Duration(seconds: 2),
          ),
        );
        throw BadRequestException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 500:
      default:
        Get.showSnackbar(
          const GetSnackBar(
            message: "Oops! something went wrong",
            isDismissible: true,
            duration: Duration(seconds: 2),
          ),
        );
        throw FetchDataException(
            'Error occured with code : ${response.statusCode}',
            response.request!.url.toString());
    }
  }
}
