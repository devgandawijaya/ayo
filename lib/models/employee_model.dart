class EmployeeModel {
  final int id;
  final int? masterPersonId;
  final int? masterCompanyId;
  final String npk;
  final String? joinDate;
  final String? leavingDate;
  final String? appId;
  final int? spvId;
  final int? departmentId;

  EmployeeModel({
    required this.id,
    this.masterPersonId,
    this.masterCompanyId,
    required this.npk,
    this.joinDate,
    this.leavingDate,
    this.appId,
    this.spvId,
    this.departmentId,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int? ?? 0,
      masterPersonId: json['master_person_id'] as int?,
      masterCompanyId: json['master_company_id'] as int?,
      npk: json['npk'] as String? ?? '-',
      joinDate: json['join_date'] as String?,
      leavingDate: json['leaving_date'] as String?,
      appId: json['app_id'] as String?,
      spvId: json['spv_id'] as int?,
      departmentId: json['department_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'master_person_id': masterPersonId,
      'master_company_id': masterCompanyId,
      'npk': npk,
      'join_date': joinDate,
      'leaving_date': leavingDate,
      'app_id': appId,
      'spv_id': spvId,
      'department_id': departmentId,
    };
  }
}
