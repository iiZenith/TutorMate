import 'package:flutter/material.dart';
import '../../core/theme/app_radii.dart';

class AuthFloatingCardLayout extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? headerIcon;
  final Widget child;

  const AuthFloatingCardLayout({
    super.key,
    this.title,
    this.subtitle,
    this.headerIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Header with Fixed Height to avoid keyboard layout shifts
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: ClipPath(
              clipper: _HeaderClipper(),
              child: Container(color: theme.colorScheme.primary),
            ),
          ),
          // Scrollable Content
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    if (headerIcon != null)
                      Icon(headerIcon, size: 64, color: theme.colorScheme.onPrimary),
                    if (title != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        title!,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // Floating Card
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      elevation: 8,
                      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.borderRadiusLarge,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
