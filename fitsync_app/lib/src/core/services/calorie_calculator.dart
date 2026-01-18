class CalorieCalculator {
  /// Calculate BMR using Mifflin-St Jeor Equation
  /// Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(y) + 5
  /// Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(y) - 161
  static int calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);

    if (gender.toLowerCase() == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    return bmr.round();
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  /// Multiplies BMR by activity factor
  static int calculateTDEE({required int bmr, required String activityLevel}) {
    double multiplier;

    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        multiplier = 1.2; // Little or no exercise
        break;
      case 'light':
        multiplier = 1.375; // Light exercise 1-3 days/week
        break;
      case 'moderate':
        multiplier = 1.55; // Moderate exercise 3-5 days/week
        break;
      case 'active':
        multiplier = 1.725; // Heavy exercise 6-7 days/week
        break;
      case 'very_active':
        multiplier = 1.9; // Very heavy exercise, physical job
        break;
      default:
        multiplier = 1.2;
    }

    return (bmr * multiplier).round();
  }

  /// Adjust calories based on goal
  /// Lose weight: -500 cal (1 lb/week loss)
  /// Gain muscle: +500 cal (1 lb/week gain)
  /// Maintain: no change
  static int calculateTargetCalories({
    required int tdee,
    required String goal,
  }) {
    switch (goal.toLowerCase()) {
      case 'lose_weight':
        return tdee - 500;
      case 'gain_muscle':
        return tdee + 500;
      case 'maintain':
      default:
        return tdee;
    }
  }

  /// Calculate macro distribution
  /// Returns map with protein, carbs, fat in grams
  static Map<String, int> calculateMacros({
    required int targetCalories,
    required String goal,
  }) {
    int protein, carbs, fat;

    if (goal.toLowerCase() == 'lose_weight') {
      // Higher protein for weight loss (40% protein, 30% carbs, 30% fat)
      protein = ((targetCalories * 0.40) / 4).round(); // 4 cal/g
      carbs = ((targetCalories * 0.30) / 4).round();
      fat = ((targetCalories * 0.30) / 9).round(); // 9 cal/g
    } else if (goal.toLowerCase() == 'gain_muscle') {
      // Balanced for muscle gain (30% protein, 40% carbs, 30% fat)
      protein = ((targetCalories * 0.30) / 4).round();
      carbs = ((targetCalories * 0.40) / 4).round();
      fat = ((targetCalories * 0.30) / 9).round();
    } else {
      // Balanced for maintenance (25% protein, 45% carbs, 30% fat)
      protein = ((targetCalories * 0.25) / 4).round();
      carbs = ((targetCalories * 0.45) / 4).round();
      fat = ((targetCalories * 0.30) / 9).round();
    }

    return {'protein': protein, 'carbs': carbs, 'fat': fat};
  }
}
