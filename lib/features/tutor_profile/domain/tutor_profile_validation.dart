/// Validation rules shared by tutor onboarding/profile editors.
///
/// These limits are intentionally explicit so invalid numeric input cannot be
/// silently converted into a no-op update.
class TutorProfileValidation {
  static const int minExperienceYears = 0;
  static const int maxExperienceYears = 80;
  static const int minRateNpr = 1;
  static const int maxRateNpr = 1000000;

  static String? validateHeadline(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Headline is required.';
    if (text.length > 120) return 'Headline must be 120 characters or fewer.';
    return null;
  }

  static String? validateBio(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Bio is required.';
    if (text.length > 1000) return 'Bio must be 1000 characters or fewer.';
    return null;
  }

  static String? validateTeachingLevels(List<String> levels) {
    if (levels.isEmpty) return 'Select at least one teaching level.';
    return null;
  }

  static String? validateExperience(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Years of experience is required.';
    final parsed = int.tryParse(text);
    if (parsed == null) return 'Enter a whole number of years.';
    if (parsed < minExperienceYears) {
      return 'Experience cannot be negative.';
    }
    if (parsed > maxExperienceYears) {
      return 'Experience must be $maxExperienceYears years or less.';
    }
    return null;
  }

  static int? parseExperience(String? value) {
    if (validateExperience(value) != null) return null;
    return int.parse(value!.trim());
  }

  static String? validateRate(String? value, {required String label}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label is required.';
    final parsed = int.tryParse(text);
    if (parsed == null) return '$label must be a whole number.';
    if (parsed < minRateNpr) return '$label must be greater than 0.';
    if (parsed > maxRateNpr) {
      return '$label must be $maxRateNpr NPR or less.';
    }
    return null;
  }

  static int? parseRate(String? value, {required String label}) {
    if (validateRate(value, label: label) != null) return null;
    return int.parse(value!.trim());
  }
}
