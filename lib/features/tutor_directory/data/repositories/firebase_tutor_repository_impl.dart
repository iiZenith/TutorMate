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
    if (subject != null && subject.isNotEmpty) {
      query = query.where('subjects', arrayContains: subject);
    }
    if (maxSalary != null && maxSalary > 0) {
      query = query.where('expectedMonthlyRate', isLessThanOrEqualTo: maxSalary);
    }

    return query.snapshots().map((snapshot) {
      var tutors = snapshot.docs.map((doc) {
        return TutorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      return tutors;
    });
  }
}
