import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';

class AuthErrorScreen extends StatelessWidget {
  const AuthErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProviderInherited.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Authentication Error',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                authProvider.errorMessage ?? 'An unknown error occurred.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: 'Sign Out & Retry',
                onPressed: () {
                  authProvider.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
