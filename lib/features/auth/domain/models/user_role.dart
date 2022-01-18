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
    final lower = roleStr.toLowerCase().trim();
    if (lower == 'student' ||
        lower == 'parent' ||
        lower == 'guardian' ||
        lower == 'studentguardian' ||
        lower == 'student/guardian' ||
        lower == 'student / guardian') {
      return UserRole.studentGuardian;
    }
    if (lower == 'tutor' ||
        lower == 'independent tutor' ||
        lower == 'independenttutor') {
      return UserRole.tutor;
    }
    return null;
  }
}
