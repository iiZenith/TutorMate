import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/auth_floating_card_layout.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class QuickEntryScreen extends StatefulWidget {
  final String role;
  const QuickEntryScreen({super.key, required this.role});

  @override
  State<QuickEntryScreen> createState() => _QuickEntryScreenState();
}

class _QuickEntryScreenState extends State<QuickEntryScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String title = widget.role == 'Student' ? 'Need a Tutor?' : 'Register as a ${widget.role}';
    IconData icon = widget.role == 'Student' ? Icons.search : Icons.person_add;

    return AuthFloatingCardLayout(
      headerIcon: icon,
      title: title,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Let\'s get started',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Email Address',
              hint: 'Enter your email to continue',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Continue',
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  context.push('/detailed-registration?role=${widget.role}&email=${_emailController.text.trim()}');
                }
              },
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
