import 'package:flutter/material.dart';

class AppRadioGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const AppRadioGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: options.map((option) {
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(option),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A simple custom radio visualization to avoid deprecated APIs quickly
                    // or we can use Radio without groupValue by just manually rendering it.
                    // A quick workaround to the new RadioGroup API without overcomplicating:
                    Icon(
                      option == selectedValue ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: option == selectedValue ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
