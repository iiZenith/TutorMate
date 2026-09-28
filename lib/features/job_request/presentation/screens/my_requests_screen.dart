import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../app/app.dart';
import '../../domain/models/job_request_model.dart';
import '../../data/repositories/firebase_job_repository_impl.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _repository = FirebaseJobRepositoryImpl();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthProviderInherited.of(context).user;

    if (user == null) {
      return const Center(child: Text('Authentication required'));
    }

    return StreamBuilder<List<JobRequestModel>>(
      stream: _repository.getMyRequestsStream(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Error loading your requests.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_add, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'You haven\'t posted any requests yet.',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: requests.length,
            itemBuilder: (context, index) {
            final job = requests[index];
            return Card(
              elevation: 4,
              shadowColor: theme.shadowColor.withValues(alpha: 0.1),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadii.large))),
              child: InkWell(
                onTap: () {
                  context.push('/request-details', extra: job);
                },
                borderRadius: const BorderRadius.all(Radius.circular(AppRadii.large)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.subjects.isNotEmpty ? job.subjects.join(', ') : 'General Subjects',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: job.status == 'open'
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            job.status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: job.status == 'open'
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InfoRow(icon: Icons.school_outlined, text: job.grade),
                    const SizedBox(height: AppSpacing.xs),
                    _InfoRow(icon: Icons.location_on_outlined, text: '${job.district} - ${job.area}'),
                    const SizedBox(height: AppSpacing.xs),
                    _InfoRow(icon: Icons.account_balance_wallet_outlined, text: 'Rs. ${job.budgetNpr} / month'),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
