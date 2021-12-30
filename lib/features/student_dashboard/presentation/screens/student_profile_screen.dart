import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_radio_group.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';
import '../../../../shared/services/storage/storage_service.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  
  String _selectedGender = 'Other';
  LocationSelection _location = const LocationSelection(province: '', district: '', area: '');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = AuthProviderInherited.of(context).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _selectedGender = (user?.gender?.isNotEmpty == true) ? user!.gender! : 'Other';
    if (user != null) {
      _location = LocationSelection(
        province: user.province ?? '',
        district: user.district ?? '',
        area: user.area ?? '',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleAvatarUpload() async {
    final user = AuthProviderInherited.of(context).user;
    if (user == null) return;

    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _isSaving = true);
      try {
        final file = File(result.files.single.path!);
        final url = await StorageService().uploadAvatar(
          uid: user.id,
          file: file,
        );
        if (url != null && mounted) {
          await AuthProviderInherited.of(context).updateStudentProfile(
            avatarUrl: url,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avatar updated successfully!')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload avatar: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  void _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isSaving = true);
    final authProvider = AuthProviderInherited.of(context);

    try {
      await authProvider.updateStudentProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        province: _location.province,
        district: _location.district,
        area: _location.area,
      );

      if (mounted) {
        if (authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage!)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                        ? Text(
                            (user?.fullName.isNotEmpty == true ? user!.fullName : 'S')[0].toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.primary, 
                              fontSize: 36, 
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _handleAvatarUpload,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, size: 18, color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              user?.email ?? 'Not Provided',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user?.isProfileComplete == true 
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Profile Status: ${user?.isProfileComplete == true ? 'Complete' : 'Incomplete'}', 
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: user?.isProfileComplete == true ? theme.colorScheme.primary : theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              'Edit Personal Details',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Full Name',
              controller: _nameController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            AppRadioGroup(
              label: 'Gender',
              options: const ['Male', 'Female', 'Other'],
              selectedValue: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
            const SizedBox(height: AppSpacing.md),

            DynamicLocationSelector(
              value: _location,
              onChanged: (v) => setState(() => _location = v),
            ),
            const SizedBox(height: AppSpacing.xl),

            AppButton(
              text: 'Save Changes',
              isLoading: _isSaving,
              onPressed: _saveProfile,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
