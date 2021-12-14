import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/auth_floating_card_layout.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_dropdown.dart';
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
  final _areaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedCity;
  String _selectedGender = 'Other';
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the Terms of Use'))
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'))
      );
      return;
    }

    final authProvider = AuthProviderInherited.of(context);
    await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      UserRole.fromString(widget.role),
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
              validator: (v) => v!.isEmpty ? 'Required' : null
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone Number', 
              controller: _phoneController, 
              keyboardType: TextInputType.phone
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email Address', 
              controller: _emailController, 
              keyboardType: TextInputType.emailAddress, 
              validator: (v) => v!.isEmpty ? 'Required' : null
            ),
            const SizedBox(height: 16),
            AppDropdown(
              label: 'City',
              hint: 'Select your city',
              value: _selectedCity,
              items: const ['Kathmandu', 'Lalitpur', 'Bhaktapur', 'Pokhara', 'Chitwan'],
              onChanged: (v) => setState(() => _selectedCity = v),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Location / Area', 
              controller: _areaController
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
              validator: (v) => v!.length < 6 ? 'Min 6 chars' : null
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirm Password', 
              controller: _confirmPasswordController, 
              isPassword: true
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms, 
                  onChanged: (v) => setState(() => _agreeToTerms = v ?? false)
                ),
                Expanded(
                  child: Text(
                    'I agree to the Terms of Use and Privacy Policy', 
                    style: Theme.of(context).textTheme.bodySmall
                  )
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
