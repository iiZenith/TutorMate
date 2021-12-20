import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/job_request_model.dart';
import '../../domain/models/tutor_interest_model.dart';
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

  @override
  Future<void> expressInterest({
    required String jobId,
    required String tutorId,
    required String tutorName,
  }) async {
    // Check for duplicate
    final existing = await _firestore
        .collection('tutor_interests')
        .where('jobId', isEqualTo: jobId)
        .where('tutorId', isEqualTo: tutorId)
        .get();
    
    if (existing.docs.isNotEmpty) {
      throw Exception('You have already expressed interest in this tuition.');
    }

    final docRef = _firestore.collection('tutor_interests').doc();
    final interest = TutorInterestModel(
      id: docRef.id,
      jobId: jobId,
      tutorId: tutorId,
      tutorName: tutorName,
      status: 'submitted',
      createdAt: DateTime.now(),
    );

    await docRef.set(interest.toMap());
  }

  @override
  Stream<List<TutorInterestModel>> getInterestsForJob(String jobId) {
    return _firestore
        .collection('tutor_interests')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TutorInterestModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<TutorInterestModel>> getMyInterestsStream(String tutorId) {
    return _firestore
        .collection('tutor_interests')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
            .map((doc) => TutorInterestModel.fromMap(doc.data(), doc.id))
            .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  @override
  Future<void> acceptInterest(String jobId, String interestId) async {
    final batch = _firestore.batch();
    
    // Update interest status to accepted
    final interestRef = _firestore.collection('tutor_interests').doc(interestId);
    batch.update(interestRef, {'status': 'accepted'});

    // Update job status to accepted
    final jobRef = _firestore.collection('job_requests').doc(jobId);
    batch.update(jobRef, {'status': 'accepted'});

    await batch.commit();
  }

  @override
  Future<void> rejectInterest(String interestId) async {
    await _firestore.collection('tutor_interests').doc(interestId).update({
      'status': 'rejected',
    });
  }
}
