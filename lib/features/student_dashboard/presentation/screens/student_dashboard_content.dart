import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_colors.dart';

class StudentDashboardContent extends StatelessWidget {
  const StudentDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Alert / Notice Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.borderRadiusMedium,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            color: AppColors.error.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete your profile', 
                          style: theme.textTheme.titleMedium?.copyWith(color: AppColors.error)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confirm you are a genuine user (30% complete)', 
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7)
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action Banner
          Card(
            elevation: 8,
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
                            'Hire a Tutor', 
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Post a requirement and find the best match for your needs.', 
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                            )
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onPrimary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Text('Your Requests', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Pending', icon: Icons.hourglass_empty, color: AppColors.warning),
              _StatItem(label: 'Active', icon: Icons.play_circle_outline, color: AppColors.info),
              _StatItem(label: 'Completed', icon: Icons.check_circle_outline, color: AppColors.success),
              _StatItem(label: 'Cancelled', icon: Icons.cancel_outlined, color: AppColors.error),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label, 
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
        ),
      ],
    );
  }
}
