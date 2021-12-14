import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/mocks/mock_jobs.dart';
import '../../domain/models/job_request.dart';

class JobBoardScreen extends StatelessWidget {
  const JobBoardScreen({super.key});

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Filter Jobs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Tuition Type', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8.0,
                  children: [
                    ChoiceChip(label: const Text('Home Tuition'), selected: true, onSelected: (_) {}),
                    ChoiceChip(label: const Text('Online'), selected: false, onSelected: (_) {}),
                    ChoiceChip(label: const Text('Both'), selected: false, onSelected: (_) {}),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Location', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(hintText: 'Select City'),
                  items: ['Kathmandu', 'Lalitpur', 'Bhaktapur'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Subject Category', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8.0,
                  children: [
                    ChoiceChip(label: const Text('School'), selected: true, onSelected: (_) {}),
                    ChoiceChip(label: const Text('University'), selected: false, onSelected: (_) {}),
                    ChoiceChip(label: const Text('Languages'), selected: false, onSelected: (_) {}),
                    ChoiceChip(label: const Text('Test Prep'), selected: false, onSelected: (_) {}),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Apply Filters',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  hintText: 'Search subjects or locations',
                  leading: const Icon(Icons.search),
                  elevation: WidgetStateProperty.all(2),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: AppSpacing.md)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filledTonal(
                icon: const Icon(Icons.tune),
                onPressed: () => _showFilterBottomSheet(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: mockJobs.length,
            itemBuilder: (context, index) {
              return _JobRequestCard(job: mockJobs[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _JobRequestCard extends StatelessWidget {
  final JobRequest job;

  const _JobRequestCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.subject,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (job.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NEW',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(icon: Icons.location_on_outlined, text: '${job.city} - ${job.location}'),
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(icon: Icons.person_outline, text: '${job.preferredGender} Student • ${job.gradeLevel}'),
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(icon: Icons.account_balance_wallet_outlined, text: job.feeRange),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job.timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application opened (Mock)')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Apply Now'),
                ),
              ],
            ),
          ],
        ),
      ),
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
