import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProviderInherited.of(context);
    final theme = Theme.of(context);
    final email = authProvider.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.mark_email_unread_outlined, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Verify your email address',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'We sent a verification link to:\n$email\n\nPlease check your inbox and click the link to verify your account.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: 'I\'ve verified my email',
                isLoading: authProvider.isLoading,
                onPressed: () async {
                  await authProvider.reloadUser();
                  // Re-triggering notifyListeners() from provider will update GoRouter
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Resend Verification Email',
                isSecondary: true,
                onPressed: () async {
                  try {
                    await authProvider.sendEmailVerification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email resent.')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
                    }
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => authProvider.signOut(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
