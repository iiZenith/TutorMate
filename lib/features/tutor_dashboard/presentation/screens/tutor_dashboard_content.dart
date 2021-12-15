import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_colors.dart';

class TutorDashboardContent extends StatelessWidget {
  const TutorDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthProviderInherited.of(context).user;
    final firstName = user?.fullName.split(' ').first ?? 'Tutor';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting
          Text(
            'Namaste, $firstName 👋',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),

          // Subtle Verification Banner
          if (user != null && !user.isProfileComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadii.borderRadiusMedium,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.warning.withValues(alpha: 0.8)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your profile verification is pending. Some features may be limited.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),

          // Quick Summary Strip
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadii.borderRadiusMedium,
              border: Border.all(color: theme.dividerTheme.color ?? theme.colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const _SummaryItem(title: 'Active Students', value: '0'),
                Container(height: 30, width: 1, color: theme.dividerTheme.color ?? theme.colorScheme.outline.withValues(alpha: 0.2)),
                const _SummaryItem(title: 'Applications', value: '0'),
                Container(height: 30, width: 1, color: theme.dividerTheme.color ?? theme.colorScheme.outline.withValues(alpha: 0.2)),
                const _SummaryItem(title: 'Earnings', value: 'Rs. 0'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Primary Focus Card
          Card(
            elevation: 4,
            shadowColor: theme.shadowColor.withValues(alpha: 0.1),
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusLarge),
            color: theme.colorScheme.primary,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switching to Job Board...')),
                );
              },
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
                            'Browse Available Tuitions',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Find new students and grow your tutoring business.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                            ),
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

          // Recent Jobs Section (Empty State)
          Text('Recent Jobs in Your Area', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xl),
          
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No tuitions posted in your area yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () {
                    // Refresh action mock
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}
