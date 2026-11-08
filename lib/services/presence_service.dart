import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/presence_response.dart';

class PresenceService {
  final http.Client _client;

  PresenceService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data presensi dari http://149.129.246.92:83/presences
  Future<PresenceResponse> getPresences({
    required int employeeId,
    required String token,
    required String fromDate,
    required String toDate,
    int pageSize = 1000,
  }) async {
    final queryParams = {
      'master_employee_id': employeeId.toString(),
      'pageSize': pageSize.toString(),
      'from': fromDate,
      'to': toDate,
    };

    final uri = Uri.parse(ApiConstants.presencesEndpoint).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(ApiConstants.timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        return PresenceResponse.fromJson(responseData);
      } else {
        return PresenceResponse(
          statusCode: response.statusCode,
          message: 'Gagal memuat data presensi (HTTP ${response.statusCode})',
        );
      }
    } on SocketException {
      return PresenceResponse(
        statusCode: 0,
        message: 'Koneksi ke server presensi terputus.',
      );
    } on TimeoutException {
      return PresenceResponse(
        statusCode: 0,
        message: 'Waktu permintaan habis saat memuat presensi.',
      );
    } catch (e) {
      return PresenceResponse(
        statusCode: 0,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }
}
