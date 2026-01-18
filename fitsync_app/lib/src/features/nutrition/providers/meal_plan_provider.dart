import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/claude_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_data.dart';
import '../providers/nutrition_provider.dart';

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
  late final StorageService _storage;

  @override
  AsyncValue<Map<String, dynamic>?> build() {
    _claude = ref.read(claudeServiceProvider);
    _storage = ref.read(storageServiceProvider);
    _loadPersistedPlan();
    return const AsyncData(null);
  }

  Future<void> _loadPersistedPlan() async {
    state = const AsyncLoading();
    try {
      final plan = await _storage.loadMealPlan();
      state = AsyncData(plan);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> generatePlan(UserData user, {String? adjustmentReason}) async {
    state = const AsyncLoading();

    final prompt =
        '''
    Generate a highly personalized 7-day meal plan as JSON.
    - Goal: ${user.goal}
    - Daily calories: ${user.targetCalories} kcal
    - Macros: Protein ${user.targetProtein}g, Carbs ${user.targetCarbs}g, Fat ${user.targetFat}g
    - Diet Preference: ${user.dietType}
    - Activity Level: ${user.activityLevel}

    Format the response as a valid JSON object with days of the week as keys (monday, tuesday, etc.). 
    Include a "meta" key with:
    - adjustment_explanation (String - A brief, supportive explanation of what changed in the plan to help the user recover their targets, or a general welcome if it's a new plan).

    Each day should contain "breakfast", "lunch", and "dinner" objects with:
    - name (String)
    - calories (int)
    - protein (int)
    - carbs (int)
    - fat (int)
    - ingredients (List of Strings)
    - portion_guidance (String - scientific or practical advice on serving size)
    - substitutions (List of Strings - simple alternatives for common ingredients)

    ${adjustmentReason != null ? "IMPORTANT: The user has missed their recent targets because: $adjustmentReason. Adjust this new plan to be easier to follow or to compensate for these misses without being too restrictive." : ""}

    Strictly return ONLY the JSON object.
    ''';

    try {
      final result = await _claude.generateSimpleResponse(prompt);
      await _storage.saveMealPlan(result);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
