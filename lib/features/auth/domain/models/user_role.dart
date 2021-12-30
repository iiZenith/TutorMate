enum UserRole {
  studentGuardian(
    label: 'Student / Guardian',
    description: 'Looking for qualified home or online tutors',
  ),
  tutor(
    label: 'Independent Tutor',
    description: 'Providing personalized tutoring services',
  );

  final String label;
  final String description;

  const UserRole({
    required this.label,
    required this.description,
  });

  static UserRole? fromString(String? roleStr) {
    if (roleStr == null || roleStr.isEmpty) return null;
    final normalized = roleStr.trim().toLowerCase();
    if (normalized == 'student' || normalized == 'parent' || normalized == 'guardian' || normalized == 'studentguardian' || normalized == 'student_guardian' || normalized == 'student/guardian') {
      return UserRole.studentGuardian;
    }
    if (normalized == 'tutor' || normalized == 'independent_tutor' || normalized == 'independent tutor') {
      return UserRole.tutor;
    }
    try {
      return UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == normalized || e.label.toLowerCase() == normalized
      );
    } catch (_) {
      return null;
    }
  }
}
