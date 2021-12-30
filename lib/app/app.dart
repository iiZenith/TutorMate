import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import 'package:tutormate/features/auth/presentation/providers/auth_provider.dart';
export 'package:tutormate/features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/data/repositories/firebase_auth_repository_impl.dart';
import 'router.dart';

// Provider to expose AuthProvider cleanly without 3rd-party dependencies for now
class AuthProviderInherited extends InheritedNotifier<AuthProvider> {
  const AuthProviderInherited({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AuthProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProviderInherited>()!.notifier!;
  }
}

class TutorMateApp extends StatefulWidget {
  const TutorMateApp({super.key});

  @override
  State<TutorMateApp> createState() => _TutorMateAppState();
}

class _TutorMateAppState extends State<TutorMateApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authRepository = FirebaseAuthRepositoryImpl();
    _authProvider = AuthProvider(authRepository);
    _router = createAppRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthProviderInherited(
      notifier: _authProvider,
      child: MaterialApp.router(
        title: 'TutorMate',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Will be overridden in dashboards for test
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
