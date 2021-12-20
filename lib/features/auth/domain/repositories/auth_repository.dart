import '../models/app_user.dart';
import '../models/user_role.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  
  AppUser? get currentUser;
  
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<AppUser> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? phoneNumber,
    String? gender,
    String? district,
    String? area,
  });
  
  Future<void> sendPasswordResetEmail({required String email});
  
  Future<void> sendEmailVerification();
  
  Future<void> reloadAuthUser();
  
  Future<void> signOut();
  
  Future<AppUser> updateProfileCompletionStatus({
    required String userId,
    required bool isComplete,
  });

  Future<void> updateStudentProfile({
    required String userId,
    required String studentType,
    required String studentGradeLevel,
    required List<String> subjects,
    required String district,
    required String area,
  });

  Future<void> updateTutorProfile({
    required String userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? district,
    String? area,
    String? headline,
    String? bio,
    List<String>? teachingLevels,
    List<String>? subjects,
    int? expectedMonthlyRate,
    int? expectedHourlyRate,
    String? highestQualification,
    String? institution,
    int? experienceYears,
    String? verificationStatus,
    String? citizenshipUrl,
    String? transcriptUrl,
    bool? isProfileComplete,
  });
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException() : super('No user found with this email.');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException() : super('An account already exists with this email.');
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Invalid email or password.');
}
