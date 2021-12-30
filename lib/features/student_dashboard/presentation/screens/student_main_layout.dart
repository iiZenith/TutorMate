import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app.dart';

class StudentMainLayout extends StatelessWidget {
  final Widget child;
  
  const StudentMainLayout({super.key, required this.child});

  String _getTitle(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/student/profile')) {
      return 'My Profile';
    }
    if (location.contains('/my-requests')) {
      return 'My Tuition Requests';
    }
    if (location.contains('/hire-tutor')) {
      return 'Post Tuition Requirement';
    }
    return 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              accountName: Text(user?.fullName.isNotEmpty == true ? user!.fullName : 'Student'),
              accountEmail: Text(user?.email.isNotEmpty == true ? user!.email : 'Not Provided'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.onPrimary,
                backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                    ? Text(
                        (user?.fullName.isNotEmpty == true ? user!.fullName : 'S')[0].toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary, 
                          fontSize: 24, 
                          fontWeight: FontWeight.bold
                        ),
                      )
                    : null,
              ),
              otherAccountsPictures: [
                Tooltip(
                  message: 'Guardian/Student ID: ${user?.id ?? 'Unknown'}',
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
                context.go('/dashboard/student');
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
                context.go('/my-requests');
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
