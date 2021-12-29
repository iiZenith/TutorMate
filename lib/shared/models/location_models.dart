class ProvinceDoc {
  final String name;
  final Map<String, List<String>> districts;

  const ProvinceDoc({
    required this.name,
    required this.districts,
  });

  factory ProvinceDoc.fromMap(Map<String, dynamic> map, String id) {
    final districtsMap = map['districts'] as Map<String, dynamic>? ?? {};
    final parsedDistricts = <String, List<String>>{};

    districtsMap.forEach((districtName, districtData) {
      if (districtData is Map && districtData['areas'] is List) {
        parsedDistricts[districtName] = List<String>.from(districtData['areas']);
      }
    });

    return ProvinceDoc(
      name: map['name'] ?? id,
      districts: parsedDistricts,
    );
  }
}
