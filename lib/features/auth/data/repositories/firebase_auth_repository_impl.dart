import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  AppUser? _cachedUser;

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        _cachedUser = null;
        return null;
      }
      final appUser = await _fetchAppUser(fbUser.uid);
      _cachedUser = appUser;
      return appUser;
    });
  }

  @override
  AppUser? get currentUser => _cachedUser;

  Future<AppUser?> _fetchAppUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return AppUser(
        id: uid,
        email: data['email'] ?? '',
        fullName: data['fullName'] ?? '',
        role: UserRole.fromString(data['role'] ?? 'Student'),
        isProfileComplete: data['isProfileComplete'] ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      final user = await _fetchAppUser(credential.user!.uid);
      if (user == null) {
        throw const AuthException('User record not found in database.');
      }
      
      _cachedUser = user;
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      _throwMappedException(e);
    }
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      final uid = credential.user!.uid;
      
      final appUser = AppUser(
        id: uid,
        email: email,
        fullName: fullName,
        role: role,
        isProfileComplete: false,
        createdAt: DateTime.now(),
      );

      // Save user details to Firestore
      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': email,
        'fullName': fullName,
        'role': role.name,
        'isProfileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      _cachedUser = appUser;
      return appUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      _throwMappedException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      _throwMappedException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _cachedUser = null;
  }

  @override
  Future<AppUser> updateProfileCompletionStatus({
    required String userId,
    required bool isComplete,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isProfileComplete': isComplete,
      });
      
      final user = await _fetchAppUser(userId);
      if (user == null) throw const AuthException('User not found.');
      
      _cachedUser = user;
      return user;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Never _throwMappedException(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        throw const UserNotFoundException();
      case 'wrong-password':
        throw const InvalidCredentialsException();
      case 'invalid-credential':
        throw const InvalidCredentialsException();
      case 'email-already-in-use':
        throw const EmailAlreadyInUseException();
      case 'weak-password':
        throw const AuthException('The password provided is too weak.');
      case 'invalid-email':
        throw const AuthException('The email address is badly formatted.');
      default:
        throw AuthException(e.message ?? 'An unknown authentication error occurred.');
    }
  }
}
