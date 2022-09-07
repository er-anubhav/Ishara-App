class DoctorData {
  DoctorData({
    this.id,
    this.name,
    this.role,
    this.specializations,
    this.degree,
    this.services,
    this.description,
    this.verified,
    this.featured,
    this.isActive,
    this.createdAt,
    this.icon,
    this.experience,
  });

  int? id;
  String? name;
  String? role;
  String? specializations;
  String? degree;
  String? services;
  String? description;
  String? verified;
  String? featured;
  String? isActive;
  String? createdAt;
  String? icon;
  String? experience;

  factory DoctorData.fromJson(Map<String, dynamic> json) => DoctorData(
        id: json["id"],
        name: json["name"],
        role: json["role"],
        specializations: json["specializations"],
        degree: json["degree"],
        services: json["services"],
        description: json["description"],
        verified: json["verified"],
        featured: json["featured"],
        isActive: json["is_active"],
        createdAt: json["created_at"],
        icon: json["icon"],
        experience: json["experience"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "role": role,
        "specializations": specializations,
        "degree": degree,
        "services": services,
        "description": description,
        "verified": verified,
        "featured": featured,
        "is_active": isActive,
        "created_at": createdAt,
        "icon": icon,
        "experience": experience,
      };
}
