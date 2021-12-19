import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              (user?.fullName ?? 'S')[0].toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary, 
                fontSize: 40, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user?.fullName.isNotEmpty == true ? user!.fullName : 'Not Provided',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email.isNotEmpty == true ? user!.email : 'Not Provided',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Profile Status: ${user?.isProfileComplete == true ? 'Complete' : 'Incomplete'}', 
            style: theme.textTheme.bodySmall?.copyWith(
              color: user?.isProfileComplete == true ? theme.colorScheme.primary : theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            )
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _SectionHeader(title: 'Personal Information'),
          _ProfileRow(label: 'Full Name', value: user?.fullName.isNotEmpty == true ? user!.fullName : 'Not provided'),
          _ProfileRow(label: 'Email', value: user?.email.isNotEmpty == true ? user!.email : 'Not provided'),
          _ProfileRow(label: 'Phone Number', value: user?.phoneNumber?.isNotEmpty == true ? user!.phoneNumber! : 'Not provided'),
          _ProfileRow(label: 'Gender', value: user?.gender?.isNotEmpty == true ? user!.gender! : 'Not provided'),
          _ProfileRow(label: 'City', value: user?.district?.isNotEmpty == true ? user!.district! : 'Not provided'),
          _ProfileRow(label: 'Location / Area', value: user?.area?.isNotEmpty == true ? user!.area! : 'Not provided'),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label, 
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
              )
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value, 
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
            ),
          ),
        ],
      ),
    );
  }
}
