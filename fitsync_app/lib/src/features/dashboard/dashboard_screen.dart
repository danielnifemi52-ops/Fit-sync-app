import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../nutrition/providers/nutrition_provider.dart';
import '../nutrition/widgets/meals_list.dart';
import '../nutrition/widgets/log_meal_modal.dart';
import '../nutrition/screens/meal_plan_screen.dart';
import '../workout/screens/workout_plan_screen.dart';
import 'widgets/weight_log_modal.dart';
import 'widgets/enhanced_ai_coach_card.dart';
import 'widgets/weekly_summary_card.dart';
import '../../core/providers/user_data_provider.dart';
import '../../core/widgets/premium_background.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macros = ref.watch(totalMacrosProvider);
    final weight = ref.watch(weightProvider);
    final userData = ref.watch(userDataProvider);

    // Use calculated targets from user data
    final targetCalories = userData.targetCalories;
    final targetProtein = userData.targetProtein;
    final targetCarbs = userData.targetCarbs;
    final targetFat = userData.targetFat;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'FitSync',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  const SizedBox(height: 16),
                  const EnhancedAiCoachCard(),
                  const SizedBox(height: 16),
                  const WeeklySummaryCard(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Meals',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const LogMealModal(),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E1A47),
        label: const Text(
          'Log Meal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Daily Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            Text(
              '$current / $target',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildPremiumFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      opacity: 0.1,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        subtitle: Text(
          'View your personalized plan',
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
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
          }
        },
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, double? weight) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.monitor_weight, color: Colors.white),
        title: Text(
          weight != null ? '$weight kg' : 'Log Weight',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Current Weight',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const WeightLogModal(),
            );
          },
        ),
      ),
    );
  }
}
