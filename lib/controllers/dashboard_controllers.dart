import 'dart:convert';

import 'package:docuhealth/model/dashboard/banners_data.dart';
import 'package:docuhealth/model/doctor_data.dart';
import 'package:docuhealth/model/documents/documents_data_model.dart';
import 'package:docuhealth/model/dashboard/get_recent_uploads.dart';
import 'package:flutter/material.dart';
import '../model/dashboard/get_banners.dart';
import '../model/dashboard/get_featured_doctors.dart';
import '../services/base_client.dart';

class DashBoardController extends ChangeNotifier {
  List<BannerData> bannersList = [];
  List<DocumentData> recentUploads = [];
  List<DoctorData> featuredDoctorLIst = [];
  BaseClient baseClient = BaseClient();
  GetBanners getBanners = GetBanners();
  GetRecentUploads getRecentUploads = GetRecentUploads();
  GetFeaturedDoctors getFeaturedDoctors = GetFeaturedDoctors();

  Future<void> getBannersData(BuildContext context) async {
    final apiResponse = await baseClient.get('banners', false);
    var response = jsonEncode(apiResponse);
    getBanners = getBannersFromJson(response);
    if (getBanners.success!) {
      bannersList = getBanners.data ?? [];
    }
    notifyListeners();
  }

  Future<void> getRecentUpload(BuildContext context) async {
    final apiResponse = await baseClient.get('recent-uploads', true);

    var response = jsonEncode(apiResponse);

    getRecentUploads = getRecentUploadsFromJson(response);
    if (getRecentUploads.success!) {
      recentUploads = getRecentUploads.data ?? [];
    }
    notifyListeners();
  }

  Future<void> getFeaturedDoctorsData(BuildContext context) async {
    final apiResponse = await baseClient.get('medico-featured', true);
    var response = jsonEncode(apiResponse);
    getFeaturedDoctors = getFeaturedDoctorsFromJson(response);
    if (getFeaturedDoctors.success!) {
      featuredDoctorLIst = getFeaturedDoctors.data ?? [];
    }
    notifyListeners();
  }
}
