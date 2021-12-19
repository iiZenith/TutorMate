import 'package:go_router/go_router.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/auth/domain/models/user_role.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/auth_error_screen.dart';
import '../features/auth/presentation/screens/landing_screen.dart';
import '../features/auth/presentation/screens/quick_entry_screen.dart';
import '../features/auth/presentation/screens/detailed_registration_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/onboarding/presentation/screens/student_onboarding_screen.dart';
import '../features/onboarding/presentation/screens/tutor_onboarding_screen.dart';
import '../features/onboarding/presentation/screens/institute_onboarding_screen.dart';
import '../features/tutor_dashboard/presentation/screens/tutor_main_layout.dart';
import '../features/dashboard/presentation/screens/institute_dashboard_screen.dart';
import '../features/student_dashboard/presentation/screens/student_main_layout.dart';
import '../features/student_dashboard/presentation/screens/student_dashboard_content.dart';
import '../features/job_request/presentation/screens/hire_tutor_screen.dart';
import '../features/tutor_directory/presentation/screens/find_tutors_screen.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final authState = authProvider.state;
      final isGoingToAuth = state.matchedLocation == '/landing' ||
          state.matchedLocation == '/quick-entry' ||
          state.matchedLocation == '/detailed-registration' ||
          state.matchedLocation == '/login';

      if (authState == AuthState.initial) {
        return '/splash';
      }

      if (authState == AuthState.error) {
        if (state.matchedLocation != '/auth-error') return '/auth-error';
        return null;
      }

      if (authState == AuthState.unauthenticated) {
        if (!isGoingToAuth) return '/landing';
        return null;
      }

      if (authState == AuthState.needsOnboarding) {
        final role = authProvider.user?.role;
        if (role == UserRole.studentGuardian && state.matchedLocation != '/onboarding/student') return '/onboarding/student';
        if (role == UserRole.tutor && state.matchedLocation != '/onboarding/tutor') return '/onboarding/tutor';
        if (role == UserRole.institute && state.matchedLocation != '/onboarding/institute') return '/onboarding/institute';
        return null; // Already on the right onboarding screen
      }

      if (authState == AuthState.authenticated) {
        final role = authProvider.user?.role;
        final loc = state.matchedLocation;

        if (role == UserRole.studentGuardian) {
          if (!loc.startsWith('/dashboard/student') && loc != '/find-tutors' && loc != '/hire-tutor') {
            return '/dashboard/student';
          }
        } else if (role == UserRole.tutor) {
          if (!loc.startsWith('/dashboard/tutor')) {
            return '/dashboard/tutor';
          }
        } else if (role == UserRole.institute) {
          if (!loc.startsWith('/dashboard/institute')) {
            return '/dashboard/institute';
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth-error',
        builder: (context, state) => const AuthErrorScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/quick-entry',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'Student';
          return QuickEntryScreen(role: role);
        },
      ),
      GoRoute(
        path: '/detailed-registration',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'Student';
          final email = state.uri.queryParameters['email'] ?? '';
          return DetailedRegistrationScreen(role: role, initialEmail: email);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'Student';
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/onboarding/student',
        builder: (context, state) => const StudentOnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/tutor',
        builder: (context, state) => const TutorOnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/institute',
        builder: (context, state) => const InstituteOnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard/student',
        builder: (context, state) => const StudentMainLayout(
          child: StudentDashboardContent(),
        ),
      ),
      GoRoute(
        path: '/hire-tutor',
        builder: (context, state) => const HireTutorScreen(),
      ),
      GoRoute(
        path: '/find-tutors',
        builder: (context, state) => const FindTutorsScreen(),
      ),
      GoRoute(
        path: '/dashboard/tutor',
        builder: (context, state) => const TutorMainLayout(),
      ),
      GoRoute(
        path: '/dashboard/institute',
        builder: (context, state) => const InstituteDashboardScreen(),
      ),
    ],
  );
}
