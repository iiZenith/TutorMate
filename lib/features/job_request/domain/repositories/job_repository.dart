import '../models/job_request_model.dart';

abstract class JobRepository {
  Future<void> createJobRequest(JobRequestModel job);
  
  Stream<List<JobRequestModel>> getOpenJobsStream({
    String? district,
    String? subject,
    int? minBudget,
  });
}
