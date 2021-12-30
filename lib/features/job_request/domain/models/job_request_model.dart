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
    this.status = 'open',
    required this.createdAt,
  });

  static int _parseBudget(dynamic val) {
    if (val is num) return val.toInt();
    if (val is String) {
      final parsed = int.tryParse(val.trim());
      if (parsed != null && parsed >= 0) return parsed;
    }
    return 0;
  }

  static DateTime _parseTimestamp(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) {
      final parsed = DateTime.tryParse(val);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

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
      budgetNpr: _parseBudget(map['budgetNpr']),
      status: map['status'] as String? ?? 'open',
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }
}
