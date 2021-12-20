import 'package:cloud_firestore/cloud_firestore.dart';

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
      createdAt: map['createdAt'] != null && map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
