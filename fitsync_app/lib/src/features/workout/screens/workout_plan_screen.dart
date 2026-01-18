import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_plan_provider.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/widgets/premium_background.dart';

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
    final userData = ref.watch(userDataProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'AI Workout Plan',
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
          child: planState.when(
            data: (data) {
              if (data == null) {
                return Center(
                  child: GlassContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fitness_center,
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
                                .read(workoutPlanProvider.notifier)
                                .generatePlan(userData);
                          },
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate Workout Plan'),
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
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: days.map((day) {
                        final dayData = data[day] as Map<String, dynamic>;
                        final exercises = dayData['exercises'] as List<dynamic>;

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: exercises.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Text(
                                  dayData['name'] ?? 'Workout',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 24),
                  Text(
                    'Building your routine...',
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
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
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
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white60),
                  child: Checkbox(
                    value: false,
                    onChanged: (v) {},
                    activeColor: Colors.white,
                    checkColor: const Color(0xFF2E1A47),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${exercise['sets']} sets × ${exercise['reps']} reps',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exercise['rest']}s rest',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (exercise['notes'] != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                ),
                child: Text(
                  exercise['notes'],
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
