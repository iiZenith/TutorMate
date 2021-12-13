import 'user_role.dart';

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final String displayName;
  final String? profilePhotoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
    this.profilePhotoUrl,
    required this.createdAt,
  });

  // Example factory and toMap for future use
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.parentStudent,
      ),
      displayName: map['displayName'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.name,
      'displayName': displayName,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
