import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/auth/domain/models/app_user.dart';
import '../../../../shared/services/storage/storage_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';
import '../../../../shared/widgets/dynamic_subject_selector.dart';
import '../../domain/tutor_profile_validation.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    final user = authProvider.user;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Personal'),
              Tab(text: 'Education'),
              Tab(text: 'Pricing'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PersonalTab(user: user),
                const _EducationTab(),
                const _PricingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalTab extends StatefulWidget {
  final AppUser? user;

  const _PersonalTab({required this.user});

  @override
  State<_PersonalTab> createState() => _PersonalTabState();
}

class _PersonalTabState extends State<_PersonalTab> {
  static const _teachingLevels = [
    'Primary',
    'Middle School',
    'Secondary (SEE)',
    '+2',
    'Bachelor',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedLevels = <String>{};
  LocationSelection _location =
      const LocationSelection(province: '', district: '', area: '');
  bool _hydrating = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _headlineController = TextEditingController();
    _bioController = TextEditingController();
    _nameController.addListener(_markDirty);
    _phoneController.addListener(_markDirty);
    _headlineController.addListener(_markDirty);
    _bioController.addListener(_markDirty);
    _hydrate(widget.user);
  }

  @override
  void didUpdateWidget(covariant _PersonalTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user?.id != oldWidget.user?.id || !_dirty) {
      _hydrate(widget.user);
    }
  }

  void _markDirty() {
    if (!_hydrating) _dirty = true;
  }

  void _hydrate(AppUser? user) {
    if (user == null) return;
    _hydrating = true;
    _nameController.text = user.fullName;
    _phoneController.text = user.phoneNumber ?? '';
    _headlineController.text = user.headline ?? '';
    _bioController.text = user.bio ?? '';
    _location = LocationSelection(
      province: user.province ?? '',
      district: user.district ?? '',
      area: user.area ?? '',
    );
    _selectedLevels
      ..clear()
      ..addAll(user.teachingLevels);
    _hydrating = false;
    _dirty = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _savePersonal() async {
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      province: _location.province,
      district: _location.district,
      area: _location.area,
    );
    if (!mounted) return;
    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }
    final saved = authProvider.user;
    if (saved?.fullName != _nameController.text.trim() ||
        saved?.phoneNumber != _phoneController.text.trim() ||
        saved?.province != _location.province ||
        saved?.district != _location.district ||
        saved?.area != _location.area) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal info could not be confirmed as saved.')),
      );
      return;
    }
    _dirty = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal info saved successfully.')),
    );
  }

  Future<void> _saveProfessionalDetails() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final levels = _selectedLevels.toList(growable: false);
    final levelError = TutorProfileValidation.validateTeachingLevels(levels);
    if (levelError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(levelError)));
      return;
    }

    final headline = _headlineController.text.trim();
    final bio = _bioController.text.trim();
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(
      headline: headline,
      bio: bio,
      teachingLevels: levels,
    );
    if (!mounted) return;
    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }

    var saved = authProvider.user;
    if (saved?.headline != headline ||
        saved?.bio != bio ||
        !_sameSet(saved?.teachingLevels, levels)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Professional details could not be confirmed as saved.')),
      );
      return;
    }

    if (saved?.isProfileComplete == true && saved?.isValidTutorProfile == false) {
      await authProvider.updateTutorProfile(isProfileComplete: false);
      if (!mounted) return;
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
        return;
      }
      saved = authProvider.user;
    }

    if (saved?.headline != headline ||
        saved?.bio != bio ||
        !_sameSet(saved?.teachingLevels, levels)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved data could not be confirmed after refresh.')),
      );
      return;
    }

    _dirty = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Professional details saved successfully.')),
    );
  }

  bool _sameSet(List<String>? first, List<String> second) {
    if (first == null || first.length != second.length) return false;
    final a = first.toSet();
    final b = second.toSet();
    return a.length == b.length && a.containsAll(b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(label: 'Full Name', controller: _nameController),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email (Read Only)',
            controller: TextEditingController(text: widget.user?.email),
            readOnly: true,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Phone Number', controller: _phoneController),
          const SizedBox(height: AppSpacing.md),
          DynamicLocationSelector(
            value: _location,
            onChanged: (value) {
              setState(() {
                _location = value;
                _dirty = true;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: 'Save Personal Info',
            isLoading: authProvider.isLoading,
            onPressed: _savePersonal,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Professional Details',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'These details are shown to students when they discover your tutor profile.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Headline',
                  hint: 'e.g., M.Sc. Physics Tutor with 5+ Years Exp',
                  controller: _headlineController,
                  validator: TutorProfileValidation.validateHeadline,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Bio',
                  hint: 'Tell students about your teaching style',
                  controller: _bioController,
                  validator: TutorProfileValidation.validateBio,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Teaching Levels', style: theme.textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                FormField<List<String>>(
                  validator: (_) => TutorProfileValidation.validateTeachingLevels(
                    _selectedLevels.toList(),
                  ),
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final level in _teachingLevels)
                            FilterChip(
                              label: Text(level),
                              selected: _selectedLevels.contains(level),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedLevels.add(level);
                                  } else {
                                    _selectedLevels.remove(level);
                                  }
                                  _dirty = true;
                                });
                                field.validate();
                              },
                            ),
                        ],
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Save Professional Details',
                  isLoading: authProvider.isLoading,
                  onPressed: _saveProfessionalDetails,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationTab extends StatefulWidget {
  const _EducationTab();

  @override
  State<_EducationTab> createState() => _EducationTabState();
}

class _EducationTabState extends State<_EducationTab> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _selectedQualification;
  List<String> _selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = AuthProviderInherited.of(context).user;
      if (user == null) return;
      setState(() {
        _institutionController.text = user.institution ?? '';
        _experienceController.text = user.experienceYears?.toString() ?? '';
        _selectedQualification = user.highestQualification;
        _selectedSubjects = List<String>.from(user.subjects);
      });
    });
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveEducation() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final experience = TutorProfileValidation.parseExperience(_experienceController.text);
    if (experience == null) return;
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(
      highestQualification: _selectedQualification,
      institution: _institutionController.text.trim(),
      experienceYears: experience,
      subjects: _selectedSubjects,
    );
    if (!mounted) return;
    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }
    if (authProvider.user?.experienceYears != experience) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Education & Experience could not be confirmed as saved.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Education & Experience saved successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdown(
              label: 'Highest Qualification',
              value: _selectedQualification,
              items: const ['Bachelors', 'Masters', 'PhD', '+2/High School'],
              onChanged: (value) => setState(() => _selectedQualification = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Current Institution / University',
              controller: _institutionController,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Years of Experience',
              keyboardType: TextInputType.number,
              controller: _experienceController,
              validator: TutorProfileValidation.validateExperience,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Subjects I Teach', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            DynamicSubjectSelector(
              selectedSubjects: _selectedSubjects,
              multiSelect: true,
              onChanged: (subjects) => setState(() => _selectedSubjects = subjects),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: 'Save Education & Experience',
              isLoading: authProvider.isLoading,
              onPressed: _saveEducation,
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingTab extends StatefulWidget {
  const _PricingTab();

  @override
  State<_PricingTab> createState() => _PricingTabState();
}

class _PricingTabState extends State<_PricingTab> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyFeeController = TextEditingController();
  final _hourlyFeeController = TextEditingController();
  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = AuthProviderInherited.of(context).user;
      if (user == null) return;
      setState(() {
        _monthlyFeeController.text = user.expectedMonthlyRate?.toString() ?? '';
        _hourlyFeeController.text = user.expectedHourlyRate?.toString() ?? '';
      });
    });
  }

  @override
  void dispose() {
    _monthlyFeeController.dispose();
    _hourlyFeeController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload(String docType) async {
    final user = AuthProviderInherited.of(context).user;
    if (user == null) return;
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null || result.path == null || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final url = await _storageService.uploadTutorDocument(
        uid: user.id,
        documentType: docType,
        file: File(result.path!),
      );
      if (url == null) throw Exception('Upload returned no URL.');
      final authProvider = AuthProviderInherited.of(context);
      if (docType == 'citizenship') {
        await authProvider.updateTutorProfile(citizenshipUrl: url);
      } else {
        await authProvider.updateTutorProfile(transcriptUrl: url);
      }
      if (!mounted) return;
      if (authProvider.errorMessage != null) {
        throw Exception(authProvider.errorMessage!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$docType uploaded successfully!')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _savePricing() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final monthly = TutorProfileValidation.parseRate(
      _monthlyFeeController.text,
      label: 'Monthly fee',
    );
    final hourly = TutorProfileValidation.parseRate(
      _hourlyFeeController.text,
      label: 'Hourly fee',
    );
    if (monthly == null || hourly == null) return;

    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(
      expectedMonthlyRate: monthly,
      expectedHourlyRate: hourly,
    );
    if (!mounted) return;
    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }
    if (authProvider.user?.expectedMonthlyRate != monthly ||
        authProvider.user?.expectedHourlyRate != hourly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pricing could not be confirmed as saved.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pricing saved successfully.')),
    );
  }

  Future<void> _submitVerification() async {
    final user = AuthProviderInherited.of(context).user;
    if (user == null) return;
    if (user.citizenshipUrl == null || user.transcriptUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents first.')),
      );
      return;
    }
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(verificationStatus: 'pending');
    if (!mounted) return;
    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }
    if (authProvider.user?.verificationStatus != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification status could not be confirmed.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification submitted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    final user = authProvider.user;
    final status = user?.verificationStatus ?? 'notSubmitted';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pricing', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Expected Minimum Monthly Fee (Rs.)',
              keyboardType: TextInputType.number,
              controller: _monthlyFeeController,
              validator: (value) => TutorProfileValidation.validateRate(value, label: 'Monthly fee'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Expected Minimum Hourly Fee (Rs.)',
              keyboardType: TextInputType.number,
              controller: _hourlyFeeController,
              validator: (value) => TutorProfileValidation.validateRate(value, label: 'Hourly fee'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Save Pricing',
              isLoading: authProvider.isLoading,
              onPressed: _savePricing,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Identity Verification', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Text('Status: ${status.toUpperCase()}', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (_isUploading) const Center(child: CircularProgressIndicator()),
            if (!_isUploading && status != 'approved' && status != 'pending') ...[
              AppButton(
                text: user?.citizenshipUrl != null ? 'Citizenship Uploaded (Tap to Replace)' : 'Upload Citizenship / ID',
                isSecondary: true,
                onPressed: () => _handleUpload('citizenship'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: user?.transcriptUrl != null ? 'Transcript Uploaded (Tap to Replace)' : 'Upload Latest Transcript',
                isSecondary: true,
                onPressed: () => _handleUpload('transcript'),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(text: 'Submit for Verification', onPressed: _submitVerification),
            ],
          ],
        ),
      ),
    );
  }
}
