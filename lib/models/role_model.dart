class RoleModel {
  final int id;
  final String name;
  final String displayName;
  final String? description;

  RoleModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
    };
  }
}
