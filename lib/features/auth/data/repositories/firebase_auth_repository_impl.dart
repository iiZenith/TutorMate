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
      try {
        final appUser = await _fetchAppUser(fbUser.uid);
        if (appUser == null) {
          throw const AuthException('User profile not found in database.');
        }
        _cachedUser = appUser;
        return appUser;
      } catch (e) {
        // If we fail to fetch the profile, we throw so the stream emits an error,
        // rather than returning null (which implies logged out).
        throw AuthException(e is AuthException ? e.message : 'Error loading user profile.');
      }
    });
  }

  @override
  AppUser? get currentUser => _cachedUser;

  Future<AppUser?> _fetchAppUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    final roleStr = data['role'] as String?;
    final parsedRole = UserRole.fromString(roleStr);
    if (parsedRole == null) {
      throw const AuthException('Invalid or missing user role.');
    }

    final fbUser = _firebaseAuth.currentUser;
    final isEmailVerified = fbUser?.emailVerified ?? false;

    return AppUser(
      id: uid,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      gender: data['gender'] as String?,
      province: data['province'] as String?,
      district: data['district'] as String?,
      area: data['area'] as String?,
      role: parsedRole,
      isEmailVerified: isEmailVerified,
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      studentType: data['studentType'] as String?,
      studentGradeLevel: data['studentGradeLevel'] as String?,
      subjects: List<String>.from(data['subjects'] ?? []),
      headline: data['headline'] as String?,
      bio: data['bio'] as String?,
      teachingLevels: List<String>.from(data['teachingLevels'] ?? []),
      expectedMonthlyRate: (data['expectedMonthlyRate'] as num?)?.toInt(),
      expectedHourlyRate: (data['expectedHourlyRate'] as num?)?.toInt(),
      highestQualification: data['highestQualification'] as String?,
      institution: data['institution'] as String?,
      experienceYears: (data['experienceYears'] as num?)?.toInt(),
      verificationStatus: data['verificationStatus'] as String?,
      citizenshipUrl: data['citizenshipUrl'] as String?,
      transcriptUrl: data['transcriptUrl'] as String?,
    );
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
    String? phoneNumber,
    String? gender,
    String? province,
    String? district,
    String? area,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      final fbUser = credential.user!;
      if (!fbUser.emailVerified) {
        await fbUser.sendEmailVerification();
      }
      
      final uid = fbUser.uid;
      
      final appUser = AppUser(
        id: uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        gender: gender,
        province: province,
        district: district,
        area: area,
        role: role,
        isProfileComplete: false,
        createdAt: DateTime.now(),
      );

      // Save user details to Firestore
      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'province': province,
        'district': district,
        'area': area,
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
  Future<void> sendEmailVerification() async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null && !fbUser.emailVerified) {
        await fbUser.sendEmailVerification();
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      _throwMappedException(e);
    }
  }

  @override
  Future<void> reloadAuthUser() async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null) {
        await fbUser.reload();
        // After reload, fetch app user again to update the cache and trigger stream if needed.
        // Actually, just fetching app user and assigning it is enough, but to trigger stream we might need to manually add if we had a controller.
        // Since we map authStateChanges, reload doesn't always fire it. 
        final appUser = await _fetchAppUser(fbUser.uid);
        _cachedUser = appUser;
      }
    } catch (e) {
      throw AuthException(e.toString());
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

  @override
  Future<void> updateStudentProfile({
    required String userId,
    required String studentType,
    required String studentGradeLevel,
    required List<String> subjects,
    String? province,
    required String district,
    required String area,
  }) async {
    try {
      final updates = <String, dynamic>{
        'studentType': studentType,
        'studentGradeLevel': studentGradeLevel,
        'subjects': subjects,
        'district': district,
        'area': area,
      };
      if (province != null && province.isNotEmpty) {
        updates['province'] = province;
      }
      await _firestore.collection('users').doc(userId).update(updates);
      _cachedUser = await _fetchAppUser(userId);
    } catch (e) {
      throw AuthException('Failed to update student profile: $e');
    }
  }

  @override
  Future<void> updateTutorProfile({
    required String userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? province,
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
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (province != null) updates['province'] = province;
      if (district != null) updates['district'] = district;
      if (area != null) updates['area'] = area;
      if (headline != null) updates['headline'] = headline;
      if (bio != null) updates['bio'] = bio;
      if (teachingLevels != null) updates['teachingLevels'] = teachingLevels;
      if (subjects != null) updates['subjects'] = subjects;
      if (expectedMonthlyRate != null) updates['expectedMonthlyRate'] = expectedMonthlyRate;
      if (expectedHourlyRate != null) updates['expectedHourlyRate'] = expectedHourlyRate;
      if (highestQualification != null) updates['highestQualification'] = highestQualification;
      if (institution != null) updates['institution'] = institution;
      if (experienceYears != null) updates['experienceYears'] = experienceYears;
      if (verificationStatus != null) updates['verificationStatus'] = verificationStatus;
      if (citizenshipUrl != null) updates['citizenshipUrl'] = citizenshipUrl;
      if (transcriptUrl != null) updates['transcriptUrl'] = transcriptUrl;
      if (isProfileComplete != null) updates['isProfileComplete'] = isProfileComplete;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
        _cachedUser = await _fetchAppUser(userId);
      }
    } catch (e) {
      throw AuthException('Failed to update tutor profile: $e');
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
