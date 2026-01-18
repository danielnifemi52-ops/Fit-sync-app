class GoalPredictor {
  /// Predict when user will reach their target weight
  /// Returns estimated date and days remaining
  static Map<String, dynamic> predictGoalCompletion({
    required double currentWeight,
    required double targetWeight,
    required double weeklyWeightChange,
  }) {
    if (weeklyWeightChange == 0) {
      return {
        'estimatedDate': null,
        'daysRemaining': null,
        'weeksRemaining': null,
        'status': 'no_progress',
        'message':
            'Your weight isn\'t changing. Adjust your calorie intake to make progress.',
      };
    }

    final weightToLose = (targetWeight - currentWeight).abs();
    final weeksNeeded = weightToLose / weeklyWeightChange.abs();
    final daysNeeded = (weeksNeeded * 7).round();

    if (daysNeeded < 0 || daysNeeded > 365 * 2) {
      return {
        'estimatedDate': null,
        'daysRemaining': null,
        'weeksRemaining': null,
        'status': 'unrealistic',
        'message':
            'At this rate, it will take too long. Consider adjusting your approach.',
      };
    }

    final estimatedDate = DateTime.now().add(Duration(days: daysNeeded));

    String status;
    if (daysNeeded < 30) {
      status = 'on_track_fast';
    } else if (daysNeeded < 90) {
      status = 'on_track';
    } else {
      status = 'long_term';
    }

    return {
      'estimatedDate': estimatedDate,
      'daysRemaining': daysNeeded,
      'weeksRemaining': weeksNeeded.round(),
      'status': status,
      'weightToGo': weightToLose,
    };
  }

  /// Check if user is ahead or behind schedule
  static Map<String, dynamic> compareToSchedule({
    required double currentWeight,
    required double startWeight,
    required double targetWeight,
    required int daysSinceStart,
  }) {
    final totalWeightToLose = (targetWeight - startWeight).abs();
    final weightLostSoFar = (currentWeight - startWeight).abs();

    // Healthy rate: 0.5-1 kg per week
    final expectedWeightLoss =
        (daysSinceStart / 7) * 0.75; // 0.75 kg/week average

    final difference = weightLostSoFar - expectedWeightLoss;

    String status;
    String message;

    if (difference > 1) {
      status = 'ahead';
      message =
          'You\'re ${difference.toStringAsFixed(1)} kg ahead of schedule! Great work!';
    } else if (difference < -1) {
      status = 'behind';
      message =
          'You\'re ${difference.abs().toStringAsFixed(1)} kg behind schedule. Consider adjusting your approach.';
    } else {
      status = 'on_track';
      message = 'You\'re right on track! Keep up the great work!';
    }

    return {
      'status': status,
      'message': message,
      'difference': difference,
      'progressPercent': (weightLostSoFar / totalWeightToLose * 100).clamp(
        0,
        100,
      ),
    };
  }

  /// Generate motivational message based on progress
  static String generateMotivationalMessage({
    required String status,
    required int daysRemaining,
    required double weightToGo,
  }) {
    if (status == 'on_track_fast') {
      return 'You\'re crushing it! Just $daysRemaining days until you reach your goal!';
    } else if (status == 'on_track') {
      return 'Steady progress! ${weightToGo.toStringAsFixed(1)} kg to go. You\'ve got this!';
    } else if (status == 'long_term') {
      return 'This is a marathon, not a sprint. Stay consistent and you\'ll get there!';
    } else if (status == 'no_progress') {
      return 'Time to shake things up! Small changes can make a big difference.';
    } else {
      return 'Every day is a new opportunity to make progress!';
    }
  }
}
