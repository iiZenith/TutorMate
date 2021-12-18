import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_models.dart';
import '../../core/constants/nepal_locations.dart';

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
    } catch (e) {
      // Fallback to local
    }

    // Fallback if empty or error
    return nepalProvinces.map((p) {
      final districtsMap = <String, List<String>>{};
      for (var d in p.districts) {
        final sortedAreas = d.areas.map((a) => a.name).toList()..sort();
        districtsMap[d.name] = sortedAreas;
      }
      return ProvinceDoc(name: p.name, districts: districtsMap);
    }).toList();
  }
}
