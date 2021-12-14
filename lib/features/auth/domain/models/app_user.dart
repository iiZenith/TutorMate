import 'user_role.dart';

class AppUser {
  final String id;
  final String email;
  final String? phoneNumber;
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
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
