import 'user_model.dart';

class LoginResponse {
  final int statusCode;
  final String message;
  final UserModel? data;

  LoginResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  bool get isSuccess => statusCode == 1 && data != null;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      statusCode: json['status_code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
