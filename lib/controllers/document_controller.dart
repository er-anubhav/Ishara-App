import 'package:docuhealth/model/get_api_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/documents/documents_data_model.dart';
import '../model/documents/get_documents.dart';
import '../services/base_client.dart';

class DocumentController extends ChangeNotifier {
  bool isLoading = false;
  List<DocumentData> listData = [];
  List<DocumentData> myDocuments = [];
  List<DocumentData> listFiles = [];
  BaseClient baseClient = BaseClient();
  GetDocuments getFilesFolders = GetDocuments();
  GetApiResponse getApiResponse = GetApiResponse();
  int totalpage = 0;

  Future<void> getData(BuildContext context, int currentPage, String sortBy, String searchKey, String categoryName,
      bool isRefresh) async {
    if (isRefresh) {
      listData = [];
      isLoading = true;
      notifyListeners();
    }
    final resp = await baseClient.get(
        'folders-and-files?sort_by=$sortBy&search=$searchKey&page=$currentPage&category=$categoryName',
        true);
    getFilesFolders = getDocumentsFromJson(resp);
    if (getFilesFolders.success!) {
      if (getFilesFolders.data?.data != null) {
        double pageCount = getFilesFolders.data!.dataRecords!.totalRecords! /
            getFilesFolders.data!.dataRecords!.limit!;

        totalpage = pageCount.ceil();
      }
      if (isRefresh) {
        listData = getFilesFolders.data?.data ?? [];
        isLoading = false;
      } else {
        listData.addAll(getFilesFolders.data?.data ?? []);
      }
    }
    notifyListeners();
  }

  Future<void> getMyDocuments(
      BuildContext context, int currentPage, String searchKey, bool isRefresh) async {
    if (isRefresh) {
      myDocuments = [];
      isLoading = true;
      notifyListeners();
    }
    final resp = await baseClient.get(
        'my-documents?page=$currentPage&search=$searchKey', true);
    getFilesFolders = getDocumentsFromJson(resp);
    if (getFilesFolders.success!) {
      if (getFilesFolders.data?.data != null) {
        double pageCount = getFilesFolders.data!.dataRecords!.totalRecords! /
            getFilesFolders.data!.dataRecords!.limit!;

        totalpage = pageCount.ceil();
      }
      if (isRefresh) {
        myDocuments = getFilesFolders.data?.data ?? [];
        isLoading = false;
      } else {
        myDocuments.addAll(getFilesFolders.data?.data ?? []);
      }
    }
    notifyListeners();
  }

  Future<void> getFiles(BuildContext context, String category, int folderId, int currentPage,
      String searchKey, String sortBy, bool isRefresh) async {
    if (isRefresh) {
      listFiles = [];
      isLoading = true;
      notifyListeners();
    }
    final resp = await baseClient.get(
        'file/get?category=$category&folder=$folderId&page=$currentPage&sort_by=$sortBy&search=$searchKey',
        true);
    getFilesFolders = getDocumentsFromJson(resp);
    if (getFilesFolders.success!) {
      if (getFilesFolders.data?.data != null) {
        double pageCount = getFilesFolders.data!.dataRecords!.totalRecords! /
            getFilesFolders.data!.dataRecords!.limit!;

        totalpage = pageCount.ceil();
      }
      if (isRefresh) {
        listFiles = getFilesFolders.data?.data ?? [];
        isLoading = false;
      } else {
        listFiles.addAll(getFilesFolders.data?.data ?? []);
      }
    }
    notifyListeners();
  }

  Future<bool> ondeleteFile(BuildContext context, int id, String buttonType) async {
    final response = await baseClient.get("$buttonType/delete/$id", true);
    final getApiResponse = getApiResponseFromJson(response);

    if (getApiResponse.success!) {
      Get.snackbar('Success', '${getApiResponse.message}',
          backgroundColor: Colors.green);
      return true;
    } else {
      Get.snackbar('Failed', '${getApiResponse.message}',
          backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> onRenamePress(int id, buttonType, nameController) async {
    var data = buttonType == "folder"
        ? {"folder_id": id.toString(), "name": nameController}
        : {"file_id": id.toString(), "name": nameController};
    final resp = await baseClient.post("$buttonType/rename", data, true);
    final getApiResponse = getApiResponseFromJson(resp);
    if (getApiResponse.success!) {
      Get.snackbar('Success', '${getApiResponse.message}',
          backgroundColor: Colors.green);
      return true;
    } else {
      Get.snackbar('Failed', '${getApiResponse.message}',
          backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> onPaste(
      BuildContext context, String documentType, int fileId, String categoryName, bool isCopy) async {
    var data = documentType == "folder"
        ? {"folder_id": "$fileId", "distination": categoryName}
        : {"file_id": "$fileId", "distination": categoryName};
    final response = await baseClient.post(
        isCopy ? '$documentType/copy' : '$documentType/move', data, true);
    final getApiResponse = getApiResponseFromJson(response);
    if (getApiResponse.success!) {
      Get.snackbar('Success', '${getApiResponse.message}',
          backgroundColor: Colors.green);
      return true;
    } else {
      Get.snackbar('Failed', '${getApiResponse.message}',
          backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> onBookMark(int id, String operation, String documentType) async {
    final response = await baseClient.get(
        'bookmark/$operation?id=$id&type=$documentType', true);

    final getApiResponse = getApiResponseFromJson(response);
    if (getApiResponse.success!) {
      Get.snackbar('Success', '${getApiResponse.message}',
          backgroundColor: Colors.green);
      return true;
    } else {
      Get.snackbar('Failed', '${getApiResponse.message}',
          backgroundColor: Colors.red);
      return false;
    }
  }
}
