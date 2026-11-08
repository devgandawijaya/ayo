import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Melakukan login ke endpoint http://149.129.246.92:83/auth/login
  Future<LoginResponse> login({
    required String email,
    required String password,
    String? appId,
  }) async {
    final effectiveAppId = (appId != null && appId.trim().isNotEmpty)
        ? appId.trim()
        : ApiConstants.defaultAppId;

    final requestBody = LoginRequest(
      email: email.trim(),
      password: password,
      appId: effectiveAppId,
    );

    try {
      final response = await _client
          .post(
            Uri.parse(ApiConstants.loginEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody.toJson()),
          )
          .timeout(ApiConstants.timeoutDuration);

      final Map<String, dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(responseData);
      } else {
        final message = responseData['message'] as String? ??
            'Login gagal dengan kode HTTP ${response.statusCode}';
        return LoginResponse(
          statusCode: responseData['status_code'] as int? ?? 0,
          message: message,
          data: null,
        );
      }
    } on SocketException {
      return LoginResponse(
        statusCode: 0,
        message:
            'Tidak dapat terhubung ke server (149.129.246.92:83). Periksa koneksi internet Anda.',
        data: null,
      );
    } on TimeoutException {
      return LoginResponse(
        statusCode: 0,
        message: 'Koneksi waktu habis (Timeout). Server tidak merespons.',
        data: null,
      );
    } on FormatException {
      return LoginResponse(
        statusCode: 0,
        message: 'Format respon dari server tidak valid.',
        data: null,
      );
    } catch (e) {
      return LoginResponse(
        statusCode: 0,
        message: 'Terjadi kesalahan sistem: $e',
        data: null,
      );
    }
  }
}
