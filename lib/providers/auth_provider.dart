import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SessionManager _sessionManager;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    AuthService? authService,
    SessionManager? sessionManager,
  })  : _authService = authService ?? AuthService(),
        _sessionManager = sessionManager ?? SessionManager();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Inisialisasi dan cek sesi login yang tersimpan
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedUser = await _sessionManager.getUser();
      if (savedUser != null && savedUser.token.isNotEmpty) {
        _currentUser = savedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Eksekusi Login
  Future<bool> login({
    required String email,
    required String password,
    String? appId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.login(
      email: email,
      password: password,
      appId: appId,
    );

    _isLoading = false;

    if (response.isSuccess && response.data != null) {
      _currentUser = response.data;
      await _sessionManager.saveSession(response.data!);
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message.isNotEmpty
          ? response.message
          : 'Login gagal. Silakan periksa kembali email dan password.';
      notifyListeners();
      return false;
    }
  }

  /// Logout user dan hapus session
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _sessionManager.clearSession();
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Bersihkan pesan error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
