import 'package:flutter_test/flutter_test.dart';
import 'package:tutormate/features/job_request/domain/models/job_request_model.dart';
import 'package:tutormate/features/job_request/domain/models/tutor_interest_model.dart';

void main() {
  group('JobRequestModel tests', () {
    test('JobRequestStatus fromString parses valid status values', () {
      expect(JobRequestStatus.fromString('open'), JobRequestStatus.open);
      expect(JobRequestStatus.fromString('ACCEPTED'), JobRequestStatus.accepted);
      expect(JobRequestStatus.fromString('rejected'), JobRequestStatus.rejected);
      expect(JobRequestStatus.fromString('cancelled'), JobRequestStatus.cancelled);
      expect(JobRequestStatus.fromString('canceled'), JobRequestStatus.cancelled);
      expect(JobRequestStatus.fromString(null), JobRequestStatus.open);
    });

    test('fromMap handles missing/corrupt fields safely', () {
      final model = JobRequestModel.fromMap({
        'studentId': 'student123',
        'budgetNpr': '5000',
        'status': 'OPEN',
      }, 'job123');

      expect(model.jobId, 'job123');
      expect(model.studentId, 'student123');
      expect(model.budgetNpr, 5000);
      expect(model.status, 'OPEN');
      expect(model.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });

  group('TutorInterestModel tests', () {
    test('TutorInterestStatus parses statuses', () {
      expect(TutorInterestStatus.fromString('submitted'), TutorInterestStatus.submitted);
      expect(TutorInterestStatus.fromString('ACCEPTED'), TutorInterestStatus.accepted);
      expect(TutorInterestStatus.fromString('rejected'), TutorInterestStatus.rejected);
      expect(TutorInterestStatus.fromString('withdrawn'), TutorInterestStatus.withdrawn);
    });
  });
}
