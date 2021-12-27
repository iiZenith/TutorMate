class TutorModel {
  final String id;
  final String fullName;
  final String district;
  final List<String> subjects;
  final int expectedMonthlyRate;

  const TutorModel({
    required this.id,
    required this.fullName,
    required this.district,
    required this.subjects,
    required this.expectedMonthlyRate,
  });

  factory TutorModel.fromMap(Map<String, dynamic> map, String id) {
    return TutorModel(
      id: id,
      fullName: map['fullName'] as String? ?? 'Unknown Tutor',
      district: map['district'] as String? ?? 'Not specified',
      subjects: List<String>.from(map['subjects'] ?? []),
      expectedMonthlyRate: (map['expectedMonthlyRate'] as num?)?.toInt() ?? 0,
    );
  }
}
