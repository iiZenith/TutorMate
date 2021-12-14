import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../job_discovery/data/mocks/mock_jobs.dart';

class TutorDashboardContent extends StatelessWidget {
  const TutorDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Metrics Grid
          Row(
            children: [
              Expanded(child: _MetricCard(title: 'Active Students', value: '3', icon: Icons.group)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _MetricCard(title: 'Pending Apps', value: '5', icon: Icons.pending_actions)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _MetricCard(title: 'Profile Views', value: '12', icon: Icons.visibility, subtext: 'this week')),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _MetricCard(title: 'Total Earned', value: 'Rs. 15K', icon: Icons.account_balance_wallet, color: AppColors.success)),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          // Warning Banner
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.borderRadiusMedium,
              side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            color: AppColors.warning.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Your Profile', 
                          style: theme.textTheme.titleMedium?.copyWith(color: AppColors.warning)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Identity verification is required before you can apply for jobs.', 
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
          Text('Recent Job Matches', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockJobs.length,
              itemBuilder: (context, index) {
                final job = mockJobs[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: AppSpacing.md, bottom: AppSpacing.xs),
                  child: Card(
                    elevation: 4,
                    shadowColor: theme.shadowColor.withValues(alpha: 0.1),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusMedium),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.subject, 
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${job.city} - ${job.location}',
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                job.feeRange,
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                              ),
                              Text(
                                job.gradeLevel,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtext;
  final Color? color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtext,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finalColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withValues(alpha: 0.05),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 18, color: finalColor.withValues(alpha: 0.7)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: finalColor,
              ),
            ),
            if (subtext != null) ...[
              const SizedBox(height: 2),
              Text(
                subtext!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
