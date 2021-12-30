import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../shared/widgets/dynamic_subject_selector.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';

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
  final _institutionController = TextEditingController();
  final _experienceController = TextEditingController();

  final Set<String> _selectedLevels = {};
  List<String> _selectedSubjects = [];
  LocationSelection _location = const LocationSelection(province: '', district: '', area: '');
  String? _selectedQualification;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = AuthProviderInherited.of(context).user;
      if (user != null) {
        if (user.headline?.isNotEmpty == true) _headlineController.text = user.headline!;
        if (user.bio?.isNotEmpty == true) _bioController.text = user.bio!;
        if (user.expectedMonthlyRate != null && user.expectedMonthlyRate! > 0) {
          _rateController.text = user.expectedMonthlyRate.toString();
        }
        if (user.institution?.isNotEmpty == true) _institutionController.text = user.institution!;
        if (user.experienceYears != null) _experienceController.text = user.experienceYears.toString();
        
        setState(() {
          if (user.teachingLevels.isNotEmpty) _selectedLevels.addAll(user.teachingLevels);
          if (user.subjects.isNotEmpty) _selectedSubjects = List.from(user.subjects);
          _selectedQualification = user.highestQualification;
          if (user.district?.isNotEmpty == true) {
            _location = LocationSelection(
              province: user.province ?? '',
              district: user.district!,
              area: user.area ?? '',
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _bioController.dispose();
    _rateController.dispose();
    _institutionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one teaching level.')));
      return;
    }
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one subject.')));
      return;
    }

    final int? rate = int.tryParse(_rateController.text.trim());
    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid monthly rate.')));
      return;
    }

    final authProvider = AuthProviderInherited.of(context);

    await authProvider.updateTutorProfile(
      headline: _headlineController.text.trim(),
      bio: _bioController.text.trim(),
      teachingLevels: _selectedLevels.toList(),
      subjects: _selectedSubjects,
      province: _location.province,
      district: _location.district,
      area: _location.area,
      expectedMonthlyRate: rate,
      highestQualification: _selectedQualification,
      institution: _institutionController.text.trim(),
      experienceYears: int.tryParse(_experienceController.text.trim()),
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
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Bio',
                  hint: 'Tell students about your teaching style',
                  controller: _bioController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                Text('Step 2: Education & Experience', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                AppDropdown(
                  label: 'Highest Qualification',
                  value: _selectedQualification,
                  items: const ['Bachelors', 'Masters', 'PhD', '+2/High School'],
                  onChanged: (v) => setState(() => _selectedQualification = v),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Institution / University',
                  hint: 'e.g., Tribhuvan University',
                  controller: _institutionController,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Years of Experience',
                  hint: 'e.g., 3',
                  keyboardType: TextInputType.number,
                  controller: _experienceController,
                ),

                const SizedBox(height: AppSpacing.xl),
                Text('Step 3: Subjects & Target Levels', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                DynamicSubjectSelector(
                  selectedSubjects: _selectedSubjects,
                  multiSelect: true,
                  onChanged: (subjects) => setState(() => _selectedSubjects = subjects),
                ),
                const SizedBox(height: AppSpacing.md),
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
                Text('Step 4: Preferred Teaching Location', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                DynamicLocationSelector(
                  value: _location,
                  onChanged: (v) => setState(() => _location = v),
                ),

                const SizedBox(height: AppSpacing.xl),
                Text('Step 5: Compensation', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Expected Monthly Rate (NPR)',
                  hint: 'e.g., 10000',
                  keyboardType: TextInputType.number,
                  controller: _rateController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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
            ],
          ),
        ),
      ),
    ),
  );
}
}
