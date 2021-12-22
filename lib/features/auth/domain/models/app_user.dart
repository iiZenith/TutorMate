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

  // Student specific
  final String? studentType;
  final String? studentGradeLevel;
  final List<String> subjects;

  // Tutor specific
  final String? headline;
  final String? bio;
  final List<String> teachingLevels;
  final int? expectedMonthlyRate;
  final int? expectedHourlyRate;
  final String? highestQualification;
  final String? institution;
  final int? experienceYears;
  final String? verificationStatus;
  final String? citizenshipUrl;
  final String? transcriptUrl;

  bool get isValidStudentProfile {
    return studentType != null &&
        studentType!.isNotEmpty &&
        studentGradeLevel != null &&
        studentGradeLevel!.isNotEmpty &&
        subjects.isNotEmpty &&
        district != null &&
        district!.isNotEmpty &&
        area != null &&
        area!.isNotEmpty;
  }

  bool get isValidTutorProfile {
    return headline != null &&
        headline!.isNotEmpty &&
        bio != null &&
        bio!.isNotEmpty &&
        teachingLevels.isNotEmpty &&
        expectedMonthlyRate != null &&
        expectedMonthlyRate! > 0;
  }

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
    this.studentType,
    this.studentGradeLevel,
    this.subjects = const [],
    this.headline,
    this.bio,
    this.teachingLevels = const [],
    this.expectedMonthlyRate,
    this.expectedHourlyRate,
    this.highestQualification,
    this.institution,
    this.experienceYears,
    this.verificationStatus,
    this.citizenshipUrl,
    this.transcriptUrl,
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
    String? studentType,
    String? studentGradeLevel,
    List<String>? subjects,
    String? headline,
    String? bio,
    List<String>? teachingLevels,
    int? expectedMonthlyRate,
    int? expectedHourlyRate,
    String? highestQualification,
    String? institution,
    int? experienceYears,
    String? verificationStatus,
    String? citizenshipUrl,
    String? transcriptUrl,
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
      studentType: studentType ?? this.studentType,
      studentGradeLevel: studentGradeLevel ?? this.studentGradeLevel,
      subjects: subjects ?? this.subjects,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      teachingLevels: teachingLevels ?? this.teachingLevels,
      expectedMonthlyRate: expectedMonthlyRate ?? this.expectedMonthlyRate,
      expectedHourlyRate: expectedHourlyRate ?? this.expectedHourlyRate,
      highestQualification: highestQualification ?? this.highestQualification,
      institution: institution ?? this.institution,
      experienceYears: experienceYears ?? this.experienceYears,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      citizenshipUrl: citizenshipUrl ?? this.citizenshipUrl,
      transcriptUrl: transcriptUrl ?? this.transcriptUrl,
    );
  }
}
