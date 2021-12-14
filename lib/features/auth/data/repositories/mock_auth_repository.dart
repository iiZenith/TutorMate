import 'dart:async';
import '../../domain/models/app_user.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _authStateController = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;
  
  // In-memory database of mock users
  final Map<String, AppUser> _users = {};
  final Map<String, String> _passwords = {}; // email -> password map

  @override
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  @override
  AppUser? get currentUser => _currentUser;

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _updateUser(AppUser? user) {
    _currentUser = user;
    if (user != null) {
      _users[user.id] = user;
    }
    _authStateController.add(user);
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();
    
    final matchingUsers = _users.values.where((u) => u.email == email).toList();
    if (matchingUsers.isEmpty) {
      throw const UserNotFoundException();
    }
    
    final storedPassword = _passwords[email];
    if (storedPassword != password) {
      throw const InvalidCredentialsException();
    }
    
    final user = matchingUsers.first;
    _updateUser(user);
    return user;
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await _simulateNetworkDelay();
    
    if (_users.values.any((u) => u.email == email)) {
      throw const EmailAlreadyInUseException();
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw const AuthException('Invalid email format.');
    }
    
    final newUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Mock UUID
      email: email,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
      isProfileComplete: false,
    );
    
    _passwords[email] = password;
    _updateUser(newUser);
    return newUser;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _simulateNetworkDelay();
    if (!_users.values.any((u) => u.email == email)) {
      throw const UserNotFoundException();
    }
    // Simulation success
  }

  @override
  Future<void> signOut() async {
    await _simulateNetworkDelay();
    _updateUser(null);
  }

  @override
  Future<AppUser> updateProfileCompletionStatus({
    required String userId,
    required bool isComplete,
  }) async {
    await _simulateNetworkDelay();
    final user = _users[userId];
    if (user == null) {
      throw const AuthException('User not found.');
    }
    
    final updatedUser = user.copyWith(isProfileComplete: isComplete);
    _updateUser(updatedUser);
    return updatedUser;
  }
}
