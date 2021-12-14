import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class InstituteOnboardingScreen extends StatefulWidget {
  const InstituteOnboardingScreen({super.key});

  @override
  State<InstituteOnboardingScreen> createState() => _InstituteOnboardingScreenState();
}

class _InstituteOnboardingScreenState extends State<InstituteOnboardingScreen> {
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _addressController = TextEditingController();
  
  void _saveProfile() async {
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProviderInherited.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Institute Registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register your educational organization on TutorMate',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              AppTextField(
                label: 'Institute Name',
                hint: 'Enter official institute name',
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Registration / PAN Number',
                hint: 'Government registration ID',
                controller: _regNoController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Office Address',
                hint: 'City, Area, Landmark',
                controller: _addressController,
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Register Institute',
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
