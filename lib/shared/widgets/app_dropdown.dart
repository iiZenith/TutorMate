import 'package:flutter/material.dart';

class AppDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hint;
  final bool isRequired;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          hint: hint != null ? Text(hint!) : null,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (v) => v == null || v.isEmpty ? 'Required field' : null
              : null,
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ],
    );
  }
}
