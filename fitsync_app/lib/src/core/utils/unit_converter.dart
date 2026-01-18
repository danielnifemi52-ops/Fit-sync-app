class UnitConverter {
  // Weight conversions
  static double kgToLbs(double kg) => kg * 2.20462;
  static double lbsToKg(double lbs) => lbs / 2.20462;

  // Height conversions
  static double cmToInches(double cm) => cm / 2.54;
  static double inchesToCm(double inches) => inches * 2.54;
  static double cmToFeet(double cm) => cm / 30.48;

  // Format weight for display
  static String formatWeight(double weight, String unitSystem) {
    if (unitSystem == 'imperial') {
      return '${kgToLbs(weight).toStringAsFixed(1)} lbs';
    }
    return '${weight.toStringAsFixed(1)} kg';
  }

  // Format height for display
  static String formatHeight(double heightCm, String unitSystem) {
    if (unitSystem == 'imperial') {
      final totalInches = cmToInches(heightCm);
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return '$feet\'$inches"';
    }
    return '${heightCm.toStringAsFixed(0)} cm';
  }

  // Parse weight input
  static double? parseWeight(String input, String unitSystem) {
    final value = double.tryParse(input);
    if (value == null) return null;

    if (unitSystem == 'imperial') {
      return lbsToKg(value);
    }
    return value;
  }

  // Parse height input (for imperial, expects total inches)
  static double? parseHeight(String input, String unitSystem) {
    final value = double.tryParse(input);
    if (value == null) return null;

    if (unitSystem == 'imperial') {
      return inchesToCm(value);
    }
    return value;
  }

  // Get weight unit label
  static String getWeightUnit(String unitSystem) {
    return unitSystem == 'imperial' ? 'lbs' : 'kg';
  }

  // Get height unit label
  static String getHeightUnit(String unitSystem) {
    return unitSystem == 'imperial' ? 'inches' : 'cm';
  }
}
