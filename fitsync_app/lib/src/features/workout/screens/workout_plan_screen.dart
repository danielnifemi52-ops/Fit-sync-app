import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_plan_provider.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/models/user_data.dart';
import '../../../core/widgets/premium_background.dart';

class WorkoutPlanScreen extends ConsumerStatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  ConsumerState<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends ConsumerState<WorkoutPlanScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final Set<String> _completedExercises = {};

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _toggleExercise(String exerciseId) {
    setState(() {
      if (_completedExercises.contains(exerciseId)) {
        _completedExercises.remove(exerciseId);
      } else {
        _completedExercises.add(exerciseId);
      }
    });
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
        actions: [
          IconButton(
            onPressed: () {
              ref.read(workoutPlanProvider.notifier).generatePlan(userData);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate Plan',
          ),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          bottom: false,
          child: planState.when(
            data: (data) {
              if (data == null) {
                return _buildEmptyState(userData);
              }

              final meta = data['meta'] as Map<String, dynamic>? ?? {};
              final days = data.keys.where((k) => k != 'meta').toList();

              if (_tabController == null ||
                  _tabController!.length != days.length) {
                _tabController = TabController(
                  length: days.length,
                  vsync: this,
                );
              }

              return Column(
                children: [
                  _buildMetaHeader(meta),
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

                        if (dayData['name']?.toString().toUpperCase() ==
                            'REST') {
                          return _buildRestDay();
                        }

                        final exercises =
                            dayData['exercises'] as List<dynamic>? ?? [];

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: exercises.length + 2,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
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
                            if (index == exercises.length + 1) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(workoutPlanProvider.notifier)
                                        .logWorkoutCompletion(
                                          day,
                                          dayData['name'] ?? 'Workout',
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Workout logged successfully!',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Complete Workout'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.greenAccent,
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return _buildExerciseCard(
                              day,
                              exercises[index - 1],
                            );
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
                    'Crafting your routine...',
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GlassContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to generate plan: $err',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(workoutPlanProvider.notifier)
                            .generatePlan(userData),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(UserData userData) {
    return Center(
      child: GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fitness_center, color: Colors.white, size: 64),
              const SizedBox(height: 24),
              const Text(
                'No plan generated yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let our AI build a custom split for you.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(workoutPlanProvider.notifier).generatePlan(userData);
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
      ),
    );
  }

  Widget _buildMetaHeader(Map<String, dynamic> meta) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.view_comfortable, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                meta['weekly_split'] ?? 'Custom Plan',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (meta['adaptation_note'] != null)
                const Icon(
                  Icons.tips_and_updates,
                  color: Colors.orangeAccent,
                  size: 20,
                ),
            ],
          ),
          if (meta['progression_guidance'] != null)
            _buildCollapsibleGuidance(meta['progression_guidance']),
        ],
      ),
    );
  }

  Widget _buildCollapsibleGuidance(String guidance) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression Tips',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            guidance,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestDay() {
    return Center(
      child: GlassContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hotel, color: Colors.blueAccent, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Rest & Recovery',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Muscles grow when you rest. Use today to stretch, walk, or relax.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(String day, Map<String, dynamic> exercise) {
    final exerciseId = '${day}_${exercise['name']}';
    final isCompleted = _completedExercises.contains(exerciseId);

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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isCompleted ? Colors.white38 : Colors.white,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                if (!isCompleted)
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      size: 20,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      ref
                          .read(workoutPlanProvider.notifier)
                          .swapExercise(day, exercise);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Swapping exercise...')),
                      );
                    },
                  ),
                Checkbox(
                  value: isCompleted,
                  onChanged: (v) => _toggleExercise(exerciseId),
                  activeColor: Colors.blueAccent,
                  checkColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
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
                    style: TextStyle(
                      color: isCompleted ? Colors.white24 : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: isCompleted ? Colors.white24 : Colors.white60,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exercise['rest']}s rest',
                      style: TextStyle(
                        color: isCompleted ? Colors.white24 : Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (exercise['notes'] != null && !isCompleted)
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
