import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/meal.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/services/progress_analyzer.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanState = ref.watch(mealPlanProvider);
    final userData = ref.watch(userDataProvider);
    final calorieLogsState = ref.watch(historicalCalorieLogsProvider);

    String? statusMessage;
    bool needsCalibration = false;

    calorieLogsState.whenData((logs) {
      if (logs.length >= 3) {
        final analysis = ProgressAnalyzer.analyzeCalorieAdherence(
          dailyLogs: logs,
          targetCalories: userData.targetCalories,
        );
        final adherence = analysis['adherencePercent'] as double;
        if (adherence < 80) {
          needsCalibration = true;
          statusMessage =
              "You've been slightly off-track recently (${adherence.toInt()}% adherence). Want Chef Claude to recalibrate your plan?";
        }
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'AI Meal Plan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PremiumBackground(
        child: SafeArea(
          bottom: false,
          child: mealPlanState.when(
            data: (data) {
              if (data == null) {
                return Center(
                  child: GlassContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No plan generated yet',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(mealPlanProvider.notifier)
                                .generatePlan(userData);
                          },
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate 7-Day Plan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2E1A47),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final days = data.keys.toList();
              if (_tabController == null ||
                  _tabController!.length != days.length) {
                _tabController = TabController(
                  length: days.length,
                  vsync: this,
                );
              }

              return Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    dividerColor: Colors.transparent,
                    tabs: days
                        .map((day) => Tab(text: day.toUpperCase()))
                        .toList(),
                  ),
                  if (data['meta']?['adjustment_explanation'] != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                data['meta']['adjustment_explanation'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (needsCalibration && statusMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              statusMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(mealPlanProvider.notifier)
                                    .generatePlan(
                                      userData,
                                      adjustmentReason:
                                          "Adherence has been below 80% recently.",
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2E1A47),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('Recalibrate Plan'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: days.map((day) {
                        final meals = data[day] as Map<String, dynamic>;
                        return ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final mealList = meals.entries.map((entry) {
                                    final mealData =
                                        entry.value as Map<String, dynamic>;
                                    return Meal(
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      name:
                                          '${day.toUpperCase()} ${entry.key}: ${mealData['name']}',
                                      calories: mealData['calories'] ?? 0,
                                      protein: mealData['protein'] ?? 0,
                                      carbs: mealData['carbs'] ?? 0,
                                      fat: mealData['fat'] ?? 0,
                                      timestamp: DateTime.now(),
                                    );
                                  }).toList();

                                  ref
                                      .read(dailyLogProvider.notifier)
                                      .addMeals(mealList);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Applied all meals for ${day.toUpperCase()}!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.playlist_add_check),
                                label: const Text('Log Entire Day'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...meals.entries.map((entry) {
                              final type = entry.key;
                              final meal = entry.value as Map<String, dynamic>;
                              return _buildMealCard(type, meal);
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 24),
                  Text(
                    'Consulting Chef Claude...',
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            error: (err, stack) => Center(
              child: GlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref
                          .read(mealPlanProvider.notifier)
                          .generatePlan(userData),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(String type, Map<String, dynamic> meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      size: 18,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Swapping meal...')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              meal['name'] ?? 'Unknown Meal',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _macroBadge('${meal['calories']} kcal', Colors.blueAccent),
                  _macroBadge('P: ${meal['protein']}g', Colors.redAccent),
                  _macroBadge('C: ${meal['carbs']}g', Colors.greenAccent),
                  _macroBadge('F: ${meal['fat']}g', Colors.orangeAccent),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ingredients',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (meal['ingredients'] as List<dynamic>? ?? [])
                  .map(
                    (i) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        i.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (meal['portion_guidance'] != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Portion Guidance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                ),
                child: Text(
                  meal['portion_guidance'].toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            if (meal['substitutions'] != null &&
                (meal['substitutions'] as List).isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Substitutions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (meal['substitutions'] as List<dynamic>)
                    .map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.greenAccent.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          s.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final mealObj = Meal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: meal['name'] ?? 'Meal',
                    calories: meal['calories'] ?? 0,
                    protein: meal['protein'] ?? 0,
                    carbs: meal['carbs'] ?? 0,
                    fat: meal['fat'] ?? 0,
                    timestamp: DateTime.now(),
                  );

                  ref.read(dailyLogProvider.notifier).addMeal(mealObj);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${meal['name']} added to daily log!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add to Daily Log'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E1A47),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
