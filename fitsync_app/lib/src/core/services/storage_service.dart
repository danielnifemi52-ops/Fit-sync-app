import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userDataKey = 'userData';
  static const String _dailyLogKey = 'dailyLog';
  static const String _mealPlanKey = 'mealPlan';

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

  Future<void> saveMealPlan(Map<String, dynamic> plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mealPlanKey, jsonEncode(plan));
  }

  Future<Map<String, dynamic>?> loadMealPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_mealPlanKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Historical weight logs
  Future<void> saveWeightLog(double weight, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await loadWeightLogs();

    logs.add({'weight': weight, 'date': date.toIso8601String()});

    // Keep only last 30 days
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    logs.removeWhere((log) => DateTime.parse(log['date']).isBefore(cutoffDate));

    await prefs.setString('weightLogs', jsonEncode(logs));
  }

  Future<List<Map<String, dynamic>>> loadWeightLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('weightLogs');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Historical calorie logs
  Future<void> saveCalorieLog(int calories, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await loadCalorieLogs();

    // Update or add today's log
    final dateStr = date.toIso8601String().split('T')[0];
    logs.removeWhere((log) => log['date'].toString().startsWith(dateStr));

    logs.add({'calories': calories, 'date': date.toIso8601String()});

    // Keep only last 30 days
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    logs.removeWhere((log) => DateTime.parse(log['date']).isBefore(cutoffDate));

    await prefs.setString('calorieLogs', jsonEncode(logs));
  }

  Future<List<Map<String, dynamic>>> loadCalorieLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('calorieLogs');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
