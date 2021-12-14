import 'package:flutter/material.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';

class AppBottomSheetSelect extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const AppBottomSheetSelect({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Select $label',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = value == option;
                      return ListTile(
                        title: Text(option),
                        trailing: isSelected
                            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () {
                          onChanged(option);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showPicker(context),
          borderRadius: AppRadii.borderRadiusMedium,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              border: Border.all(
                color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? 
                       theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: AppRadii.borderRadiusMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: value == null 
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.5) 
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down, 
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
