import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_data.dart';
import '../../../core/services/calorie_calculator.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/widgets/premium_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  String _unitSystem = 'metric'; // 'metric' or 'imperial'
  int? _age;
  String? _gender;
  double? _heightCm;
  double? _currentWeight;
  double? _targetWeight;
  String _goal = 'maintain';
  String _activityLevel = 'moderate';

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    if (_age == null ||
        _gender == null ||
        _heightCm == null ||
        _currentWeight == null ||
        _targetWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final bmr = CalorieCalculator.calculateBMR(
      weightKg: _currentWeight!,
      heightCm: _heightCm!,
      age: _age!,
      gender: _gender!,
    );

    final tdee = CalorieCalculator.calculateTDEE(
      bmr: bmr,
      activityLevel: _activityLevel,
    );

    final targetCalories = CalorieCalculator.calculateTargetCalories(
      tdee: tdee,
      goal: _goal,
    );

    final macros = CalorieCalculator.calculateMacros(
      targetCalories: targetCalories,
      goal: _goal,
    );

    final userData = UserData(
      age: _age,
      gender: _gender,
      heightCm: _heightCm,
      currentWeight: _currentWeight,
      targetWeight: _targetWeight,
      goal: _goal,
      activityLevel: _activityLevel,
      unitSystem: _unitSystem,
      onboardingComplete: true,
      bmr: bmr,
      tdee: tdee,
      targetCalories: targetCalories,
      targetProtein: macros['protein']!,
      targetCarbs: macros['carbs']!,
      targetFat: macros['fat']!,
    );

    ref.read(userDataProvider.notifier).updateUserData(userData);
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? Colors.white
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: index <= _currentPage
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Pages
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(0),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                      children: [
                        _buildBasicInfoPage(),
                        _buildWeightPage(),
                        _buildGoalPage(),
                        _buildActivityPage(),
                        _buildSummaryPage(),
                      ],
                    ),
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _previousPage,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E1A47),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 4 ? 'Complete' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let\'s get to know you',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll use this to calculate your personalized targets',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),

          // Unit Selection
          Center(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'metric',
                  label: Text('Metric'),
                  icon: Icon(Icons.public),
                ),
                ButtonSegment(
                  value: 'imperial',
                  label: Text('Imperial (US)'),
                  icon: Icon(Icons.flag),
                ),
              ],
              selected: {_unitSystem},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _unitSystem = newSelection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _age = int.tryParse(value),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            value: _gender,
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: (value) => setState(() => _gender = value),
          ),
          const SizedBox(height: 16),

          TextField(
            decoration: InputDecoration(
              labelText: _unitSystem == 'metric'
                  ? 'Height (cm)'
                  : 'Height (inches)',
              border: const OutlineInputBorder(),
              helperText: _unitSystem == 'imperial'
                  ? 'Total inches (e.g., 5\'10" = 70")'
                  : null,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null) {
                _heightCm = _unitSystem == 'imperial' ? parsed * 2.54 : parsed;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your weight goals',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          TextField(
            decoration: InputDecoration(
              labelText: _unitSystem == 'metric'
                  ? 'Current Weight (kg)'
                  : 'Current Weight (lbs)',
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null) {
                _currentWeight = _unitSystem == 'imperial'
                    ? parsed / 2.20462
                    : parsed;
              }
            },
          ),
          const SizedBox(height: 16),

          TextField(
            decoration: InputDecoration(
              labelText: _unitSystem == 'metric'
                  ? 'Target Weight (kg)'
                  : 'Target Weight (lbs)',
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null) {
                _targetWeight = _unitSystem == 'imperial'
                    ? parsed / 2.20462
                    : parsed;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your goal?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          _buildGoalCard(
            'Lose Weight',
            'lose_weight',
            Icons.trending_down,
            Colors.redAccent,
          ),
          const SizedBox(height: 12),
          _buildGoalCard(
            'Gain Muscle',
            'gain_muscle',
            Icons.trending_up,
            Colors.greenAccent,
          ),
          const SizedBox(height: 12),
          _buildGoalCard(
            'Maintain',
            'maintain',
            Icons.trending_flat,
            Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _goal == value;
    return InkWell(
      onTap: () => setState(() => _goal = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity level',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          _buildActivityCard('Sedentary', 'sedentary', 'Little or no exercise'),
          _buildActivityCard('Light', 'light', 'Light exercise 1-3 days/week'),
          _buildActivityCard(
            'Moderate',
            'moderate',
            'Moderate exercise 3-5 days/week',
          ),
          _buildActivityCard(
            'Active',
            'active',
            'Heavy exercise 6-7 days/week',
          ),
          _buildActivityCard(
            'Very Active',
            'very_active',
            'Very heavy exercise, physical job',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String value, String description) {
    final isSelected = _activityLevel == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _activityLevel = value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Colors.white.withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPage() {
    if (_age == null ||
        _gender == null ||
        _heightCm == null ||
        _currentWeight == null ||
        _targetWeight == null) {
      return const Center(
        child: Text(
          'Please complete all previous steps',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final bmr = CalorieCalculator.calculateBMR(
      weightKg: _currentWeight!,
      heightCm: _heightCm!,
      age: _age!,
      gender: _gender!,
    );

    final tdee = CalorieCalculator.calculateTDEE(
      bmr: bmr,
      activityLevel: _activityLevel,
    );

    final targetCalories = CalorieCalculator.calculateTargetCalories(
      tdee: tdee,
      goal: _goal,
    );

    final macros = CalorieCalculator.calculateMacros(
      targetCalories: targetCalories,
      goal: _goal,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your personalized plan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your profile, here are your daily targets',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 32),

          _buildSummaryCardResult('BMR', '$bmr cal', 'Calories burned at rest'),
          _buildSummaryCardResult(
            'TDEE',
            '$tdee cal',
            'Total daily energy expenditure',
          ),
          _buildSummaryCardResult(
            'Target Calories',
            '$targetCalories cal',
            'Daily calorie goal',
          ),

          const SizedBox(height: 24),
          const Text(
            'Daily Macros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          _buildMacroCardResult(
            'Protein',
            '${macros['protein']}g',
            Colors.redAccent,
          ),
          _buildMacroCardResult(
            'Carbs',
            '${macros['carbs']}g',
            Colors.greenAccent,
          ),
          _buildMacroCardResult(
            'Fat',
            '${macros['fat']}g',
            Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardResult(String title, String value, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCardResult(String name, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
