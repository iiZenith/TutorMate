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
  String _userType = 'student';
  final _gradeController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _locationController = TextEditingController();
  
  void _saveProfile() async {
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.completeOnboarding();
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
              ),
              const SizedBox(height: AppSpacing.md),
              
              AppTextField(
                label: 'Subjects Needed',
                hint: 'e.g., Math, Science, English',
                controller: _subjectsController,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                label: 'Location (City / Area)',
                hint: 'e.g., Kathmandu, Baneshwor',
                controller: _locationController,
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
    );
  }
}
