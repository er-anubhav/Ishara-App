class DocumentData {
  DocumentData({
    this.name,
    this.value,
    this.tag,
    this.id,
    this.belongsTo,
    this.createdAt,
    this.bookmark,
    this.category,
    this.fileType,
    this.remarks,
    this.file,
    this.thumbnailFile,
  });

  String? name;
  String? value;
  String? tag;
  int? id;
  dynamic belongsTo;
  String? createdAt;
  String? bookmark;
  dynamic category;
  String? fileType;
  dynamic remarks;
  String? file;
  String? thumbnailFile;

  factory DocumentData.fromJson(Map<String, dynamic> json) => DocumentData(
        name: json["name"],
        value: json["value"],
        tag: json["tag"],
        id: json["id"],
        belongsTo: json["belongs_to"],
        createdAt: json["created_at"],
        bookmark: json["bookmark"],
        category: json["category"],
        fileType: json["file_type"],
        remarks: json["remarks"],
        file: json["file"],
        thumbnailFile: json["thumbnail_file"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
        "tag": tag,
        "id": id,
        "belongs_to": belongsTo,
        "created_at": createdAt,
        "bookmark": bookmark,
        "category": category,
        "file_type": fileType,
        "remarks": remarks,
        "file": file,
        "thumbnail_file": thumbnailFile,
      };
}
