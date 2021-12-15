import '../models/job_request_model.dart';

abstract class JobRepository {
  Future<void> createJobRequest(JobRequestModel job);
}
