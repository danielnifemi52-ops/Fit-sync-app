class UserData {
  final int? age;
  final String? gender; // 'male', 'female'
  final double? heightCm;
  final double? currentWeight;
  final double? targetWeight;
  final String goal; // 'lose_weight', 'gain_muscle', 'maintain'
  final String?
  activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final String dietType;
  final bool onboardingComplete;
  final String unitSystem; // 'metric' or 'imperial'

  // Calculated fields
  final int? bmr;
  final int? tdee;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;

  UserData({
    this.age,
    this.gender,
    this.heightCm,
    this.currentWeight,
    this.targetWeight,
    this.goal = 'maintain',
    this.activityLevel,
    this.dietType = 'balanced',
    this.onboardingComplete = false,
    this.unitSystem = 'metric',
    this.bmr,
    this.tdee,
    this.targetCalories = 2000,
    this.targetProtein = 150,
    this.targetCarbs = 200,
    this.targetFat = 65,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'goal': goal,
      'activityLevel': activityLevel,
      'dietType': dietType,
      'onboardingComplete': onboardingComplete,
      'unitSystem': unitSystem,
      'bmr': bmr,
      'tdee': tdee,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      heightCm: json['heightCm'] as double?,
      currentWeight: json['currentWeight'] as double?,
      targetWeight: json['targetWeight'] as double?,
      goal: json['goal'] ?? 'maintain',
      activityLevel: json['activityLevel'] as String?,
      dietType: json['dietType'] ?? 'balanced',
      onboardingComplete: json['onboardingComplete'] ?? false,
      unitSystem: json['unitSystem'] ?? 'metric',
      bmr: json['bmr'] as int?,
      tdee: json['tdee'] as int?,
      targetCalories: json['targetCalories'] ?? 2000,
      targetProtein: json['targetProtein'] ?? 150,
      targetCarbs: json['targetCarbs'] ?? 200,
      targetFat: json['targetFat'] ?? 65,
    );
  }

  UserData copyWith({
    int? age,
    String? gender,
    double? heightCm,
    double? currentWeight,
    double? targetWeight,
    String? goal,
    String? activityLevel,
    String? dietType,
    bool? onboardingComplete,
    String? unitSystem,
    int? bmr,
    int? tdee,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
  }) {
    return UserData(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      dietType: dietType ?? this.dietType,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      unitSystem: unitSystem ?? this.unitSystem,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
    );
  }
}
