import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../job_request/domain/models/job_request_model.dart';
import '../../../job_request/data/repositories/firebase_job_repository_impl.dart';

class TutorDashboardContent extends StatefulWidget {
  final VoidCallback? onBrowseTuitions;

  const TutorDashboardContent({super.key, this.onBrowseTuitions});

  @override
  State<TutorDashboardContent> createState() => _TutorDashboardContentState();
}

class _TutorDashboardContentState extends State<TutorDashboardContent> {
  final _jobRepository = FirebaseJobRepositoryImpl();

  Future<void> _handleRefresh() async {
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.reloadUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    final user = authProvider.user;
    final firstName = user?.fullName.split(' ').first ?? 'Tutor';

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
            if (user != null && user.verificationStatus != 'approved')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: user.verificationStatus == 'rejected' ? Colors.red.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppRadii.borderRadiusMedium,
                  border: Border.all(color: user.verificationStatus == 'rejected' ? Colors.red.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      user.verificationStatus == 'rejected' ? Icons.cancel : Icons.info_outline, 
                      size: 20, 
                      color: user.verificationStatus == 'rejected' ? Colors.red : AppColors.warning.withValues(alpha: 0.8)
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        user.verificationStatus == 'rejected' 
                          ? 'Your profile verification was rejected. Please update your documents.'
                          : user.verificationStatus == 'pending' 
                            ? 'Your profile verification is pending.'
                            : 'Your profile verification is not submitted. Some features may be limited.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
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
                  if (widget.onBrowseTuitions != null) {
                    widget.onBrowseTuitions!();
                  }
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

            // Recent Jobs Section (Firestore Backed)
            Text('Recent Jobs in Your Area', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),

            StreamBuilder<List<JobRequestModel>>(
              stream: _jobRepository.getOpenJobsStream(
                district: (user?.district?.isNotEmpty == true) ? user!.district : null,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Error loading recent jobs.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                      ),
                    ),
                  );
                }

                final jobs = snapshot.data ?? [];

                if (jobs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
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
                            onPressed: _handleRefresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: jobs.take(3).map((job) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusMedium),
                      child: ListTile(
                        title: Text(
                          job.subjects.isNotEmpty ? job.subjects.join(', ') : 'General Subjects',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${job.grade} • ${job.district} - ${job.area}'),
                        trailing: Text(
                          'Rs. ${job.budgetNpr}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          if (widget.onBrowseTuitions != null) {
                            widget.onBrowseTuitions!();
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
