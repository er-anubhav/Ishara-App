class ReminderData {
  ReminderData({
    this.id,
    this.profileId,
    this.name,
    this.time,
    this.eventType,
    this.eventAt,
    this.snooze,
    this.snoozeInterval,
    this.snoozeRepeat,
    this.status,
    this.updatedAt,
  });

  int? id;
  int? profileId;
  String? name;
  String? time;
  String? eventType;
  List<String>? eventAt;
  int? snooze;
  dynamic snoozeInterval;
  dynamic snoozeRepeat;
  bool? status;
  String? updatedAt;

  factory ReminderData.fromJson(Map<String, dynamic> json) => ReminderData(
        id: json["id"],
        profileId: json["profile_id"],
        name: json["name"],
        time: json["time"],
        eventType: json["event_type"],
        eventAt: List<String>.from(json["event_at"].map((x) => x)),
        snooze: json["snooze"],
        snoozeInterval: json["snooze_interval"],
        snoozeRepeat: json["snooze_repeat"],
        status: json["status"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "profile_id": profileId,
        "name": name,
        "time": time,
        "event_type": eventType,
        "event_at": List<dynamic>.from(eventAt!.map((x) => x)),
        "snooze": snooze,
        "snooze_interval": snoozeInterval,
        "snooze_repeat": snoozeRepeat,
        "status": status,
        "updated_at": updatedAt,
      };
}
