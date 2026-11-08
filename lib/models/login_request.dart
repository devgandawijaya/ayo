class LoginRequest {
  final String email;
  final String password;
  final String appId;

  LoginRequest({
    required this.email,
    required this.password,
    required this.appId,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'password': password,
      'appId': appId.trim(),
    };
  }
}
