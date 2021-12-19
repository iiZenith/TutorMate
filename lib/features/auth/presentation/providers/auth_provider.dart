import 'package:flutter/foundation.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthState {
  initial,
  unauthenticated,
  authenticating,
  needsOnboarding,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  
  AuthState _state = AuthState.initial;
  AppUser? _user;
  String? _errorMessage;

  AuthProvider(this._repository) {
    _init();
  }

  AuthState get state => _state;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.authenticating || _state == AuthState.initial;

  Future<void> _init() async {
    // Artificial splash delay
    await Future.delayed(const Duration(seconds: 2));
    
    _repository.authStateChanges.listen((appUser) {
      _user = appUser;
      if (appUser == null) {
        _state = AuthState.unauthenticated;
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
      if (_repository.currentUser == null) {
        _state = AuthState.unauthenticated;
      } else {
        _user = _repository.currentUser;
        _state = _user!.isProfileComplete ? AuthState.authenticated : AuthState.needsOnboarding;
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
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

  Future<void> signIn(String email, String password) async {
    _setLoading();
    try {
      await _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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

  Future<void> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Re-throw so UI can show a snackbar instead of changing the global state to error
      throw Exception(e.toString());
    }
  }

  Future<void> completeOnboarding() async {
    if (_user == null) return;
    _setLoading();
    try {
      await _repository.updateProfileCompletionStatus(
        userId: _user!.id,
        isComplete: true,
      );
    } catch (e) {
      _setError(e.toString());
    }
  }
}
