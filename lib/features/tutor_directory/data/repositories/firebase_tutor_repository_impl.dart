import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/tutor_model.dart';
import '../../domain/repositories/tutor_repository.dart';

class FirebaseTutorRepositoryImpl implements TutorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<TutorModel>> getTutorsStream({
    String? district,
    String? subject,
    int? maxSalary,
  }) {
    Query query = _firestore.collection('users').where('role', isEqualTo: 'tutor');

    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }

    return query.snapshots().map((snapshot) {
      var tutors = snapshot.docs.map((doc) {
        return TutorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      if (subject != null && subject.isNotEmpty) {
        tutors = tutors.where((t) => t.subjects.contains(subject)).toList();
      }
      if (maxSalary != null && maxSalary > 0) {
        // Tutors usually ask for a minimum expected salary. 
        // We filter out tutors who demand strictly MORE than the student's max budget.
        // We only include tutors whose expected salary is <= maxSalary.
        tutors = tutors.where((t) => t.expectedSalary > 0 && t.expectedSalary <= maxSalary).toList();
      }

      return tutors;
    });
  }
}
