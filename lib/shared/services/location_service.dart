import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_models.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'locations';

  Future<List<ProvinceDoc>> getLocationsTree() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      if (snapshot.docs.isNotEmpty) {
        final provinces = snapshot.docs.map((doc) => ProvinceDoc.fromMap(doc.data(), doc.id)).toList();
        provinces.sort((a, b) => a.name.compareTo(b.name));
        return provinces;
      }
      return []; // Return empty list if empty, NO static fallback
    } catch (e) {
      throw Exception('Failed to load locations: $e');
    }
  }
}
