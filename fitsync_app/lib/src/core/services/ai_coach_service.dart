import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';
import 'progress_analyzer.dart';

class AiCoachService {
  AiCoachService();

  Future<String> generateInsight({
    required UserData userData,
    required List<Map<String, dynamic>> weightLogs,
    required List<Map<String, dynamic>> dailyLogs,
    required List<Map<String, dynamic>> workoutLogs,
    required int todayCalories,
    required Map<String, int> todayMacros,
  }) async {
    // 1. Analyze 7-day trends
    final weightTrend = ProgressAnalyzer.analyzeWeeklyWeightTrend(
      weightLogs: weightLogs.length >= 7
          ? weightLogs.sublist(weightLogs.length - 7)
          : weightLogs,
    );

    final calorieAdherence = ProgressAnalyzer.analyzeCalorieAdherence(
      dailyLogs: dailyLogs.length >= 7
          ? dailyLogs.sublist(dailyLogs.length - 7)
          : dailyLogs,
      targetCalories: userData.targetCalories,
    );

    final workoutAdherence = ProgressAnalyzer.analyzeWorkoutAdherence(
      workoutLogs: workoutLogs,
      weeklyTarget: userData.weeklyAvailability ?? 0,
    );

    // 2. Prepare reasoning data for the LLM
    final reasoningContext = {
      'user_profile': {
        'goal': userData.goal,
        'current_weight': userData.currentWeight,
        'target_weight': userData.targetWeight,
        'activity_level': userData.activityLevel,
        'target_calories': userData.targetCalories,
        'is_premium': userData.isPremium,
      },
      'recent_performance': {
        'average_calories_last_7_days': calorieAdherence['averageCalories'],
        'adherence_percent': calorieAdherence['adherencePercent'],
        'workout_adherence_percent': workoutAdherence['adherencePercent'],
        'weight_change_7_days': weightTrend['change'],
        'weight_trend_status': weightTrend['trend'],
      },
      'today_so_far': {'calories': todayCalories, 'macros': todayMacros},
    };

    final prompt = _buildCoachPrompt(reasoningContext);

    try {
      return await _getCoachResponse(prompt, isPremium: userData.isPremium);
    } catch (e) {
      return ProgressAnalyzer.explainProgress(
        weightTrend: weightTrend['trend'],
        averageCalories: calorieAdherence['averageCalories'] as int,
        targetCalories: userData.targetCalories,
        goal: userData.goal,
      );
    }
  }

  Future<String> generatePlateauAnalysis({
    required UserData userData,
    required List<Map<String, dynamic>> weightLogs,
    required List<Map<String, dynamic>> dailyLogs,
    required List<Map<String, dynamic>> workoutLogs,
  }) async {
    final fourteenDayLogs = weightLogs.length >= 14
        ? weightLogs.sublist(weightLogs.length - 14)
        : weightLogs;

    final trend = ProgressAnalyzer.analyzeWeeklyWeightTrend(
      weightLogs: fourteenDayLogs,
    );
    final calorieAdherence = ProgressAnalyzer.analyzeCalorieAdherence(
      dailyLogs: dailyLogs,
      targetCalories: userData.targetCalories,
    );
    final workoutAdherence = ProgressAnalyzer.analyzeWorkoutAdherence(
      workoutLogs: workoutLogs,
      weeklyTarget: userData.weeklyAvailability ?? 0,
    );

    final prompt =
        """
Analyze plateau for ${userData.goal}:
- 14-day weight change: ${trend['change']}kg
- Nutrition adherence: ${calorieAdherence['adherencePercent']}%
- Workout adherence: ${workoutAdherence['adherencePercent']}%
""";

    return await _getCoachResponse(prompt, isPlateauAction: true);
  }

  String _buildCoachPrompt(Map<String, dynamic> context) {
    final bool isPremium = context['user_profile']['is_premium'] ?? false;

    if (!isPremium) {
      return "Basic insight: Stay consistent with your ${context['recent_performance']['adherence_percent'] > 80 ? 'excellent logging' : 'daily logs'} to see results. Upgrade to Premium for deep analysis.";
    }

    final scenario = _analyzeAdherenceScenario(context);

    return """
### 🧠 Reasoning
${context['recent_performance']['weight_trend_status'] == 'insufficient_data' ? '*Insufficient data to determine a trend yet.*' : 'You are in a **${context['recent_performance']['weight_trend_status']}** phase. Calorie adherence: **${context['recent_performance']['adherence_percent'].toStringAsFixed(0)}%**, Workout adherence: **${context['recent_performance']['workout_adherence_percent'].toStringAsFixed(0)}%**.'}

### 💡 Daily Insight
$scenario

### 🎯 Actionable Tip
**Precision Macro Correction:** You've hit ${context['today_so_far']['macros']['protein']}g of protein. Ensure your final meal includes complex carbs to facilitate muscle glycogen replenishment without spiking insulin unnecessarily.
""";
  }

  String _analyzeAdherenceScenario(Map<String, dynamic> context) {
    final nutrition = context['recent_performance']['adherence_percent'] ?? 0.0;
    final training =
        context['recent_performance']['workout_adherence_percent'] ?? 0.0;
    final trend = context['recent_performance']['weight_trend_status'];
    final goal = context['user_profile']['goal'];

    // Detect "Unexpected Changes"
    if (nutrition > 85 && trend == 'gaining' && goal == 'lose_weight') {
      return "Unexpected weight increase detected despite high calorie adherence. This is likely **temporary water retention** due to cortisol or glycogen storage from your consistent training. Stay the course; the scale will catch up.";
    }

    if (nutrition > 85 && trend == 'losing' && goal == 'gain_muscle') {
      return "Unexpected weight loss despite following your muscle-building nutrition. Your high activity level or metabolic rate might be higher than estimated. Consider a **200-calorie bump** in your target to support growth.";
    }

    if (nutrition > 85 && training > 85) {
      return "Perfect synergy! Your nutrition and training are perfectly aligned with your $goal goal. This consistency is the primary driver of your current ${trend == 'losing'
          ? 'fat loss'
          : trend == 'gaining'
          ? 'muscle growth'
          : 'maintenance'}.";
    }

    if (nutrition < 70 && training > 85) {
      return "Your training is strong, which is currently buffering the impact of your nutrition fluctuations. While you're staying active, tightening your calorie adherence will accelerate your $goal significantly.";
    }

    if (nutrition > 85 && training < 70) {
      return "Your nutrition is spot-on, but your training consistency has dipped. Since your goal is $goal, prioritizing your workouts will ensure you're preserving lean mass while your body fat changes.";
    }

    if (nutrition < 70 && training < 70) {
      return "You're in a bit of a consistency dip. It's difficult to see clear progress when both variables are fluctuating. Let's focus on hitting just one target—either calories or workouts—consistently for the next 3 days.";
    }

    return "You're on the right track. Prioritize consistency in your ${nutrition < training ? 'nutrition' : 'workouts'} to break through current plateaus and optimize your $goal.";
  }

  Future<String> _getCoachResponse(
    String prompt, {
    bool isPremium = false,
    bool isPlateauAction = false,
  }) async {
    if (isPlateauAction) {
      return """
### 🔍 Plateau Diagnosis
Your weight has remained stable for 14 days despite relatively high adherence. This is often a sign of **metabolic adaptation** or temporary **water retention** due to inflammation from workouts.

### 🚀 Next Steps
1. **Strategic Refeed:** Increase carbs by 50g for two days to reset leptin levels.
2. **Step Count Check:** Ensure your non-exercise activity (NEAT) hasn't subconsciously dropped.
3. **Double-Down on Protein:** Maintain high protein to preserve lean mass during this stall.
""";
    }

    return prompt; // Prompt now contains the full reasoning for Premium users
  }
}

final aiCoachServiceProvider = Provider((ref) {
  return AiCoachService();
});
