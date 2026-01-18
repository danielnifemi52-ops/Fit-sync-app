import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userDataKey = 'userData';
  static const String _dailyLogKey = 'dailyLog';

  Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_userDataKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> saveDailyLog(Map<String, dynamic> log) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyLogKey, jsonEncode(log));
  }

  Future<Map<String, dynamic>?> loadDailyLog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_dailyLogKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
