import 'measurements.dart';

class Value {
  Value({
    this.category,
    this.measurements,
    this.formattedDate,
    this.time,
    this.id,
  });

  String? category;
  Measurements? measurements;
  String? formattedDate;
  String? time;
  int? id;

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        category: json["category"],
        measurements: Measurements.fromJson(json["datas"]),
        formattedDate: json["formatted_date"],
        time: json["time"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "datas": measurements?.toJson(),
        "formatted_date": formattedDate,
        "time": time,
        "id": id,
      };
}
