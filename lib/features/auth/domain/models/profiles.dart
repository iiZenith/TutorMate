import '../../../../shared/models/geo_area.dart';
import '../../../../shared/models/tuition_type.dart';
import '../../../../shared/models/gender_preference.dart';

enum StudentOrGuardianType { student, parentGuardian }

class TutorProfile {
  final String tutorId;
  final String headline;
  final String bio;
  final List<String> qualifications;
  final List<String> teachingMedium;
  final List<TuitionType> tuitionTypes;
  final List<String> targetLevels;
  final List<String> subjects;
  final double? monthlyRate;
  final double? hourlyRate;
  final GeoArea serviceLocation;
  final bool isIdentityVerified;

  const TutorProfile({
    required this.tutorId,
    required this.headline,
    required this.bio,
    required this.qualifications,
    required this.teachingMedium,
    required this.tuitionTypes,
    required this.targetLevels,
    required this.subjects,
    this.monthlyRate,
    this.hourlyRate,
    required this.serviceLocation,
    this.isIdentityVerified = false,
  });
}

class StudentGuardianProfile {
  final String studentGuardianId;
  final StudentOrGuardianType userType;
  final String studentGradeLevel;
  final String? institutionName;
  final List<String> interestedSubjects;
  final TuitionType preferredTuitionType;
  final GenderPreference preferredTutorGender;
  final GeoArea location;

  const StudentGuardianProfile({
    required this.studentGuardianId,
    required this.userType,
    required this.studentGradeLevel,
    this.institutionName,
    required this.interestedSubjects,
    required this.preferredTuitionType,
    required this.preferredTutorGender,
    required this.location,
  });
}

class InstituteProfile {
  final String instituteId;
  final String instituteName;
  final String registrationNumber;
  final String contactPersonName;
  final String contactPersonDesignation;
  final String officialEmail;
  final String officeAddress;
  final List<String> servicesOffered;
  final bool isVerified;

  const InstituteProfile({
    required this.instituteId,
    required this.instituteName,
    required this.registrationNumber,
    required this.contactPersonName,
    required this.contactPersonDesignation,
    required this.officialEmail,
    required this.officeAddress,
    required this.servicesOffered,
    this.isVerified = false,
  });
}
