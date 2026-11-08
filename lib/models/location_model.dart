class LocationModel {
  final int id;
  final int? masterCompanyId;
  final String name;
  final String? latitude;
  final String? longitude;
  final String? timeIn;
  final String? timeOut;
  final String? timeInDeadline;
  final String? startBreak;
  final String? endBreak;
  final String? minTimeIn;

  LocationModel({
    required this.id,
    this.masterCompanyId,
    required this.name,
    this.latitude,
    this.longitude,
    this.timeIn,
    this.timeOut,
    this.timeInDeadline,
    this.startBreak,
    this.endBreak,
    this.minTimeIn,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int? ?? 0,
      masterCompanyId: json['master_company_id'] as int?,
      name: json['name'] as String? ?? '-',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      timeIn: json['time_in'] as String?,
      timeOut: json['time_out'] as String?,
      timeInDeadline: json['time_in_dl'] as String?,
      startBreak: json['start_break'] as String?,
      endBreak: json['end_break'] as String?,
      minTimeIn: json['min_time_in'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'master_company_id': masterCompanyId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'time_in': timeIn,
      'time_out': timeOut,
      'time_in_dl': timeInDeadline,
      'start_break': startBreak,
      'end_break': endBreak,
      'min_time_in': minTimeIn,
    };
  }
}
