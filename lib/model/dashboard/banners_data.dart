class BannerData {
  BannerData({
    this.id,
    this.image,
    this.type,
    this.position,
    this.url,
    this.urlType,
    this.remarks,
    this.createdAt,
  });

  int? id;
  String? image;
  String? type;
  int? position;
  String? url;
  String? urlType;
  String? remarks;
  String? createdAt;

  factory BannerData.fromJson(Map<String, dynamic> json) => BannerData(
        id: json["id"],
        image: json["image"],
        type: json["type"],
        position: json["position"],
        url: json["url"],
        urlType: json["url_type"],
        remarks: json["remarks"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "type": type,
        "position": position,
        "url": url,
        "url_type": urlType,
        "remarks": remarks,
        "created_at": createdAt,
      };
}
