class ConfigurationModel {
  final int id;
  final bool selfie;
  final bool geotagging;
  final String radius;
  final bool fingerprint;
  final int sessionTimeout;

  ConfigurationModel({
    required this.id,
    required this.selfie,
    required this.geotagging,
    required this.radius,
    required this.fingerprint,
    required this.sessionTimeout,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      id: json['id'] as int? ?? 0,
      selfie: json['selfie'] as bool? ?? false,
      geotagging: (json['geotaging'] ?? json['geotagging']) as bool? ?? false,
      radius: json['radius']?.toString() ?? '0',
      fingerprint: json['fingerprint'] as bool? ?? false,
      sessionTimeout: json['session_timeout'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'selfie': selfie,
      'geotaging': geotagging,
      'radius': radius,
      'fingerprint': fingerprint,
      'session_timeout': sessionTimeout,
    };
  }
}
