import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';

class StudentDashboardContent extends StatelessWidget {
  const StudentDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthProviderInherited.of(context).user;
    final firstName = user?.fullName.split(' ').first ?? 'Student';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting & Header
          Text(
            'Namaste, $firstName 👋',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Find a Home Tutor in Kathmandu Valley',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Primary Action Card
          Card(
            elevation: 4,
            shadowColor: theme.shadowColor.withValues(alpha: 0.1),
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusLarge),
            color: theme.colorScheme.primary,
            child: InkWell(
              onTap: () => context.push('/hire-tutor'),
              borderRadius: AppRadii.borderRadiusLarge,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request a Home Tutor', 
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Post your specific requirements and let qualified tutors reach out to you.', 
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                            )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.arrow_forward, color: theme.colorScheme.onPrimary, size: 32),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          
          Text('My Requests', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xl),
          
          // Empty State for Requests
          Center(
            child: Column(
              children: [
                Icon(Icons.assignment_add, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'You haven\'t requested any tutors yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.push('/hire-tutor'),
                  child: const Text('Tap here to post your first requirement'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          Text('Tutor Directory', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xl),
          
          // Empty State for Directory Feed
          Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Tutor directory is currently refreshing.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Directory'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
