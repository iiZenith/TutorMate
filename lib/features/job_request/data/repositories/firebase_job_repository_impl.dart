import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/job_request_model.dart';
import '../../domain/repositories/job_repository.dart';

class FirebaseJobRepositoryImpl implements JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createJobRequest(JobRequestModel job) async {
    final docRef = _firestore.collection('job_requests').doc();
    
    // Create a new map to merge serverTimestamp correctly based on the model's toMap()
    final map = job.toMap();
    map['jobId'] = docRef.id;
    
    await docRef.set(map);
  }

  @override
  Stream<List<JobRequestModel>> getOpenJobsStream({
    String? district,
    String? subject,
    int? minBudget,
  }) {
    Query query = _firestore.collection('job_requests').where('status', isEqualTo: 'open');

    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }

    // We execute local filtering for arrays and inequalities to prevent forcing manual composite indexes during MVP
    return query.snapshots().map((snapshot) {
      var jobs = snapshot.docs.map((doc) {
        return JobRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      if (subject != null && subject.isNotEmpty) {
        jobs = jobs.where((job) => job.subjects.contains(subject)).toList();
      }
      if (minBudget != null && minBudget > 0) {
        jobs = jobs.where((job) => job.budgetNpr >= minBudget).toList();
      }

      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  @override
  Stream<List<JobRequestModel>> getMyRequestsStream(String studentId) {
    return _firestore
        .collection('job_requests')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs.map((doc) {
        return JobRequestModel.fromMap(doc.data(), doc.id);
      }).toList();
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }
}
