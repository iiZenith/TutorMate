import 'package:cloud_firestore/cloud_firestore.dart';

enum TutorInterestStatus {
  submitted,
  accepted,
  rejected,
  withdrawn;

  static TutorInterestStatus fromString(String? val) {
    if (val == null) return TutorInterestStatus.submitted;
    switch (val.toLowerCase().trim()) {
      case 'accepted':
        return TutorInterestStatus.accepted;
      case 'rejected':
        return TutorInterestStatus.rejected;
      case 'withdrawn':
        return TutorInterestStatus.withdrawn;
      case 'submitted':
      default:
        return TutorInterestStatus.submitted;
    }
  }
}

class TutorInterestModel {
  final String id;
  final String jobId;
  final String tutorId;
  final String tutorName;
  final String status; // 'submitted', 'accepted', 'rejected', 'withdrawn'
  final DateTime createdAt;

  const TutorInterestModel({
    required this.id,
    required this.jobId,
    required this.tutorId,
    required this.tutorName,
    this.status = 'submitted',
    required this.createdAt,
  });

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
      'tutorId': tutorId,
      'tutorName': tutorName,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory TutorInterestModel.fromMap(Map<String, dynamic> map, String docId) {
    return TutorInterestModel(
      id: docId,
      jobId: map['jobId'] as String? ?? '',
      tutorId: map['tutorId'] as String? ?? '',
      tutorName: map['tutorName'] as String? ?? '',
      status: map['status'] as String? ?? 'submitted',
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }
}
