import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/app_button.dart';

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
    final theme = Theme.of(context);

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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No tuition jobs posted yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Job Board'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
