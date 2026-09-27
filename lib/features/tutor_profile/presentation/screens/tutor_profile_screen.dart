import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
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
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullName);
    _emailController = TextEditingController(text: widget.user?.email);
    _phoneController = TextEditingController(text: widget.user?.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          AppTextField(label: 'Email', controller: _emailController),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Phone Number', controller: _phoneController),
          const SizedBox(height: AppSpacing.md),
          AppDropdown(
            label: 'City',
            value: null,
            items: const ['Kathmandu', 'Lalitpur', 'Bhaktapur'],
            onChanged: (v) {},
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(text: 'Save Personal Info', onPressed: () {}),
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

  @override
  void dispose() {
    _institutionController.dispose();
    _experienceController.dispose();
    super.dispose();
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
            value: null,
            items: const ['Bachelors', 'Masters', 'PhD', '+2/High School'],
            onChanged: (v) {},
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Current Institution / University', controller: _institutionController),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Years of Experience', keyboardType: TextInputType.number, controller: _experienceController),
          
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subjects I Teach', style: theme.textTheme.titleMedium),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add subject dialog')));
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const Center(child: Text('No subjects added')),
          const SizedBox(height: AppSpacing.xl),
          AppButton(text: 'Save Education & Experience', onPressed: () {}),
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

  @override
  void dispose() {
    _monthlyFeeController.dispose();
    _hourlyFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          
          const SizedBox(height: AppSpacing.xl),
          Text('Identity Verification', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          
          AppButton(
            text: 'Upload Citizenship / ID',
            isSecondary: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker opening...')));
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            text: 'Upload Latest Transcript',
            isSecondary: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker opening...')));
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(text: 'Submit for Verification', onPressed: () {}),
        ],
      ),
    );
  }
}
