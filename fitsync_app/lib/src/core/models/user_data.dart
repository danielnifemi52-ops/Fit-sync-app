class UserData {
  final String dietType; // e.g., 'balanced', 'keto', 'vegan'
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final String goal; // e.g., 'lose_weight', 'gain_muscle'

  UserData({
    this.dietType = 'balanced',
    this.targetCalories = 2000,
    this.targetProtein = 150,
    this.targetCarbs = 200,
    this.targetFat = 65,
    this.goal = 'maintain',
  });

  Map<String, dynamic> toJson() {
    return {
      'dietType': dietType,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
      'goal': goal,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      dietType: json['dietType'] ?? 'balanced',
      targetCalories: json['targetCalories'] ?? 2000,
      targetProtein: json['targetProtein'] ?? 150,
      targetCarbs: json['targetCarbs'] ?? 200,
      targetFat: json['targetFat'] ?? 65,
      goal: json['goal'] ?? 'maintain',
    );
  }
}
