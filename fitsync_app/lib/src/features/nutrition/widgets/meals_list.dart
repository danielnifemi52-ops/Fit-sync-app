import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';

class MealsList extends ConsumerWidget {
  const MealsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);

    if (meals.isEmpty) {
      return const Center(child: Text('No meals logged today'));
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              meal.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${meal.calories} kcal • P: ${meal.protein}g C: ${meal.carbs}g F: ${meal.fat}g',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(dailyLogProvider.notifier).removeMeal(meal.id);
              },
            ),
          ),
        );
      },
    );
  }
}
