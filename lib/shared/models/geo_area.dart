class GeoArea {
  final String city;
  final String neighborhood;
  final double? serviceRadiusKm; // Primarily for tutors
  final String? landmark; // Primarily for students/institutes

  const GeoArea({
    required this.city,
    required this.neighborhood,
    this.serviceRadiusKm,
    this.landmark,
  });
}
