import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../nutrition/providers/nutrition_provider.dart';
import '../nutrition/widgets/meals_list.dart';
import '../nutrition/widgets/log_meal_modal.dart';
import '../nutrition/screens/meal_plan_screen.dart';
import '../workout/screens/workout_plan_screen.dart';
import 'widgets/weight_log_modal.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macros = ref.watch(totalMacrosProvider);
    final weight = ref.watch(weightProvider);
    // ...
    // In main column, add weight card/row
    // We'll replace the placeholder or add it below summary
    // Hardcoded targets for MVP
    const targetCalories = 2000;
    const targetProtein = 150;
    const targetCarbs = 200;
    const targetFat = 65;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitSync Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCard(
                context,
                macros,
                targetCalories,
                targetProtein,
                targetCarbs,
                targetFat,
              ),
              const SizedBox(height: 16),
              _buildWeightCard(context, weight),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Meals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const MealsList(),
              const SizedBox(height: 24),
              _buildPremiumFeatureCard(
                context,
                'AI Meal Plan',
                Icons.restaurant_menu,
              ),
              const SizedBox(height: 12),
              _buildPremiumFeatureCard(
                context,
                'AI Workout Plan',
                Icons.fitness_center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const LogMealModal(),
          );
        },
        label: const Text('Log Meal'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    Map<String, int> current,
    int tCal,
    int tProt,
    int tCarb,
    int tFat,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Daily Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              context,
              'Calories',
              current['calories']!,
              tCal,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProgressBar(
                    context,
                    'Protein',
                    current['protein']!,
                    tProt,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressBar(
                    context,
                    'Carbs',
                    current['carbs']!,
                    tCarb,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressBar(
                    context,
                    'Fat',
                    current['fat']!,
                    tFat,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String label,
    int current,
    int target,
    Color color,
  ) {
    final double progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '$current / $target',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildPremiumFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Card(
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        trailing: const Icon(Icons.lock, color: Colors.purple),
        subtitle: const Text(
          'Upgrade for AI-generated plans',
          style: TextStyle(fontSize: 12),
        ),
        onTap: () {
          if (title == 'AI Meal Plan') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MealPlanScreen()),
            );
          } else if (title == 'AI Workout Plan') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutPlanScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Premium feature coming soon!')),
            );
          }
        },
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, double? weight) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.monitor_weight, color: Colors.blue),
        title: Text(
          weight != null ? '$weight kg' : 'Log Weight',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Current Weight'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const WeightLogModal(),
            );
          },
        ),
      ),
    );
  }
}
