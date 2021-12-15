import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/job_request_model.dart';
import '../../domain/repositories/job_repository.dart';

class FirebaseJobRepositoryImpl implements JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createJobRequest(JobRequestModel job) async {
    final docRef = _firestore.collection('job_requests').doc();
    
    // Create a new map to merge serverTimestamp
    final map = job.toMap();
    map['jobId'] = docRef.id;
    map['createdAt'] = FieldValue.serverTimestamp();
    
    await docRef.set(map);
  }
}
