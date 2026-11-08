import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/presence_model.dart';
import '../services/presence_service.dart';

class PresenceProvider extends ChangeNotifier {
  final PresenceService _presenceService;

  List<PresenceModel> _presences = [];
  PresenceModel? _todayPresence;
  bool _isLoading = false;
  String? _errorMessage;

  late String _fromDate;
  late String _toDate;

  PresenceProvider({PresenceService? presenceService})
      : _presenceService = presenceService ?? PresenceService() {
    final now = DateTime.now();
    // Default to start of current month until end of current month
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    _fromDate = DateFormat('yyyy-MM-dd').format(firstDay);
    _toDate = DateFormat('yyyy-MM-dd').format(lastDay);
  }

  List<PresenceModel> get presences => _presences;
  PresenceModel? get todayPresence => _todayPresence;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get fromDate => _fromDate;
  String get toDate => _toDate;

  // Stats
  int get totalPresent => _presences.length;
  int get totalLate => _presences.where((p) => p.isLate).length;
  int get totalOnTime => totalPresent - totalLate;

  /// Ambil data presensi berdasarkan rentang tanggal
  Future<void> fetchPresences({
    required int employeeId,
    required String token,
    String? from,
    String? to,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (from != null) _fromDate = from;
    if (to != null) _toDate = to;

    final response = await _presenceService.getPresences(
      employeeId: employeeId,
      token: token,
      fromDate: _fromDate,
      toDate: _toDate,
    );

    _isLoading = false;

    if (response.isSuccess) {
      _presences = response.presences;
      _errorMessage = null;

      // Check if any presence matches today
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      try {
        _todayPresence = _presences.firstWhere(
          (p) => p.dateString == todayStr,
        );
      } catch (_) {
        // If no entry for today, take latest if within range or null
        _todayPresence = _presences.isNotEmpty ? _presences.first : null;
      }
    } else {
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  /// Khusus ambil presensi hari ini
  Future<void> fetchTodayPresence({
    required int employeeId,
    required String token,
  }) async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await _presenceService.getPresences(
      employeeId: employeeId,
      token: token,
      fromDate: todayStr,
      toDate: todayStr,
      pageSize: 10,
    );

    if (response.isSuccess && response.presences.isNotEmpty) {
      _todayPresence = response.presences.first;
      notifyListeners();
    }
  }
}
