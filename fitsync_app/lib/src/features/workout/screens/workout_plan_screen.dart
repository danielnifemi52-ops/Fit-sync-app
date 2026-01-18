import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_plan_provider.dart';
import '../../../core/models/user_data.dart';

class WorkoutPlanScreen extends ConsumerStatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  ConsumerState<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends ConsumerState<WorkoutPlanScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(workoutPlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Workout Plan')),
      body: planState.when(
        data: (data) {
          if (data == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(workoutPlanProvider.notifier)
                      .generatePlan(UserData());
                },
                icon: const Icon(Icons.fitness_center),
                label: const Text('Generate Workout Plan'),
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
                    final dayData = data[day] as Map<String, dynamic>;
                    final exercises = dayData['exercises'] as List<dynamic>;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: exercises.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              dayData['name'] ?? 'Workout',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return _buildExerciseCard(exercises[index - 1]);
                      },
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
              Text('Building your routine...'),
            ],
          ),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Checkbox(value: false, onChanged: (v) {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${exercise['sets']} sets × ${exercise['reps']} reps'),
                Text(
                  '${exercise['rest']}s rest',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (exercise['notes'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  exercise['notes'],
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
