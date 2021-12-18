class SeedArea {
  final String name;

  const SeedArea({required this.name});
}

class SeedDistrict {
  final String name;
  final List<SeedArea> areas;

  const SeedDistrict({
    required this.name,
    required this.areas,
  });
}

class SeedProvince {
  final String name;
  final List<SeedDistrict> districts;

  const SeedProvince({
    required this.name,
    required this.districts,
  });
}

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
