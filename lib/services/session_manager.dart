import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  // Save session to SharedPreferences
  Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, user.token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  // Get active JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Get logged in user profile
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonStr = prefs.getString(_keyUser);
    if (userJsonStr == null || userJsonStr.isEmpty) return null;

    try {
      final Map<String, dynamic> userMap = jsonDecode(userJsonStr);
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  // Check if session is authenticated
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear session (Logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}
