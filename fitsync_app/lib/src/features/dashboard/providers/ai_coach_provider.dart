import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/claude_service.dart';
import '../../../core/services/progress_analyzer.dart';
import '../../nutrition/providers/nutrition_provider.dart';

final claudeServiceProviderForCoach = Provider((ref) => ClaudeService());

final aiCoachInsightProvider = FutureProvider<String>((ref) async {
  final dailyLog = ref.watch(dailyLogProvider);
  final meals = dailyLog['meals'] as List;
  final weight = dailyLog['weight'] as double?;

  // Calculate total calories for today
  int totalCalories = 0;
  for (var meal in meals) {
    totalCalories += (meal as dynamic).calories as int;
  }

  // Mock weekly data for now (in production, this would come from storage)
  // For MVP, we'll use simple analysis
  final targetCalories = 2000; // This should come from userData

  // Generate insight based on current data
  String insight;

  if (weight == null) {
    insight =
        "Start by logging your weight to track progress! Aim for consistent meal logging to build the habit.";
  } else if (totalCalories == 0) {
    insight =
        "Log your meals today to see how you're doing! Your current weight is ${weight.toStringAsFixed(1)} kg.";
  } else {
    final calorieDeficit = targetCalories - totalCalories;

    if (calorieDeficit > 500) {
      insight =
          "You're eating $calorieDeficit calories below target. This is great for weight loss, but make sure you're getting enough nutrition!";
    } else if (calorieDeficit > 0) {
      insight =
          "Perfect! You're $calorieDeficit calories below target. At this rate, you could lose about 0.5 kg per week. Keep it up!";
    } else if (calorieDeficit > -200) {
      insight =
          "You're right on target! This is perfect for maintaining your current weight of ${weight.toStringAsFixed(1)} kg.";
    } else {
      insight =
          "You're ${calorieDeficit.abs()} calories over target. This could slow your progress. Try reducing portion sizes or choosing lower-calorie options.";
    }
  }

  return insight;
});

String _generateFallbackInsight(int calories, double? weight) {
  if (weight == null) {
    return "Start by logging your weight to track progress! Aim for ${calories > 0 ? 'consistent' : 'regular'} meal logging to build the habit.";
  }

  if (calories < 1500) {
    return "You're eating light today. Make sure you're getting enough nutrition to fuel your body and maintain energy levels.";
  } else if (calories > 2500) {
    return "High calorie day! If you're trying to lose weight, consider smaller portions or more vegetables to stay in your target range.";
  } else {
    return "You're on track! Keep logging consistently and weigh yourself weekly to monitor trends over time.";
  }
}
