import 'package:flutter/material.dart';
import '../services/subject_service.dart';

class DynamicSubjectSelector extends StatefulWidget {
  final List<String> selectedSubjects;
  final bool multiSelect;
  final ValueChanged<List<String>> onChanged;

  const DynamicSubjectSelector({
    super.key,
    required this.selectedSubjects,
    this.multiSelect = true,
    required this.onChanged,
  });

  @override
  State<DynamicSubjectSelector> createState() => _DynamicSubjectSelectorState();
}

class _DynamicSubjectSelectorState extends State<DynamicSubjectSelector> {
  final SubjectService _service = SubjectService();
  bool _isLoading = true;
  String? _error;
  List<String> _availableSubjects = [];
  late List<String> _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = List.from(widget.selectedSubjects);
    _loadSubjects();
  }

  @override
  void didUpdateWidget(covariant DynamicSubjectSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSubjects != widget.selectedSubjects) {
      setState(() {
        _currentSelection = List.from(widget.selectedSubjects);
      });
    }
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final subjects = await _service.getSubjects();
      if (mounted) {
        setState(() {
          _availableSubjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Failed to load subjects.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            TextButton.icon(
              onPressed: _loadSubjects,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_availableSubjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No subjects available.'),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _availableSubjects.map((subject) {
        final isSelected = _currentSelection.contains(subject);
        return FilterChip(
          label: Text(subject),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (!widget.multiSelect) _currentSelection.clear();
                _currentSelection.add(subject);
              } else {
                _currentSelection.remove(subject);
              }
            });
            widget.onChanged(_currentSelection);
          },
        );
      }).toList(),
    );
  }
}
