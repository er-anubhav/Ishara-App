import 'package:docuhealth/model/daily_measurement/measurements.dart';

class MeasurementData {
  MeasurementData({
    this.id,
    this.profileId,
    this.category,
    this.datas,
    this.attachment,
    this.comment,
    this.isAutoFetched,
    this.date,
    this.time,
    this.deletedAt,
  });

  int? id;
  int? profileId;
  String? category;
  Measurements? datas;
  String? attachment;
  String? comment;
  bool? isAutoFetched;
  String? date;
  String? time;
  dynamic deletedAt;

  factory MeasurementData.fromJson(Map<String, dynamic> json) =>
      MeasurementData(
        id: json["id"],
        profileId: json["profile_id"],
        category: json["category"],
        datas: Measurements.fromJson(json["datas"]),
        attachment: json["attachment"],
        comment: json["comment"],
        isAutoFetched: json["is_auto_fetched"] == 1 || json["is_auto_fetched"] == true,
        date: json["date"],
        time: json["time"],
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "profile_id": profileId,
        "category": category,
        "datas": datas?.toJson(),
        "attachment": attachment,
        "comment": comment,
        "is_auto_fetched": isAutoFetched,
        "date": date,
        "time": time,
        "deleted_at": deletedAt,
      };
}
