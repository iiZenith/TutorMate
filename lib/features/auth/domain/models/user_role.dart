enum UserRole {
  studentGuardian(
    label: 'Student / Guardian',
    description: 'Looking for qualified home or online tutors',
  ),
  tutor(
    label: 'Independent Tutor',
    description: 'Providing personalized tutoring services',
  ),
  institute(
    label: 'Educational Institute',
    description: 'Managing educational programs and multiple tutors',
  );

  final String label;
  final String description;

  const UserRole({
    required this.label,
    required this.description,
  });

  static UserRole fromString(String roleStr) {
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == roleStr.toLowerCase() || e.label.toLowerCase() == roleStr.toLowerCase(),
      orElse: () => UserRole.studentGuardian,
    );
  }
}
