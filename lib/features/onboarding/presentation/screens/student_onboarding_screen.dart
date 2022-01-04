import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class StudentOnboardingScreen extends StatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  State<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends State<StudentOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userType = 'student';
  final _gradeController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _locationController = TextEditingController();
  
  void _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    final authProvider = AuthProviderInherited.of(context);
    
    final locText = _locationController.text.trim();
    String district = locText;
    String area = locText;
    if (locText.contains(',')) {
      final parts = locText.split(',');
      district = parts[0].trim();
      area = parts.length > 1 ? parts[1].trim() : district;
    }

    final subjects = _subjectsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
        
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter at least one subject.')));
      return;
    }

    await authProvider.updateStudentProfile(
      studentType: _userType,
      studentGradeLevel: _gradeController.text.trim(),
      subjects: subjects,
      district: district,
      area: area,
    );

    if (mounted && authProvider.errorMessage == null) {
      await authProvider.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProviderInherited.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tell Us What You Need')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'We\'ll help match you with the best tutors in your area',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Text('Are you a student or a parent?', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'student', label: Text('Student')),
                  ButtonSegment(value: 'parent', label: Text('Parent/Guardian')),
                ],
                selected: {_userType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _userType = newSelection.first);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Grade / Level',
                hint: 'e.g., Grade 10, +2 Science, Bachelor',
                controller: _gradeController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              
              AppTextField(
                label: 'Subjects Needed',
                hint: 'e.g., Math, Science, English',
                controller: _subjectsController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                label: 'Location (City / Area)',
                hint: 'e.g., Kathmandu, Baneshwor',
                controller: _locationController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Save & Discover Tutors',
                  isLoading: authProvider.isLoading,
                  onPressed: _saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
