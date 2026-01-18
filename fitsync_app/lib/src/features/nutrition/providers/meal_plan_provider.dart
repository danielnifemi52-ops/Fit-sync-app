import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/claude_service.dart';
import '../../../core/models/user_data.dart';

// Simple provider for ClaudeService
final claudeServiceProvider = Provider((ref) => ClaudeService());

// State for the Meal Plan (Map for JSON structure or a proper Model)
// For MVP, using dynamic Map from JSON
final mealPlanProvider =
    NotifierProvider<MealPlanNotifier, AsyncValue<Map<String, dynamic>?>>(
      MealPlanNotifier.new,
    );

class MealPlanNotifier extends Notifier<AsyncValue<Map<String, dynamic>?>> {
  late final ClaudeService _claude;

  @override
  AsyncValue<Map<String, dynamic>?> build() {
    _claude = ref.read(claudeServiceProvider);
    return const AsyncData(null);
  }

  Future<void> generatePlan(UserData user) async {
    state = const AsyncLoading();

    // Construct prompt based on user data
    final prompt =
        '''
    Generate a 7-day meal plan as JSON:
    - Goal: ${user.goal}
    - Daily calories: ${user.targetCalories}
    - Protein: ${user.targetProtein}g
    - Carbs: ${user.targetCarbs}g
    - Fat: ${user.targetFat}g
    - Diet: ${user.dietType}
    - 3 meals/day

    Format:
    {
      "monday": {
        "breakfast": {
          "name": "Protein Oatmeal",
          "calories": 400,
          "protein": 30,
          "carbs": 45,
          "fat": 12,
          "ingredients": ["oats", "protein powder", "banana"]
        },
        ...
      }
    }
    ''';

    try {
      final result = await _claude.generateSimpleResponse(prompt);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
