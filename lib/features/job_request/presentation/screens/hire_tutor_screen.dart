import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';
import '../../domain/models/job_request_model.dart';
import '../../data/repositories/firebase_job_repository_impl.dart';

class HireTutorScreen extends StatefulWidget {
  const HireTutorScreen({super.key});

  @override
  State<HireTutorScreen> createState() => _HireTutorScreenState();
}

class _HireTutorScreenState extends State<HireTutorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobRepository = FirebaseJobRepositoryImpl();
  final _budgetController = TextEditingController();

  LocationSelection _location = const LocationSelection(province: '', district: '', area: '');
  String? _selectedGrade;
  
  final List<String> _selectedSubjects = [];

  final List<String> _availableSubjects = [
    'Social',
    'Nepali',
    'English',
    'Math',
    'Science',
    'Health',
  ];

  bool _isLoading = false;

  void _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one subject.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = AuthProviderInherited.of(context).user;
      if (user == null) throw Exception("User not logged in");

      final newJob = JobRequestModel(
        jobId: '', // Handled dynamically in repo
        studentId: user.id,
        studentName: user.fullName,
        district: _location.district,
        area: _location.area,
        grade: _selectedGrade ?? '',
        subjects: _selectedSubjects,
        budgetNpr: int.tryParse(_budgetController.text) ?? 0,
        createdAt: DateTime.now(), // Handled gracefully by firestore serverTimestamp
      );

      await _jobRepository.createJobRequest(newJob);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor requirement posted successfully!')));
        context.pop(); // Go back to dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Hire a Tutor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Post your requirement',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Fill in the details below to find the perfect tutor match.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 1. Dynamic Location Selector
                DynamicLocationSelector(
                  value: _location,
                  onChanged: (v) => setState(() => _location = v),
                ),
                if (_location.district.isEmpty || _location.area.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16),
                    child: Text('Location is required', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                  ),
                const SizedBox(height: AppSpacing.md),

                // 3. Grade
                AppDropdown(
                  label: 'Grade / Class',
                  hint: 'Select Grade',
                  value: _selectedGrade,
                  items: List.generate(10, (index) => 'Grade ${index + 1}'),
                  onChanged: (v) => setState(() => _selectedGrade = v),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Subjects (Chips)
                Text('Subjects Required', style: theme.textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _availableSubjects.map((subject) {
                    final isSelected = _selectedSubjects.contains(subject);
                    return FilterChip(
                      label: Text(subject),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSubjects.add(subject);
                          } else {
                            _selectedSubjects.remove(subject);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 5. Budget
                AppTextField(
                  label: 'Approximate Monthly Budget (Rs.)',
                  hint: 'e.g., 5000',
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Budget is required';
                    if (int.tryParse(v) == null) return 'Must be a valid number';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  text: 'Post Request',
                  isLoading: _isLoading,
                  onPressed: _submitRequest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
