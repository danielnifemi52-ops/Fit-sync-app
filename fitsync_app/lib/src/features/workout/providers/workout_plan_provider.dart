import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/claude_service.dart';
import '../../../core/models/user_data.dart';
import '../../nutrition/providers/meal_plan_provider.dart'; // Reuse claudeServiceProvider

final workoutPlanProvider =
    NotifierProvider<WorkoutPlanNotifier, AsyncValue<Map<String, dynamic>?>>(
      WorkoutPlanNotifier.new,
    );

class WorkoutPlanNotifier extends Notifier<AsyncValue<Map<String, dynamic>?>> {
  late final ClaudeService _claude;

  @override
  AsyncValue<Map<String, dynamic>?> build() {
    _claude = ref.read(claudeServiceProvider);
    return const AsyncData(null);
  }

  Future<void> generatePlan(UserData user) async {
    state = const AsyncLoading();

    // Construct prompt
    final prompt =
        '''
    Generate a 4-day/week workout plan as JSON:
    - Goal: ${user.goal}
    - Equipment: Gym
    - Experience: intermediate

    Format:
    {
      "monday": {
        "name": "Upper Body Push",
        "exercises": [
          {
            "name": "Barbell Bench Press",
            "sets": 4,
            "reps": "8-10",
            "rest": 120,
            "notes": "Control the descent"
          }
        ]
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
