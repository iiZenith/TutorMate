import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import 'tutor_dashboard_content.dart';
import '../../../job_discovery/presentation/screens/job_board_screen.dart';
import '../../../tutor_profile/presentation/screens/tutor_profile_screen.dart';

class TutorMainLayout extends StatefulWidget {
  const TutorMainLayout({super.key});

  @override
  State<TutorMainLayout> createState() => _TutorMainLayoutState();
}

class _TutorMainLayoutState extends State<TutorMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TutorDashboardContent(),
    const JobBoardScreen(),
    const Center(child: Text('Applications Screen - Coming Soon')), // Placeholder
    const TutorProfileScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Job Board',
    'My Applications',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = AuthProviderInherited.of(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
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
              accountName: Row(
                children: [
                  Text(user?.fullName ?? 'Tutor Name'),
                  const SizedBox(width: 8),
                  Icon(Icons.verified_user, size: 16, color: theme.colorScheme.onPrimary),
                ],
              ),
              accountEmail: Text(user?.email ?? 'tutor@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.onPrimary,
                child: Text(
                  (user?.fullName ?? 'T')[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              otherAccountsPictures: [
                Tooltip(
                  message: 'Tutor ID: ${user?.id ?? 'TUT-9988'}',
                  child: Icon(
                    Icons.info_outline, 
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                  ),
                )
              ],
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Payments & Earnings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payments coming soon'))
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon'))
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support coming soon'))
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Job Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
