import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import 'tutor_dashboard_content.dart';
import '../../../job_discovery/presentation/screens/find_students_screen.dart';
import '../../../tutor_profile/presentation/screens/tutor_profile_screen.dart';

class TutorMainLayout extends StatefulWidget {
  const TutorMainLayout({super.key});

  @override
  State<TutorMainLayout> createState() => _TutorMainLayoutState();
}

class _TutorMainLayoutState extends State<TutorMainLayout> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Find Students',
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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              accountName: Row(
                children: [
                  Text(user?.fullName.isNotEmpty == true ? user!.fullName : 'Tutor'),
                  const SizedBox(width: 8),
                  Icon(Icons.verified_user, size: 16, color: theme.colorScheme.onPrimary),
                ],
              ),
              accountEmail: Text(user?.email.isNotEmpty == true ? user!.email : 'Not Provided'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.onPrimary,
                child: Text(
                  (user?.fullName.isNotEmpty == true ? user!.fullName : 'T')[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              otherAccountsPictures: [
                Tooltip(
                  message: 'Tutor ID: ${user?.id ?? 'Unknown'}',
                  child: Icon(
                    Icons.info_outline, 
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                  ),
                )
              ],
            ),
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
        children: [
          TutorDashboardContent(
            onBrowseTuitions: () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          const FindStudentsScreen(),
          const TutorProfileScreen(),
        ],
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
            label: 'Find Students',
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
