import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oviasogie_school_mis/theme/colors.dart';
import 'package:oviasogie_school_mis/theme/themes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Center(
            child: UserAccountsDrawerHeader(
              accountName: Text(
                'John Doe',
                style: customTextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                'john.doe@gmail.com',
                style: customTextStyle(
                    color: Colors.white, fontStyle: FontStyle.italic),
              ),
              currentAccountPicture: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40.0,
                    child: Container(
                      height: 55.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          fit: BoxFit.scaleDown,
                          image:
                              AssetImage('assets/images/avatar_icon_no_bg.png'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              decoration: const BoxDecoration(
                color: primaryTheme,
              ),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(
                Icons.home_rounded,
                color: primaryTheme,
              ),
            ),
            title: const Text('Home'),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Image.asset(
                'assets/images/admin-icon.png',
                width: 24.0, // Set the desired width
                height: 24.0, // Set the desired height
                color: primaryTheme,
              ),
            ),
            title: const Text('Admin Portal'),
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/admin-dashboard');
              });
            },
          ),
          ListTile(
            leading: CircleAvatar(
              child: Image.asset(
                'assets/images/student-icon.png',
                width: 24.0, // Set the desired width
                height: 24.0, // Set the desired height
                color: primaryTheme,
              ),
            ),
            title: const Text('Learner Portal'),
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/learner-dashboard');
              });
            },
          ),
          const Divider(), // Add a divider
          ListTile(
            leading: const CircleAvatar(
              child: Icon(
                Icons.settings,
                color: primaryTheme,
              ),
            ),
            title: const Text('Settings'),
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/settings'); 
              });
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(
                Icons.exit_to_app,
                color: primaryTheme,
              ),
            ),
            title: const Text('Exit'),
            onTap: () {
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
