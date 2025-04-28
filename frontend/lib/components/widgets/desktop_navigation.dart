import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oviasogie_school_mis/theme/colors.dart';

class DesktopNavigation extends StatelessWidget {
  const DesktopNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: 0,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/admin-dashboard');
            break;
          case 2:
            context.go('/learner-dashboard');
            break;
          case 3:
            context.go('/settings'); 
            break;
        }
      },
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Image.asset(
            'assets/images/admin-icon.png',
            width: 24.0, // Set the desired width
            height: 24.0, // Set the desired height
            color: primaryTheme,
          ),
          label: const Text('Admin Portal'),
        ),
        NavigationRailDestination(
          icon: Image.asset(
            'assets/images/student-icon.png',
            width: 24.0, // Set the desired width
            height: 24.0, // Set the desired height
            color: primaryTheme,
          ),
          label: const Text('Learner Portal'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }
}
