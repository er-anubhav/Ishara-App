import 'package:docuhealth/model/daily_measurement/values.dart';

class AnalyticsData {
  AnalyticsData({
    this.label,
    this.values,
  });

  String? label;
  List<Value>? values;

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => AnalyticsData(
        label: json["label"],
        values: List<Value>.from(json["values"].map((x) => Value.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "values": List<dynamic>.from(values!.map((x) => x.toJson())),
      };
}
