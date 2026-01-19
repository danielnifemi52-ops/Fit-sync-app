class ProgressAnalyzer {
  /// Analyze weekly weight trend
  /// Returns change in kg and percentage
  static Map<String, dynamic> analyzeWeeklyWeightTrend({
    required List<Map<String, dynamic>> weightLogs,
  }) {
    if (weightLogs.length < 2) {
      return {
        'change': 0.0,
        'changePercent': 0.0,
        'trend': 'insufficient_data',
        'message': 'Log your weight for at least a week to see trends',
      };
    }

    // Sort by date
    weightLogs.sort(
      (a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
    );

    final latestWeight = weightLogs.last['weight'] as double;
    final oldestWeight = weightLogs.first['weight'] as double;

    final change = latestWeight - oldestWeight;
    final changePercent = (change / oldestWeight) * 100;

    String trend;
    if (change > 0.5) {
      trend = 'gaining';
    } else if (change < -0.5) {
      trend = 'losing';
    } else {
      trend = 'maintaining';
    }

    return {
      'change': change,
      'changePercent': changePercent,
      'trend': trend,
      'latestWeight': latestWeight,
      'oldestWeight': oldestWeight,
      'daysTracked': weightLogs.length,
    };
  }

  /// Calculate average daily calories over a period
  static Map<String, dynamic> analyzeCalorieAdherence({
    required List<Map<String, dynamic>> dailyLogs,
    required int targetCalories,
  }) {
    if (dailyLogs.isEmpty) {
      return {
        'averageCalories': 0,
        'adherencePercent': 0.0,
        'daysOnTarget': 0,
        'totalDays': 0,
      };
    }

    int totalCalories = 0;
    int daysOnTarget = 0;

    for (var log in dailyLogs) {
      final calories = log['totalCalories'] as int? ?? 0;
      totalCalories += calories;

      // Within 10% of target is considered "on target"
      if ((calories - targetCalories).abs() <= targetCalories * 0.1) {
        daysOnTarget++;
      }
    }

    final averageCalories = (totalCalories / dailyLogs.length).round();
    final adherencePercent = (daysOnTarget / dailyLogs.length) * 100;

    return {
      'averageCalories': averageCalories,
      'adherencePercent': adherencePercent,
      'daysOnTarget': daysOnTarget,
      'totalDays': dailyLogs.length,
      'calorieDeficit': targetCalories - averageCalories,
    };
  }

  /// Explain why user is gaining/losing/maintaining
  static String explainProgress({
    required String weightTrend,
    required int averageCalories,
    required int targetCalories,
    required String goal,
  }) {
    final calorieDeficit = targetCalories - averageCalories;

    if (weightTrend == 'insufficient_data') {
      return 'Keep logging your weight and meals to see your progress trends.';
    }

    // Losing weight
    if (weightTrend == 'losing') {
      if (goal == 'lose_weight') {
        if (calorieDeficit > 0) {
          return 'Great! You\'re losing weight because you\'re eating ${calorieDeficit.abs()} calories below your target. Keep it up!';
        } else {
          return 'You\'re losing weight even though you\'re eating ${calorieDeficit.abs()} calories over target. This might be water weight or increased activity.';
        }
      } else if (goal == 'gain_muscle') {
        return 'You\'re losing weight, but your goal is to gain. Try eating ${(calorieDeficit.abs() + 500)} more calories per day.';
      } else {
        return 'You\'re losing weight. If you want to maintain, increase calories by ${calorieDeficit.abs()} per day.';
      }
    }

    // Gaining weight
    if (weightTrend == 'gaining') {
      if (goal == 'gain_muscle') {
        if (calorieDeficit < 0) {
          return 'Perfect! You\'re gaining weight by eating ${calorieDeficit.abs()} calories above your target. Continue this surplus!';
        } else {
          return 'You\'re gaining weight even though you\'re eating ${calorieDeficit.abs()} calories below target. Consider adjusting your activity level.';
        }
      } else if (goal == 'lose_weight') {
        return 'You\'re gaining weight. To lose, reduce calories by ${(calorieDeficit.abs() + 500)} per day.';
      } else {
        return 'You\'re gaining weight. To maintain, reduce calories by ${calorieDeficit.abs()} per day.';
      }
    }

    // Maintaining
    if (goal == 'maintain') {
      return 'You\'re maintaining your weight perfectly! Your calorie intake is balanced.';
    } else if (goal == 'lose_weight') {
      return 'Your weight hasn\'t changed. To lose weight, reduce calories by 300-500 per day.';
    } else {
      return 'Your weight hasn\'t changed. To gain muscle, increase calories by 300-500 per day.';
    }
  }

  /// Calculate expected weekly weight change based on calorie deficit
  /// 3500 calories = 1 lb (0.45 kg)
  static double predictWeeklyWeightChange({required int dailyCalorieDeficit}) {
    final weeklyDeficit = dailyCalorieDeficit * 7;
    final poundsPerWeek = weeklyDeficit / 3500;
    final kgPerWeek = poundsPerWeek * 0.45;
    return kgPerWeek;
  }

  /// Calculate workout adherence over the last 7 days
  static Map<String, dynamic> analyzeWorkoutAdherence({
    required List<Map<String, dynamic>> workoutLogs,
    required int weeklyTarget,
  }) {
    if (weeklyTarget == 0) {
      return {'adherencePercent': 0.0, 'completed': 0, 'target': weeklyTarget};
    }

    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));

    int completed = 0;
    for (var log in workoutLogs) {
      final date = DateTime.parse(log['date']);
      if (date.isAfter(last7Days)) {
        completed++;
      }
    }

    final adherencePercent = (completed / weeklyTarget) * 100;

    return {
      'adherencePercent': adherencePercent.clamp(0.0, 100.0),
      'completed': completed,
      'target': weeklyTarget,
    };
  }
}
