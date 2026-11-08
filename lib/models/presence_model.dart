import 'location_model.dart';

class PresenceModel {
  final int id;
  final int masterCompanyId;
  final int masterEmployeeId;
  final int? timeInLocationId;
  final int? timeOutLocationId;
  final String? latitude;
  final String? longitude;
  final String? radius;
  final String? timeIn;
  final String? timeOut;
  final String? createdAt;
  final String? updatedAt;
  final int? late;
  final String? startBreak;
  final String? endBreak;
  final String? reason;
  final String? setupTimeIn;
  final String? setupTimeInDeadline;
  final String? mobileId;
  final String? masterLeaveName;
  final LocationModel? timeInLocation;
  final LocationModel? timeOutLocation;

  PresenceModel({
    required this.id,
    required this.masterCompanyId,
    required this.masterEmployeeId,
    this.timeInLocationId,
    this.timeOutLocationId,
    this.latitude,
    this.longitude,
    this.radius,
    this.timeIn,
    this.timeOut,
    this.createdAt,
    this.updatedAt,
    this.late,
    this.startBreak,
    this.endBreak,
    this.reason,
    this.setupTimeIn,
    this.setupTimeInDeadline,
    this.mobileId,
    this.masterLeaveName,
    this.timeInLocation,
    this.timeOutLocation,
  });

  bool get isLate => (late != null && late! < 0) || (reason != null && reason!.toLowerCase().contains('telat'));
  int get lateMinutes => (late != null && late! < 0) ? late!.abs() : 0;
  bool get hasCheckedIn => timeIn != null && timeIn!.isNotEmpty;
  bool get hasCheckedOut => timeOut != null && timeOut!.isNotEmpty;

  String get dateString {
    if (createdAt != null && createdAt!.length >= 10) {
      return createdAt!.substring(0, 10);
    }
    return '-';
  }

  String get locationName => timeInLocation?.name ?? timeOutLocation?.name ?? 'PKP HO';

  factory PresenceModel.fromJson(Map<String, dynamic> json) {
    return PresenceModel(
      id: json['id'] as int? ?? 0,
      masterCompanyId: json['master_company_id'] as int? ?? 1,
      masterEmployeeId: json['master_employee_id'] as int? ?? 0,
      timeInLocationId: json['time_in_location_id'] as int?,
      timeOutLocationId: json['time_out_location_id'] as int?,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      radius: json['radius']?.toString(),
      timeIn: json['time_in'] as String?,
      timeOut: json['time_out'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      late: json['late'] as int?,
      startBreak: json['start_break'] as String?,
      endBreak: json['end_break'] as String?,
      reason: json['reason'] as String?,
      setupTimeIn: json['setup_time_in'] as String?,
      setupTimeInDeadline: json['setup_time_in_dl'] as String?,
      mobileId: json['mobile_id'] as String?,
      masterLeaveName: json['master_leave_name'] as String?,
      timeInLocation: json['time_in_location'] != null
          ? LocationModel.fromJson(json['time_in_location'] as Map<String, dynamic>)
          : null,
      timeOutLocation: json['time_out_location'] != null
          ? LocationModel.fromJson(json['time_out_location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'master_company_id': masterCompanyId,
      'master_employee_id': masterEmployeeId,
      'time_in_location_id': timeInLocationId,
      'time_out_location_id': timeOutLocationId,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'time_in': timeIn,
      'time_out': timeOut,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'late': late,
      'start_break': startBreak,
      'end_break': endBreak,
      'reason': reason,
      'setup_time_in': setupTimeIn,
      'setup_time_in_dl': setupTimeInDeadline,
      'mobile_id': mobileId,
      'master_leave_name': masterLeaveName,
      'time_in_location': timeInLocation?.toJson(),
      'time_out_location': timeOutLocation?.toJson(),
    };
  }
}
