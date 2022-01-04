import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/services/storage/storage_service.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/dynamic_subject_selector.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../shared/widgets/app_button.dart';

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
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
  final dynamic user;
  const _PersonalTab({required this.user});

  @override
  State<_PersonalTab> createState() => _PersonalTabState();
}

class _PersonalTabState extends State<_PersonalTab> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  LocationSelection _location = const LocationSelection(province: '', district: '', area: '');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullName);
    _phoneController = TextEditingController(text: widget.user?.phoneNumber);
    if (widget.user != null) {
      _location = LocationSelection(
        province: widget.user!.province ?? '',
        district: widget.user!.district ?? '',
        area: widget.user!.area ?? '',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _savePersonal() async {
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      province: _location.province,
      district: _location.district,
      area: _location.area,
    );
    if (mounted) {
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personal info saved successfully.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, size: 16, color: theme.colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(label: 'Full Name', controller: _nameController),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Email (Read Only)', controller: TextEditingController(text: widget.user?.email), readOnly: true),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Phone Number', controller: _phoneController),
          const SizedBox(height: AppSpacing.md),
          DynamicLocationSelector(
            value: _location,
            onChanged: (v) => setState(() => _location = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(text: 'Save Personal Info', onPressed: _savePersonal),
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
  final _institutionController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _selectedQualification;
  List<String> _selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = AuthProviderInherited.of(context).user;
      if (user != null) {
        if (user.institution != null) _institutionController.text = user.institution!;
        if (user.experienceYears != null) _experienceController.text = user.experienceYears.toString();
        setState(() {
          _selectedQualification = user.highestQualification;
          _selectedSubjects = List.from(user.subjects);
        });
      }
    });
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _saveEducation() async {
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(
      highestQualification: _selectedQualification,
      institution: _institutionController.text.trim(),
      experienceYears: int.tryParse(_experienceController.text.trim()),
      subjects: _selectedSubjects,
    );
    if (mounted) {
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Education & Experience saved successfully.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropdown(
            label: 'Highest Qualification',
            value: _selectedQualification,
            items: const ['Bachelors', 'Masters', 'PhD', '+2/High School'],
            onChanged: (v) => setState(() => _selectedQualification = v),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Current Institution / University', controller: _institutionController),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Years of Experience', keyboardType: TextInputType.number, controller: _experienceController),

          const SizedBox(height: AppSpacing.xl),
          Text('Subjects I Teach', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          DynamicSubjectSelector(
            selectedSubjects: _selectedSubjects,
            multiSelect: true,
            onChanged: (subjects) {
              setState(() {
                _selectedSubjects = subjects;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(text: 'Save Education & Experience', onPressed: _saveEducation),
        ],
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
  final _monthlyFeeController = TextEditingController();
  final _hourlyFeeController = TextEditingController();
  final StorageService _storageService = StorageService();

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = AuthProviderInherited.of(context).user;
      if (user != null) {
        if (user.expectedMonthlyRate != null) {
          _monthlyFeeController.text = user.expectedMonthlyRate.toString();
        }
        if (user.expectedHourlyRate != null) {
          _hourlyFeeController.text = user.expectedHourlyRate.toString();
        }
      }
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

    PlatformFile? result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.path != null) {
      setState(() => _isUploading = true);
      try {
        final file = File(result.path!);
        final url = await _storageService.uploadTutorDocument(
          uid: user.id,
          documentType: docType,
          file: file,
        );

        if (url != null && mounted) {
          final authProvider = AuthProviderInherited.of(context);
          if (docType == 'citizenship') {
            await authProvider.updateTutorProfile(citizenshipUrl: url);
          } else {
            await authProvider.updateTutorProfile(transcriptUrl: url);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$docType uploaded successfully!')));
          }
        } else {
          throw Exception('Upload returned null URL.');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  void _savePricing() async {
    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(
      expectedMonthlyRate: int.tryParse(_monthlyFeeController.text.trim()),
      expectedHourlyRate: int.tryParse(_hourlyFeeController.text.trim()),
    );
    if (mounted) {
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pricing saved successfully.')));
      }
    }
  }

  void _submitVerification() async {
    final user = AuthProviderInherited.of(context).user;
    if (user == null) return;
    
    if (user.citizenshipUrl == null || user.transcriptUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload all required documents first.')));
      return;
    }

    final authProvider = AuthProviderInherited.of(context);
    await authProvider.updateTutorProfile(verificationStatus: 'pending');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification submitted!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthProviderInherited.of(context).user;
    final status = user?.verificationStatus ?? 'notSubmitted';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pricing', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Expected Minimum Monthly Fee (Rs.)',
            keyboardType: TextInputType.number,
            controller: _monthlyFeeController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Expected Minimum Hourly Fee (Rs.)',
            keyboardType: TextInputType.number,
            controller: _hourlyFeeController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(text: 'Save Pricing', onPressed: _savePricing),
          
          const SizedBox(height: AppSpacing.xl),
          Text('Identity Verification', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: status == 'approved' ? Colors.green.withValues(alpha: 0.1) : 
                     status == 'pending' ? Colors.orange.withValues(alpha: 0.1) :
                     status == 'rejected' ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerTheme.color ?? theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  status == 'approved' ? Icons.check_circle :
                  status == 'pending' ? Icons.hourglass_empty :
                  status == 'rejected' ? Icons.cancel : Icons.info_outline,
                  color: status == 'approved' ? Colors.green :
                         status == 'pending' ? Colors.orange :
                         status == 'rejected' ? Colors.red : theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Status: ${status.toUpperCase()}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
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
    );
  }
}
