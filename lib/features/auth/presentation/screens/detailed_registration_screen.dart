import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/auth_floating_card_layout.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';
import '../../../../shared/widgets/app_radio_group.dart';
import '../../../../app/app.dart';
import '../../domain/models/user_role.dart';

class DetailedRegistrationScreen extends StatefulWidget {
  final String role;
  final String initialEmail;
  
  const DetailedRegistrationScreen({
    super.key, 
    required this.role, 
    required this.initialEmail,
  });

  @override
  State<DetailedRegistrationScreen> createState() => _DetailedRegistrationScreenState();
}

class _DetailedRegistrationScreenState extends State<DetailedRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late TextEditingController _emailController;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  LocationSelection _location = const LocationSelection(province: '', district: '', area: '');
  String _selectedGender = 'Other';
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the Terms of Use and Privacy Policy'))
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'))
      );
      return;
    }

    final parsedRole = UserRole.fromString(widget.role);
    if (parsedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid role selected'))
      );
      return;
    }

    final authProvider = AuthProviderInherited.of(context);
    await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      parsedRole,
      phoneNumber: _phoneController.text.trim(),
      gender: _selectedGender,
      province: _location.province,
      district: _location.district,
      area: _location.area,
    );

    if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProviderInherited.of(context);
    final theme = Theme.of(context);

    return AuthFloatingCardLayout(
      title: 'Create Account',
      subtitle: 'Register as a ${widget.role}',
      headerIcon: Icons.person_add,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Full Name', 
              controller: _nameController, 
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone Number', 
              controller: _phoneController, 
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email Address', 
              controller: _emailController, 
              keyboardType: TextInputType.emailAddress, 
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!v.contains('@') || !v.contains('.')) return 'Invalid email format';
                return null;
              }
            ),
            const SizedBox(height: 16),
            DynamicLocationSelector(
              value: _location,
              onChanged: (v) => setState(() => _location = v),
            ),
            const SizedBox(height: 16),
            AppRadioGroup(
              label: 'Gender',
              options: const ['Male', 'Female', 'Other'],
              selectedValue: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password', 
              controller: _passwordController, 
              isPassword: true, 
              validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirm Password', 
              controller: _confirmPasswordController, 
              isPassword: true,
              validator: (v) => v == null || v.isEmpty ? 'Please confirm password' : null
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms, 
                  onChanged: (v) => setState(() => _agreeToTerms = v ?? false)
                ),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('I agree to the ', style: theme.textTheme.bodySmall),
                      InkWell(
                        onTap: () => _showPolicyDialog('Terms of Use', 'TutorMate Terms of Use:\n1. All users must provide authentic information.\n2. Tutors must undergo verification.\n3. Content violating platform policy is strictly prohibited.'),
                        child: Text(
                          'Terms of Use', 
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary, 
                            decoration: TextDecoration.underline
                          )
                        ),
                      ),
                      Text(' and ', style: theme.textTheme.bodySmall),
                      InkWell(
                        onTap: () => _showPolicyDialog('Privacy Policy', 'TutorMate Privacy Policy:\n1. We respect your personal data privacy.\n2. User data is strictly used for tutoring matching.\n3. Documents are stored securely on Firebase Storage.'),
                        child: Text(
                          'Privacy Policy', 
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary, 
                            decoration: TextDecoration.underline
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Sign Up',
              isLoading: authProvider.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
