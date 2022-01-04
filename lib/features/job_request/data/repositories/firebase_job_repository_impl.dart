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
    if (subject != null && subject.isNotEmpty) {
      query = query.where('subjects', arrayContains: subject);
    }
    if (minBudget != null && minBudget > 0) {
      query = query.where('budgetNpr', isGreaterThanOrEqualTo: minBudget);
    }

    return query.snapshots().map((snapshot) {
      var jobs = snapshot.docs.map((doc) {
        return JobRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
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
    final docId = '${jobId}_$tutorId';
    final docRef = _firestore.collection('tutor_interests').doc(docId);
    
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      throw Exception('You have already expressed interest in this tuition.');
    }

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
  Future<void> acceptInterest({
    required String jobId, 
    required String interestId, 
    required String studentId,
  }) async {
    final jobDoc = await _firestore.collection('job_requests').doc(jobId).get();
    if (!jobDoc.exists || jobDoc.data()?['studentId'] != studentId) {
      throw Exception('Unauthorized or job not found.');
    }

    final interestDoc = await _firestore.collection('tutor_interests').doc(interestId).get();
    if (!interestDoc.exists || interestDoc.data()?['jobId'] != jobId) {
      throw Exception('Interest does not belong to this job.');
    }
    
    if (interestDoc.data()?['status'] != 'submitted') {
      throw Exception('Interest is not in submitted state.');
    }

    final batch = _firestore.batch();
    
    // Update target interest status to accepted
    final interestRef = _firestore.collection('tutor_interests').doc(interestId);
    batch.update(interestRef, {'status': 'accepted'});

    // Update job status to accepted
    final jobRef = _firestore.collection('job_requests').doc(jobId);
    batch.update(jobRef, {'status': 'accepted'});

    // Reject all other pending interests for this job
    final otherInterests = await _firestore
        .collection('tutor_interests')
        .where('jobId', isEqualTo: jobId)
        .where('status', isEqualTo: 'submitted')
        .get();

    for (var doc in otherInterests.docs) {
      if (doc.id != interestId) {
        batch.update(doc.reference, {'status': 'rejected'});
      }
    }

    await batch.commit();
  }

  @override
  Future<void> rejectInterest({
    required String interestId,
    required String studentId,
  }) async {
    final interestDoc = await _firestore.collection('tutor_interests').doc(interestId).get();
    if (!interestDoc.exists) {
      throw Exception('Interest not found.');
    }

    final jobId = interestDoc.data()?['jobId'];
    if (jobId == null) {
      throw Exception('Interest has no associated job.');
    }

    final jobDoc = await _firestore.collection('job_requests').doc(jobId).get();
    if (!jobDoc.exists || jobDoc.data()?['studentId'] != studentId) {
      throw Exception('Unauthorized or job not found.');
    }

    await _firestore.collection('tutor_interests').doc(interestId).update({
      'status': 'rejected',
    });
  }

  @override
  Future<void> cancelJobRequest({
    required String jobId,
    required String studentId,
  }) async {
    final jobDoc = await _firestore.collection('job_requests').doc(jobId).get();
    if (!jobDoc.exists || jobDoc.data()?['studentId'] != studentId) {
      throw Exception('Unauthorized or job request not found.');
    }

    await _firestore.collection('job_requests').doc(jobId).update({
      'status': 'cancelled',
    });
  }
}
