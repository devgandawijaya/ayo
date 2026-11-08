class ApiConstants {
  static const String baseUrl = 'http://149.129.246.92:83';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String presencesEndpoint = '$baseUrl/presences';

  // Default values
  static const String defaultAppId = '3507398578724';
  
  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 15);
}
