import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/progress_analyzer.dart';
import '../../../core/services/goal_predictor.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/ai_coach_service.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../nutrition/providers/nutrition_provider.dart';

final enhancedAiCoachProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final dailyLog = ref.watch(dailyLogProvider);
  final userData = ref.watch(userDataProvider);
  final storage = ref.read(storageServiceProvider);
  final aiCoach = ref.read(aiCoachServiceProvider);
  final todayMacros = ref.watch(totalMacrosProvider);

  final currentWeight = dailyLog['weight'] as double?;

  // Load historical data
  final weightLogs = await storage.loadWeightLogs();
  final calorieLogs = await storage.loadCalorieLogs();

  // 1. Analyze weekly weight trend
  final weeklyWeightTrend = ProgressAnalyzer.analyzeWeeklyWeightTrend(
    weightLogs: weightLogs.length >= 7
        ? weightLogs.sublist(weightLogs.length - 7)
        : weightLogs,
  );

  // 2. Analyze calorie adherence
  final calorieAdherence = ProgressAnalyzer.analyzeCalorieAdherence(
    dailyLogs: calorieLogs.length >= 7
        ? calorieLogs.sublist(calorieLogs.length - 7)
        : calorieLogs,
    targetCalories: userData.targetCalories,
  );

  // 3. Predict goal completion
  final averageCalories = calorieAdherence['averageCalories'] as int;
  final calorieDeficit = userData.targetCalories - averageCalories;
  final predictedWeeklyChange = ProgressAnalyzer.predictWeeklyWeightChange(
    dailyCalorieDeficit: calorieDeficit,
  );

  Map<String, dynamic>? goalPrediction;
  if (currentWeight != null && userData.targetWeight != null) {
    goalPrediction = GoalPredictor.predictGoalCompletion(
      currentWeight: currentWeight,
      targetWeight: userData.targetWeight!,
      weeklyWeightChange: predictedWeeklyChange,
    );
  }

  // 4. Generate AI Insight using reasoning
  final aiInsight = await aiCoach.generateInsight(
    userData: userData,
    weightLogs: weightLogs,
    dailyLogs: calorieLogs,
    todayCalories: todayMacros['calories']!,
    todayMacros: {
      'protein': todayMacros['protein']!,
      'carbs': todayMacros['carbs']!,
      'fat': todayMacros['fat']!,
    },
  );

  return {
    'insight': aiInsight,
    'weightTrend': weeklyWeightTrend,
    'calorieAdherence': calorieAdherence,
    'goalPrediction': goalPrediction,
    'predictedWeeklyChange': predictedWeeklyChange,
  };
});
