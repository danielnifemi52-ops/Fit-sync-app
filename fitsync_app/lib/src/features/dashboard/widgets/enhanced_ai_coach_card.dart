import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/enhanced_ai_coach_provider.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/services/ai_coach_service.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../nutrition/providers/meal_plan_provider.dart';
import '../../workout/providers/workout_plan_provider.dart';

class EnhancedAiCoachCard extends ConsumerWidget {
  const EnhancedAiCoachCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachDataAsync = ref.watch(enhancedAiCoachProvider);

    return GlassContainer(
      padding: const EdgeInsets.all(0),
      borderRadius: 24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: coachDataAsync.when(
            data: (coachData) {
              final insight = coachData['insight'] as String;
              final weightTrend =
                  coachData['weightTrend'] as Map<String, dynamic>;
              final calorieAdherence =
                  coachData['calorieAdherence'] as Map<String, dynamic>;
              final goalPrediction =
                  coachData['goalPrediction'] as Map<String, dynamic>?;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'AI Coach Insight',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Main insight
                  MarkdownBody(
                    data: insight,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      h3: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 2.0,
                      ),
                      em: const TextStyle(color: Colors.white70),
                      strong: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Metrics row
                  Row(
                    children: [
                      if (calorieAdherence['adherencePercent'] > 0) ...[
                        Expanded(
                          child: _buildMetric(
                            icon: Icons.check_circle_outline,
                            label: 'Adherence',
                            value:
                                '${(calorieAdherence['adherencePercent'] as double).toStringAsFixed(0)}%',
                          ),
                        ),
                      ],
                      if (weightTrend['trend'] != 'insufficient_data') ...[
                        Expanded(
                          child: _buildMetric(
                            icon: _getTrendIcon(weightTrend['trend'] as String),
                            label: 'Trend',
                            value: _getTrendText(
                              weightTrend['trend'] as String,
                            ),
                          ),
                        ),
                      ],
                      if (goalPrediction != null &&
                          goalPrediction['weeksRemaining'] != null) ...[
                        Expanded(
                          child: _buildMetric(
                            icon: Icons.flag_outlined,
                            label: 'Goal ETA',
                            value: '${goalPrediction['weeksRemaining']}w',
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Plateau Action
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showPlateauAnalysis(context, ref),
                      icon: const Icon(Icons.help_outline, size: 18),
                      label: const Text('Why isn\'t my weight changing?'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'AI Coach Insight',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Analyzing your progress...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            error: (error, stack) => const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'AI Coach Insight',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Keep logging your meals and weight to get personalized insights!',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'losing':
        return Icons.trending_down;
      case 'gaining':
        return Icons.trending_up;
      default:
        return Icons.trending_flat;
    }
  }

  String _getTrendText(String trend) {
    switch (trend) {
      case 'losing':
        return 'Losing';
      case 'gaining':
        return 'Gaining';
      default:
        return 'Stable';
    }
  }

  Future<void> _showPlateauAnalysis(BuildContext context, WidgetRef ref) async {
    final userData = ref.read(userDataProvider);

    if (!userData.isPremium) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 8),
              Text('Premium Feature', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Plateau diagnostics and metabolic reasoning are available for Premium members. Upgrade to unlock deep insights.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Maybe Later',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(userDataProvider.notifier)
                    .updateUserData(userData.copyWith(isPremium: true));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upgraded to Premium! Feature Unlocked.'),
                    backgroundColor: Colors.greenAccent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final aiCoach = ref.read(aiCoachServiceProvider);
      final storage = ref.read(storageServiceProvider);

      final weightLogs = await storage.loadWeightLogs();
      final calorieLogs = await storage.loadCalorieLogs();
      final workoutLogs = await storage.loadWorkoutLogs();

      final analysis = await aiCoach.generatePlateauAnalysis(
        userData: userData,
        weightLogs: weightLogs,
        dailyLogs: calorieLogs,
        workoutLogs: workoutLogs,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.blueAccent, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'AI Diagnostic',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                MarkdownBody(
                  data: analysis,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    h3: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 2.0,
                    ),
                    listBullet: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back to Dashboard'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close Diagnostic

                      // Trigger adaptations
                      ref
                          .read(mealPlanProvider.notifier)
                          .generatePlan(
                            userData,
                            adjustmentReason: "AI Plateau Diagnosis: $analysis",
                          );
                      ref
                          .read(workoutPlanProvider.notifier)
                          .generatePlan(
                            userData,
                            adjustmentReason: "AI Plateau Diagnosis: $analysis",
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Adapting your plans based on analysis...',
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Adapt My Plan Based on This'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
    }
  }
}
