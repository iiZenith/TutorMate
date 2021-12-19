import 'user_role.dart';

class AppUser {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? gender;
  final String? district;
  final String? area;
  final String fullName;
  final UserRole role;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final DateTime createdAt;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.gender,
    this.district,
    this.area,
    required this.fullName,
    required this.role,
    this.isEmailVerified = false,
    this.isProfileComplete = false,
    required this.createdAt,
    this.avatarUrl,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? gender,
    String? district,
    String? area,
    String? fullName,
    UserRole? role,
    bool? isEmailVerified,
    bool? isProfileComplete,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      district: district ?? this.district,
      area: area ?? this.area,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
