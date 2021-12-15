class JobRequestModel {
  final String jobId;
  final String studentId;
  final String studentName;
  final String level;
  final List<String> subjects;
  final String district;
  final String area;
  final double salaryNpr;
  final String tuitionMode;
  final int daysPerWeek;
  final String status;
  final DateTime createdAt;

  const JobRequestModel({
    required this.jobId,
    required this.studentId,
    required this.studentName,
    required this.level,
    required this.subjects,
    required this.district,
    required this.area,
    required this.salaryNpr,
    required this.tuitionMode,
    required this.daysPerWeek,
    this.status = "open",
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'studentId': studentId,
      'studentName': studentName,
      'level': level,
      'subjects': subjects,
      'district': district,
      'area': area,
      'salaryNpr': salaryNpr,
      'tuitionMode': tuitionMode,
      'daysPerWeek': daysPerWeek,
      'status': status,
      'createdAt': createdAt.toIso8601String(), // This will be overwritten by FieldValue.serverTimestamp() during creation if needed
    };
  }

  factory JobRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return JobRequestModel(
      jobId: id,
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      level: map['level'] as String? ?? '',
      subjects: List<String>.from((map['subjects'] as List?) ?? []),
      district: map['district'] as String? ?? '',
      area: map['area'] as String? ?? '',
      salaryNpr: (map['salaryNpr'] as num?)?.toDouble() ?? 0.0,
      tuitionMode: map['tuitionMode'] as String? ?? '',
      daysPerWeek: (map['daysPerWeek'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'open',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String ? DateTime.parse(map['createdAt']) : map['createdAt'].toDate())
          : DateTime.now(),
    );
  }
}
