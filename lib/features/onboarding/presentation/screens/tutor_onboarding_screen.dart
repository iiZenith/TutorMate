import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class TutorOnboardingScreen extends StatefulWidget {
  const TutorOnboardingScreen({super.key});

  @override
  State<TutorOnboardingScreen> createState() => _TutorOnboardingScreenState();
}

class _TutorOnboardingScreenState extends State<TutorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _rateController = TextEditingController();
  
  final Set<String> _selectedLevels = {};
  
  void _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one teaching level')));
      return;
    }

    final authProvider = AuthProviderInherited.of(context);
    
    final int? rate = int.tryParse(_rateController.text.trim());
    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid monthly rate')));
      return;
    }

    await authProvider.updateTutorProfile(
      headline: _headlineController.text.trim(),
      bio: _bioController.text.trim(),
      teachingLevels: _selectedLevels.toList(),
      expectedMonthlyRate: rate,
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
      appBar: AppBar(title: const Text('Set Up Your Tutor Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'Help students and parents understand your teaching expertise',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Text('Step 1: Professional Details', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Headline',
                hint: 'e.g., M.Sc. Physics Tutor with 5+ Years Exp',
                controller: _headlineController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Bio',
                hint: 'Tell students about your teaching style',
                controller: _bioController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              Text('Step 2: Target Levels', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8.0,
                children: ['Primary', 'Middle School', 'Secondary (SEE)', '+2', 'Bachelor']
                    .map((level) => FilterChip(
                          label: Text(level),
                          selected: _selectedLevels.contains(level),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedLevels.add(level);
                              } else {
                                _selectedLevels.remove(level);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),

              const SizedBox(height: AppSpacing.xl),
              Text('Step 3: Compensation', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Expected Monthly Rate (NPR)',
                hint: 'e.g., 10000',
                keyboardType: TextInputType.number,
                controller: _rateController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Complete Profile & Start Tutoring',
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
