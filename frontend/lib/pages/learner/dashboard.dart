import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oviasogie_school_mis/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';
import '../../responsiveness/screen_type.dart';
import '../settings_page.dart';
import 'fees.dart';
import 'notifications.dart';
import 'results.dart';
import 'shared/platform_helpers.dart';
import 'timetables.dart';

import 'package:http/http.dart' as http;

class LearnerDashboard extends StatefulWidget {
  const LearnerDashboard({super.key});

  @override
  State<LearnerDashboard> createState() => _LearnerDashboardState();
}

class _LearnerDashboardState extends State<LearnerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Widget divider =
      Divider(color: Colors.black87.withValues(alpha: 0.3), height: 1);
  final SidebarXController? controller =
      SidebarXController(selectedIndex: 0, extended: true);
  Map<String, dynamic>? learnerDetails = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        getLearnerDetails();
      },
    );
    if (kIsWeb) {
      // Listen for the browser back button on web
      PlatformSpecificImplementation.initializeBackButtonHandler(context);
    }
  }

  void getLearnerDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      MyAlertDialog.showSnackbar(context, 'You are not logged in.',
          isSuccess: false);
      GoRouter.of(context).go('/');
    }
    learnerDetails?['token'] = prefs.getString('token')!.substring(8) ?? '';
    learnerDetails?['admissionNumber'] =
        prefs.getString('admissionNumber') ?? '';
    learnerDetails?['username'] = prefs.getString('username') ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Screens.getType(context) == ScreenTypes.mobile;
    return WillPopScope(
      onWillPop: () async {
        // Show a confirmation dialog before logging out
        bool shouldLogout = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout Confirmation'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
            ],
          ),
        );

        if (shouldLogout) {
          // Perform logout logic here
          if (mounted) {
            resetSharedPreferences(context);
          }
        }

        // Return false to prevent the default back button action
        return false;
      },
      child: Scaffold(
        drawer: SizedBox(
          width: 200,
          child: SidebarX(
            controller: SidebarXController(selectedIndex: 0, extended: true),
            footerDivider: divider,
            footerItems: [
              SidebarXItem(
                icon: Icons.settings,
                label: ' Settings',
                onTap: () {
                  MyAlertDialog.showSnackbar(context, 'Settings clicked.');
                  context.go('/settings');
                },
              ),
              SidebarXItem(
                icon: Icons.help,
                label: ' Help',
                onTap: () {
                  MyAlertDialog.showSnackbar(context, 'Help clicked.');
                },
              ),
              SidebarXItem(
                icon: Icons.logout,
                label: ' Logout',
                onTap: () {
                  MyAlertDialog.showSnackbar(context, 'Logout clicked.');
                },
              ),
            ],
            separatorBuilder: (context, index) => divider,
            headerBuilder: (context, extended) {
              return SizedBox(
                height: 100,
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset('assets/images/student-icon.png'),
                ),
              );
            },
            items: const [
              SidebarXItem(icon: Icons.home, label: ' Fees'),
              SidebarXItem(icon: Icons.search, label: ' Notifications'),
              SidebarXItem(icon: Icons.home, label: ' Results'),
              SidebarXItem(icon: Icons.search, label: ' Timetables'),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
            "Learner Dashboard: ${learnerDetails?['username']}",
            style: const TextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.grey[200],
          actions: [
            TextButton.icon(
              label: const Text('Logout', style: TextStyle(color: Colors.black)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[400],
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.logout, size: 20, color: Colors.blue),
              onPressed: () async {
                final response = await http.post(
                  Uri.parse("${ApiUtils.baseUrl}/learner/logout"),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ${learnerDetails!['token']}',
                  },
                );

                if (response.statusCode == 200) {
                  final responseBody = json.decode(response.body);
                  if (responseBody['status'] == 'success') {
                    log("$responseBody");
                    print('Logged out successfully');
                  } else {
                    print('Logout failed: ${responseBody['message']}');
                  }
                } else {
                  log(response.body);
                  print('Failed to logout: ${response.reasonPhrase}');
                }
                MyAlertDialog.showSnackbar(context, 'Logout successfully.',
                    isSuccess: true);
                GoRouter.of(context).go('/');
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: primaryTheme,
            physics: const NeverScrollableScrollPhysics(),
            tabs: const [
              Tab(icon: Icon(Icons.attach_money), text: "Fees"),
              Tab(icon: Icon(Icons.notifications), text: "Notifications"),
              Tab(icon: Icon(Icons.school), text: "Exam Results"),
              Tab(icon: Icon(Icons.schedule), text: "Timetables"),
            ],
          ),
        ),
        body: learnerDetails!.isEmpty
            ? const Center(child: CupertinoActivityIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  Fees(
                    token: learnerDetails?['token'] ?? "",
                    admissionNumber: learnerDetails?['admissionNumber'] ?? "",
                    username: learnerDetails?['username'] ?? "",
                  ),
                  Notifications(
                    token: learnerDetails?['token'] ?? "",
                    admissionNumber: learnerDetails?['admissionNumber'] ?? "",
                  ),
                  Results(
                    token: learnerDetails?['token'] ?? "",
                    admissionNumber: learnerDetails?['admissionNumber'] ?? "",
                  ),
                  Timetables(
                    token: learnerDetails?['token'] ?? "",
                    admissionNumber: learnerDetails?['admissionNumber'] ?? "",
                  ),
                ],
              ),
      ),
    );
  }

  void resetSharedPreferences(BuildContext context) async {
     final prefs = await SharedPreferences.getInstance();
    await ApiUtils.loadIpAddress();
    await ApiUtils.loadSelectedServer();
    String selectedServer = ApiUtils.baseUrl;
    String selectedIp = ApiUtils.currentIp;
    prefs.clear();
    await ApiUtils.setIpAddress(selectedIp);
    await ApiUtils.setBaseUrl(selectedServer);
    log('Shared Preferences cleared : learner_dashboard.dart');
    if (mounted) {
      GoRouter.of(context).go('/');
    }
  }
}
