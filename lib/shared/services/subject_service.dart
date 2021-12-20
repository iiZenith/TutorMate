import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getSubjects() async {
    try {
      final doc = await _firestore.collection('platform_metadata').doc('subjects').get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['items'] is List) {
          final List<String> subjects = List<String>.from(data['items']);
          subjects.sort();
          return subjects;
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }
}
