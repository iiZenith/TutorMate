import '../models/job_request_model.dart';
import '../models/tutor_interest_model.dart';

abstract class JobRepository {
  Future<void> createJobRequest(JobRequestModel job);
  
  Stream<List<JobRequestModel>> getOpenJobsStream({
    String? district,
    String? subject,
    int? minBudget,
  });

  Stream<List<JobRequestModel>> getMyRequestsStream(String studentId);

  Future<void> expressInterest({
    required String jobId,
    required String tutorId,
    required String tutorName,
  });

  Stream<List<TutorInterestModel>> getInterestsForJob(String jobId);

  Stream<List<TutorInterestModel>> getMyInterestsStream(String tutorId);

  Future<void> acceptInterest(String jobId, String interestId);
  Future<void> rejectInterest(String interestId);
}
