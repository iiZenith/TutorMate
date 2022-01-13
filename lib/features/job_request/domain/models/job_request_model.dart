import 'package:cloud_firestore/cloud_firestore.dart';

enum JobRequestStatus {
  open,
  accepted,
  rejected,
  cancelled;

  static JobRequestStatus fromString(String? val) {
    if (val == null) return JobRequestStatus.open;
    switch (val.toLowerCase().trim()) {
      case 'accepted':
        return JobRequestStatus.accepted;
      case 'rejected':
        return JobRequestStatus.rejected;
      case 'cancelled':
      case 'canceled':
        return JobRequestStatus.cancelled;
      case 'open':
      default:
        return JobRequestStatus.open;
    }
  }
}

class JobRequestModel {
  final String jobId;
  final String studentId;
  final String studentName;
  final String? province;
  final String district;
  final String area;
  final String grade;
  final List<String> subjects;
  final int budgetNpr;
  final String status;
  final DateTime createdAt;

  const JobRequestModel({
    required this.jobId,
    required this.studentId,
    required this.studentName,
    this.province,
    required this.district,
    required this.area,
    required this.grade,
    required this.subjects,
    required this.budgetNpr,
    this.status = "open",
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'studentId': studentId,
      'studentName': studentName,
      if (province != null) 'province': province,
      'district': district,
      'area': area,
      'grade': grade,
      'subjects': subjects,
      'budgetNpr': budgetNpr,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory JobRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return JobRequestModel(
      jobId: id,
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      province: map['province'] as String?,
      district: map['district'] as String? ?? '',
      area: map['area'] as String? ?? '',
      grade: map['grade'] as String? ?? '',
      subjects: List<String>.from((map['subjects'] as List?) ?? []),
      budgetNpr: (map['budgetNpr'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'open',
      createdAt: map['createdAt'] != null && map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
