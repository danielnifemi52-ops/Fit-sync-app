import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';
import '../../../core/services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final dailyLogProvider =
    NotifierProvider<DailyLogNotifier, Map<String, dynamic>>(
      DailyLogNotifier.new,
    );

class DailyLogNotifier extends Notifier<Map<String, dynamic>> {
  late final StorageService _storage;

  @override
  Map<String, dynamic> build() {
    _storage = ref.read(storageServiceProvider);
    _loadLog();
    return {'meals': <Meal>[], 'weight': null};
  }

  Future<void> _loadLog() async {
    final log = await _storage.loadDailyLog();
    if (log != null) {
      final List<dynamic> mealsJson = log['meals'] ?? [];
      final meals = mealsJson.map((m) => Meal.fromJson(m)).toList();
      state = {'meals': meals, 'weight': log['weight']};
    }
  }

  Future<void> addMeal(Meal meal) async {
    final currentMeals = List<Meal>.from(state['meals'] as List);
    currentMeals.add(meal);
    state = {...state, 'meals': currentMeals};
    await _saveLog();
  }

  Future<void> removeMeal(String id) async {
    final currentMeals = List<Meal>.from(state['meals'] as List);
    currentMeals.removeWhere((m) => m.id == id);
    state = {...state, 'meals': currentMeals};
    await _saveLog();
  }

  Future<void> logWeight(double weight) async {
    state = {...state, 'weight': weight};
    await _saveLog();
  }

  Future<void> _saveLog() async {
    final meals = state['meals'] as List<Meal>;
    final weight = state['weight'];
    await _storage.saveDailyLog({
      'meals': meals.map((m) => m.toJson()).toList(),
      'weight': weight,
    });
  }
}

final mealsProvider = Provider<List<Meal>>((ref) {
  final log = ref.watch(dailyLogProvider);
  return log['meals'] as List<Meal>;
});

final weightProvider = Provider<double?>((ref) {
  final log = ref.watch(dailyLogProvider);
  return log['weight'] as double?;
});

final totalMacrosProvider = Provider((ref) {
  final meals = ref.watch(mealsProvider);
  int calories = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;

  for (var meal in meals) {
    calories += meal.calories;
    protein += meal.protein;
    carbs += meal.carbs;
    fat += meal.fat;
  }

  return {'calories': calories, 'protein': protein, 'carbs': carbs, 'fat': fat};
});
