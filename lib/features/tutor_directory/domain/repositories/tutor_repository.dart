import '../models/tutor_model.dart';

abstract class TutorRepository {
  Stream<List<TutorModel>> getTutorsStream({
    String? district,
    String? subject,
    int? maxSalary,
  });
}
