import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthState {
  initial,
  unauthenticated,
  authenticating,
  needsVerification,
  needsOnboarding,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  
  AuthState _state = AuthState.initial;
  AppUser? _user;
  String? _errorMessage;
  StreamSubscription<AppUser?>? _authSubscription;

  AuthProvider(this._repository) {
    _init();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  AuthState get state => _state;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.authenticating || _state == AuthState.initial;

  void _init() {
    _authSubscription = _repository.authStateChanges.listen((appUser) {
      _user = appUser;
      if (appUser == null) {
        _state = AuthState.unauthenticated;
      } else if (!appUser.isEmailVerified) {
        _state = AuthState.needsVerification;
      } else if (!appUser.isProfileComplete) {
        _state = AuthState.needsOnboarding;
      } else {
        _state = AuthState.authenticated;
      }
      notifyListeners();
    }, onError: (error) {
      _user = null;
      _state = AuthState.error;
      _errorMessage = error.toString();
      notifyListeners();
    });
    
    // Set initial state
    try {
      final current = _repository.currentUser;
      if (current == null) {
        _state = AuthState.unauthenticated;
      } else {
        _user = current;
        if (!current.isEmailVerified) {
          _state = AuthState.needsVerification;
        } else if (!current.isProfileComplete) {
          _state = AuthState.needsOnboarding;
        } else {
          _state = AuthState.authenticated;
        }
      }
      notifyListeners();
    } catch (_) {
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  void _setLoading() {
    _state = AuthState.authenticating;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> signIn(String email, String password, {UserRole? expectedRole}) async {
    _setLoading();
    try {
      final loggedInUser = await _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (expectedRole != null && loggedInUser.role != expectedRole) {
        await _repository.signOut();
        _setError('The selected account type does not match this account.');
        return;
      }
      // The stream listener will handle the state update
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> register(
    String fullName, 
    String email, 
    String password, 
    UserRole role, {
    String? phoneNumber,
    String? gender,
    String? province,
    String? district,
    String? area,
  }) async {
    _setLoading();
    try {
      await _repository.registerWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        phoneNumber: phoneNumber,
        gender: gender,
        province: province,
        district: district,
        area: area,
      );
      // The stream listener will handle the state update
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signOut() async {
    _setLoading();
    try {
      await _repository.signOut();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> reloadUser() async {
    _setLoading();
    try {
      await _repository.reloadAuthUser();
      _user = _repository.currentUser;
      if (_user == null) {
        _state = AuthState.unauthenticated;
      } else if (!_user!.isEmailVerified) {
        _state = AuthState.needsVerification;
      } else if (!_user!.isProfileComplete) {
        _state = AuthState.needsOnboarding;
      } else {
        _state = AuthState.authenticated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _repository.sendEmailVerification();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<void> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Re-throw so UI can show a snackbar instead of changing the global state to error
      throw Exception(e.toString());
    }
  }

  Future<void> updateStudentProfile({
    String? fullName,
    String? phoneNumber,
    String? gender,
    String? studentType,
    String? studentGradeLevel,
    List<String>? subjects,
    String? province,
    String? district,
    String? area,
    String? avatarUrl,
  }) async {
    if (_user == null) return;
    _setLoading();
    try {
      await _repository.updateStudentProfile(
        userId: _user!.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        gender: gender,
        studentType: studentType,
        studentGradeLevel: studentGradeLevel,
        subjects: subjects,
        province: province,
        district: district,
        area: area,
        avatarUrl: avatarUrl,
      );
      _user = _repository.currentUser;
      if (_user?.isProfileComplete == true) {
        _state = AuthState.authenticated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateTutorProfile({
    String? fullName,
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
    String? avatarUrl,
    bool? isProfileComplete,
  }) async {
    if (_user == null) return;
    _setLoading();
    try {
      await _repository.updateTutorProfile(
        userId: _user!.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        province: province,
        district: district,
        area: area,
        headline: headline,
        bio: bio,
        teachingLevels: teachingLevels,
        subjects: subjects,
        expectedMonthlyRate: expectedMonthlyRate,
        expectedHourlyRate: expectedHourlyRate,
        highestQualification: highestQualification,
        institution: institution,
        experienceYears: experienceYears,
        verificationStatus: verificationStatus,
        citizenshipUrl: citizenshipUrl,
        transcriptUrl: transcriptUrl,
        avatarUrl: avatarUrl,
        isProfileComplete: isProfileComplete,
      );
      _user = _repository.currentUser;
      if (_user?.isProfileComplete == true) {
        _state = AuthState.authenticated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> completeOnboarding() async {
    if (_user == null) return;
    _setLoading();
    try {
      // Re-fetch user to get latest state from backend
      await _repository.reloadAuthUser();
      _user = _repository.currentUser;

      if (_user == null) throw Exception('User not found');

      bool isValid = false;
      if (_user!.role == UserRole.studentGuardian) {
        isValid = _user!.isValidStudentProfile;
      } else if (_user!.role == UserRole.tutor) {
        isValid = _user!.isValidTutorProfile;
      }

      if (!isValid) {
        throw Exception('Profile is incomplete. Please fill all required fields.');
      }

      await _repository.updateProfileCompletionStatus(
        userId: _user!.id,
        isComplete: true,
      );
      _user = _repository.currentUser;
      _state = AuthState.authenticated;
      notifyListeners();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
