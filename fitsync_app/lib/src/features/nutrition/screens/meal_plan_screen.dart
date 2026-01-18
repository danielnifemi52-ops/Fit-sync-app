import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meal_plan_provider.dart';
import '../../../core/models/user_data.dart'; // Mock user data source for now

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

    return Scaffold(
      appBar: AppBar(title: const Text('AI Meal Plan')),
      body: mealPlanState.when(
        data: (data) {
          if (data == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Using default mock user data for MVP
                  ref.read(mealPlanProvider.notifier).generatePlan(UserData());
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate 7-Day Plan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            );
          }

          final days = data.keys.toList();
          if (_tabController == null || _tabController!.length != days.length) {
            _tabController = TabController(length: days.length, vsync: this);
          }

          return Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: days.map((day) => Tab(text: day.toUpperCase())).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: days.map((day) {
                    final meals = data[day] as Map<String, dynamic>;
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: meals.entries.map((entry) {
                        final type = entry.key; // breakfast, lunch, dinner
                        final meal = entry.value as Map<String, dynamic>;
                        return _buildMealCard(type, meal);
                      }).toList(),
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
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Consulting Chef Claude...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              TextButton(
                onPressed: () => ref
                    .read(mealPlanProvider.notifier)
                    .generatePlan(UserData()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(String type, Map<String, dynamic> meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    // TODO: Implement single meal regeneration
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Swapping meal...')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal['name'] ?? 'Unknown Meal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _macroBadge('${meal['calories']} kcal', Colors.blue),
                _macroBadge('P: ${meal['protein']}g', Colors.red),
                _macroBadge('C: ${meal['carbs']}g', Colors.green),
                _macroBadge('F: ${meal['fat']}g', Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingredients:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Wrap(
              spacing: 8,
              children: (meal['ingredients'] as List<dynamic>? ?? [])
                  .map(
                    (i) => Chip(
                      label: Text(
                        i.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
