import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/caregiver_models.dart';

class CaregiverLocalDataSource {
  static const String _tokenKey = 'memoryguide_caregiver_token';
  static const String _userKey = 'memoryguide_caregiver_user';

  Future<void> saveSession({
    required String token,
    required CaregiverUser user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<CaregiverUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    try {
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      return CaregiverUser.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
