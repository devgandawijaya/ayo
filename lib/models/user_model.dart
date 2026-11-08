import 'role_model.dart';
import 'company_model.dart';
import 'employee_model.dart';
import 'person_model.dart';
import 'configuration_model.dart';

class UserModel {
  final int id;
  final int? masterPersonId;
  final int? masterCompanyId;
  final int? masterRoleId;
  final String name;
  final String email;
  final String? fcmToken;
  final String? avatar;
  final String token;
  final List<RoleModel> roles;
  final ConfigurationModel? configuration;
  final EmployeeModel? employee;
  final CompanyModel? company;
  final PersonModel? person;

  UserModel({
    required this.id,
    this.masterPersonId,
    this.masterCompanyId,
    this.masterRoleId,
    required this.name,
    required this.email,
    this.fcmToken,
    this.avatar,
    required this.token,
    this.roles = const [],
    this.configuration,
    this.employee,
    this.company,
    this.person,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Roles can be under 'roles' or 'role' in the JSON
    final rawRoles = json['roles'] ?? json['role'];
    List<RoleModel> rolesList = [];
    if (rawRoles is List) {
      rolesList = rawRoles
          .map((r) => RoleModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return UserModel(
      id: json['id'] as int? ?? 0,
      masterPersonId: json['master_person_id'] as int?,
      masterCompanyId: json['master_company_id'] as int?,
      masterRoleId: json['master_role_id'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fcmToken: json['fcm_token'] as String?,
      avatar: json['avatar'] as String?,
      token: json['token'] as String? ?? '',
      roles: rolesList,
      configuration: json['configuration'] != null
          ? ConfigurationModel.fromJson(
              json['configuration'] as Map<String, dynamic>)
          : null,
      employee: json['employee'] != null
          ? EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      company: json['company'] != null
          ? CompanyModel.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      person: json['person'] != null
          ? PersonModel.fromJson(json['person'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'master_person_id': masterPersonId,
      'master_company_id': masterCompanyId,
      'master_role_id': masterRoleId,
      'name': name,
      'email': email,
      'fcm_token': fcmToken,
      'avatar': avatar,
      'token': token,
      'roles': roles.map((r) => r.toJson()).toList(),
      'configuration': configuration?.toJson(),
      'employee': employee?.toJson(),
      'company': company?.toJson(),
      'person': person?.toJson(),
    };
  }

  // Convenient helper getters
  String get roleName =>
      roles.isNotEmpty ? roles.first.displayName : 'Employee';
  String get companyName => company?.name ?? 'PT. PKP';
  String get npk => employee?.npk ?? '-';
  String get gender => person?.gender ?? '-';
  String get religion => person?.religion ?? '-';
  String get maritalStatus => person?.maritalStatus ?? '-';
}
