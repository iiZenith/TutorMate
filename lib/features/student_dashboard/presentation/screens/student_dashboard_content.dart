import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../job_request/data/repositories/firebase_job_repository_impl.dart';
import '../../../job_request/domain/models/job_request_model.dart';

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
            'Find a Home Tutor in your area',
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
          
          Text('My Recent Requests', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          
          StreamBuilder<List<JobRequestModel>>(
            stream: user != null ? FirebaseJobRepositoryImpl().getMyRequestsStream(user.id) : const Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading requests.'));
              }
              
              final requests = snapshot.data ?? [];
              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Icon(Icons.assignment_add, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'You haven\'t requested any tutors yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => context.push('/hire-tutor'),
                        child: const Text('Tap here to post your first requirement'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length > 3 ? 3 : requests.length,
                itemBuilder: (context, index) {
                  final job = requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      title: Text(job.subjects.join(', ')),
                      subtitle: Text('Status: ${job.status.toUpperCase()}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/request-details', extra: job),
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tutor Directory', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.push('/find-tutors'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Browse our directory of qualified tutors available for home and online tuition.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
