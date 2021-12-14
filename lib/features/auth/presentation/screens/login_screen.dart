import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/auth_floating_card_layout.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../app/app.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  
  const LoginScreen({super.key, this.role = 'Student'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final authProvider = AuthProviderInherited.of(context);
      
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProviderInherited.of(context);

    return AuthFloatingCardLayout(
      title: 'Welcome Back',
      subtitle: 'Sign in to continue',
      headerIcon: Icons.lock_outline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Account Login',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Email',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter your email' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              hint: 'Enter your password',
              isPassword: true,
              controller: _passwordController,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter your password' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Forgot Password not implemented yet')),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Log In',
              isLoading: authProvider.isLoading,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () {
                    context.go('/landing'); // Go back to landing to select a role
                  },
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
