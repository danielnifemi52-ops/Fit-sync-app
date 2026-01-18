import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../../core/widgets/premium_background.dart';

class WeeklySummaryCard extends ConsumerWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final weight = ref.watch(weightProvider);
    final macros = ref.watch(totalMacrosProvider);

    // Mock weekly data (in production, this would aggregate from storage)
    final weeklyWeightChange = 0.0; // Would calculate from weight logs
    final averageCalories = macros['calories'] ?? 0;
    final targetCalories = userData.targetCalories;
    final calorieDeficit = targetCalories - averageCalories;

    // Predict weekly weight change based on calorie deficit
    final predictedWeeklyChange =
        (calorieDeficit * 7) / 7700; // 7700 cal = 1 kg

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(calorieDeficit).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(calorieDeficit).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(calorieDeficit, userData.goal),
                  style: TextStyle(
                    color: _getStatusColor(calorieDeficit),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weight Change
          _buildMetricRow(
            context,
            icon: Icons.trending_down,
            iconColor: Colors.blue,
            label: 'Weight Change',
            value: weight != null
                ? '${weeklyWeightChange >= 0 ? '+' : ''}${weeklyWeightChange.toStringAsFixed(1)} kg'
                : 'Log weight to track',
            subtitle: 'This week',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white10),
          ),

          // Calorie Adherence
          _buildMetricRow(
            context,
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            label: 'Daily Average',
            value: '$averageCalories cal',
            subtitle: 'Target: $targetCalories cal',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white10),
          ),

          // Prediction
          _buildMetricRow(
            context,
            icon: Icons.insights,
            iconColor: Colors.purpleAccent,
            label: 'Predicted Change',
            value:
                '${predictedWeeklyChange >= 0 ? '+' : ''}${predictedWeeklyChange.toStringAsFixed(2)} kg/week',
            subtitle: 'Based on current habits',
          ),

          const SizedBox(height: 16),

          // Progress explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getProgressExplanation(calorieDeficit, userData.goal),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(int calorieDeficit) {
    if (calorieDeficit > 300) return Colors.greenAccent;
    if (calorieDeficit > -300) return Colors.blueAccent;
    return Colors.orangeAccent;
  }

  String _getStatusText(int calorieDeficit, String goal) {
    if (goal == 'lose_weight') {
      if (calorieDeficit > 300) return 'On Track';
      if (calorieDeficit > 0) return 'Good Progress';
      return 'Needs Adjustment';
    } else if (goal == 'gain_muscle') {
      if (calorieDeficit < -300) return 'On Track';
      if (calorieDeficit < 0) return 'Good Progress';
      return 'Needs Adjustment';
    } else {
      if (calorieDeficit.abs() < 200) return 'Maintaining';
      return 'Slight Variation';
    }
  }

  String _getProgressExplanation(int calorieDeficit, String goal) {
    if (goal == 'lose_weight') {
      if (calorieDeficit > 500) {
        return 'You\'re eating $calorieDeficit cal below target. Great for weight loss! This could result in ~${(calorieDeficit * 7 / 7700).toStringAsFixed(1)} kg loss per week.';
      } else if (calorieDeficit > 0) {
        return 'You\'re $calorieDeficit cal below target. Keep this up for steady weight loss of ~${(calorieDeficit * 7 / 7700).toStringAsFixed(1)} kg per week.';
      } else {
        return 'You\'re ${calorieDeficit.abs()} cal over target. To lose weight, try reducing portions or choosing lower-calorie options.';
      }
    } else if (goal == 'gain_muscle') {
      if (calorieDeficit < -300) {
        return 'Perfect! You\'re eating ${calorieDeficit.abs()} cal above target for muscle gain. Expect ~${(calorieDeficit.abs() * 7 / 7700).toStringAsFixed(1)} kg gain per week.';
      } else {
        return 'To gain muscle, increase calories by ${(500 + calorieDeficit)} per day. Focus on protein-rich foods.';
      }
    } else {
      if (calorieDeficit.abs() < 200) {
        return 'You\'re maintaining your weight perfectly! Your calorie intake is well-balanced.';
      } else {
        return 'Your calories are ${calorieDeficit > 0 ? 'below' : 'above'} target by ${calorieDeficit.abs()}. Adjust slightly to maintain weight.';
      }
    }
  }
}
