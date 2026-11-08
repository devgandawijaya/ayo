import 'presence_model.dart';

class PresenceResponse {
  final int statusCode;
  final String message;
  final int total;
  final int page;
  final int pageSize;
  final List<PresenceModel> presences;

  PresenceResponse({
    required this.statusCode,
    required this.message,
    this.total = 0,
    this.page = 1,
    this.pageSize = 1000,
    this.presences = const [],
  });

  bool get isSuccess => statusCode == 1;

  factory PresenceResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<PresenceModel> list = [];
    int total = 0;
    int page = 1;
    int pageSize = 1000;

    if (rawData is Map<String, dynamic>) {
      total = int.tryParse(rawData['total']?.toString() ?? '0') ?? 0;
      page = int.tryParse(rawData['page']?.toString() ?? '1') ?? 1;
      pageSize = int.tryParse(rawData['page_size']?.toString() ?? '1000') ?? 1000;

      final rawList = rawData['data'];
      if (rawList is List) {
        list = rawList
            .map((item) => PresenceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return PresenceResponse(
      statusCode: json['status_code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      total: total,
      page: page,
      pageSize: pageSize,
      presences: list,
    );
  }
}
