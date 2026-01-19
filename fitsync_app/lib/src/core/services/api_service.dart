import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // TODO: Replace with your Firebase Cloud Functions URL
  static const String baseUrl =
      'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api';

  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return await user.getIdToken() ?? '';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Meal Plan APIs
  Future<Map<String, dynamic>> generateMealPlan({
    String? adjustmentReason,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/meal-plan/generate'),
      headers: headers,
      body: jsonEncode({
        if (adjustmentReason != null) 'adjustmentReason': adjustmentReason,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to generate meal plan');
    }
  }

  Future<Map<String, dynamic>> swapMeal({
    required String planId,
    required String day,
    required String mealType,
    required Map<String, dynamic> currentMeal,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/meal-plan/swap-meal'),
      headers: headers,
      body: jsonEncode({
        'planId': planId,
        'day': day,
        'mealType': mealType,
        'currentMeal': currentMeal,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to swap meal');
    }
  }

  Future<Map<String, dynamic>?> getCurrentMealPlan() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/meal-plan/current'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['plan'];
    } else {
      throw Exception('Failed to fetch meal plan');
    }
  }

  // Workout Plan APIs
  Future<Map<String, dynamic>> generateWorkoutPlan({
    String? adjustmentReason,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/workout-plan/generate'),
      headers: headers,
      body: jsonEncode({
        if (adjustmentReason != null) 'adjustmentReason': adjustmentReason,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to generate workout plan');
    }
  }

  Future<Map<String, dynamic>> swapExercise({
    required String planId,
    required String day,
    required Map<String, dynamic> currentExercise,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/workout-plan/swap-exercise'),
      headers: headers,
      body: jsonEncode({
        'planId': planId,
        'day': day,
        'currentExercise': currentExercise,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to swap exercise');
    }
  }

  Future<Map<String, dynamic>?> getCurrentWorkoutPlan() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/workout-plan/current'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['plan'];
    } else {
      throw Exception('Failed to fetch workout plan');
    }
  }

  // AI Coach APIs
  Future<String> getAICoachInsight({
    required Map<String, dynamic> weightTrend,
    required Map<String, dynamic> calorieAdherence,
    required Map<String, dynamic> workoutAdherence,
    required int todayCalories,
    required Map<String, dynamic> todayMacros,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/ai-coach/insight'),
      headers: headers,
      body: jsonEncode({
        'weightTrend': weightTrend,
        'calorieAdherence': calorieAdherence,
        'workoutAdherence': workoutAdherence,
        'todayCalories': todayCalories,
        'todayMacros': todayMacros,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['insight'];
    } else {
      throw Exception('Failed to get AI insight');
    }
  }

  Future<String> getPlateauAnalysis() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/ai-coach/plateau-analysis'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['analysis'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get plateau analysis');
    }
  }

  // Progress APIs
  Future<void> logWeight(double weight, DateTime date) async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse('$baseUrl/progress/log-weight'),
      headers: headers,
      body: jsonEncode({'weight': weight, 'date': date.toIso8601String()}),
    );
  }

  Future<void> logCalories({
    required int totalCalories,
    required int protein,
    required int carbs,
    required int fat,
    required List<Map<String, dynamic>> meals,
    required DateTime date,
  }) async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse('$baseUrl/progress/log-calories'),
      headers: headers,
      body: jsonEncode({
        'totalCalories': totalCalories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'meals': meals,
        'date': date.toIso8601String(),
      }),
    );
  }

  Future<void> logWorkout({
    required String day,
    required String workoutName,
    required DateTime date,
  }) async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse('$baseUrl/progress/log-workout'),
      headers: headers,
      body: jsonEncode({
        'day': day,
        'workoutName': workoutName,
        'date': date.toIso8601String(),
      }),
    );
  }

  Future<Map<String, dynamic>> getAnalyticsData() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/progress/analytics'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch analytics data');
    }
  }

  // User APIs
  Future<Map<String, dynamic>> getUserProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final headers = await _getHeaders();
    await http.put(
      Uri.parse('$baseUrl/user/profile'),
      headers: headers,
      body: jsonEncode(updates),
    );
  }

  Future<void> upgradeToPremium() async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse('$baseUrl/user/upgrade-premium'),
      headers: headers,
    );
  }
}
