class CompanyModel {
  final int id;
  final int? configurationId;
  final String name;
  final String? description;
  final bool isActive;

  CompanyModel({
    required this.id,
    this.configurationId,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int? ?? 0,
      configurationId: json['configuration_id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'configuration_id': configurationId,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}
