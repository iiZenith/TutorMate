import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/auth_floating_card_layout.dart';
import '../../../../shared/widgets/app_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFloatingCardLayout(
      title: 'TutorMate',
      subtitle: 'Find the Right Tutor Today or Join as an Educator',
      headerIcon: Icons.school,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Get Started',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Hire a Tutor',
            onPressed: () => context.push('/quick-entry?role=Student'),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Become a Tutor',
            isSecondary: true,
            onPressed: () => context.push('/quick-entry?role=Tutor'),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Register Institute',
            isSecondary: true,
            onPressed: () => context.push('/quick-entry?role=Institute'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?', style: Theme.of(context).textTheme.bodyMedium),
              TextButton(
                onPressed: () => context.push('/login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
