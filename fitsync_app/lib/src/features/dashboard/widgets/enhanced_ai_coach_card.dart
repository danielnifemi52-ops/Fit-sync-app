import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/enhanced_ai_coach_provider.dart';
import '../../../core/widgets/premium_background.dart';

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
}
