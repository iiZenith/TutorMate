import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app.dart';

class StudentMainLayout extends StatelessWidget {
  final Widget child;
  
  const StudentMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              accountName: Text(user?.fullName ?? 'Student Name'),
              accountEmail: Text(user?.email ?? 'student@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.onPrimary,
                child: Text(
                  (user?.fullName ?? 'S')[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              otherAccountsPictures: [
                Tooltip(
                  message: 'Guardian/Student ID: ${user?.id ?? '12345'}',
                  child: Icon(
                    Icons.info_outline, 
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                  ),
                )
              ],
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go('/student/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Hire a Tutor'),
              onTap: () {
                Navigator.pop(context);
                context.push('/hire-tutor');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Requests'),
              onTap: () {
                Navigator.pop(context);
                // Placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('My Requests page coming soon'))
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.go('/student/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings page coming soon'))
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                authProvider.signOut();
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
