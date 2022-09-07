class DataRecords {
  DataRecords({
    this.pagination,
    this.page,
    this.limit,
    this.start,
    this.totalRecords,
  });

  bool? pagination;
  int? page;
  int? limit;
  int? start;
  int? totalRecords;

  factory DataRecords.fromJson(Map<String, dynamic> json) => DataRecords(
        pagination: json["pagination"],
        page: json["page"],
        limit: json["limit"],
        start: json["start"],
        totalRecords: json["total_records"],
      );

  Map<String, dynamic> toJson() => {
        "pagination": pagination,
        "page": page,
        "limit": limit,
        "start": start,
        "total_records": totalRecords,
      };
}
