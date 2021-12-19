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
  
  Future<void> signOut();
  
  Future<AppUser> updateProfileCompletionStatus({
    required String userId,
    required bool isComplete,
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
