import 'dart:developer';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oviasogie_school_mis/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sidebarx/sidebarx.dart';
import 'package:sn_progress_dialog/enums/progress_types.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';
// import '../../components/widgets/process_dialog.dart';
import '../learner/shared/platform_helpers.dart';
import '../settings_page.dart';
import 'admissions.dart';
import 'attendance.dart';
import 'fees_management.dart';
import 'results.dart';
import 'timetables.dart';
import 'notifications.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Widget divider =
      Divider(color: Colors.black87.withValues(alpha: 0.3), height: 1);
  final SidebarXController? controller =
      SidebarXController(selectedIndex: 0, extended: true);
  Map<String, dynamic>? adminDetails = {};
  Map<String, dynamic> summaryData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        getAdminDetails();
        if (kIsWeb) {
          // Listen for the browser back button on web
          PlatformSpecificImplementation.initializeBackButtonHandler(context);
        }
      },
    );
  }

  void getAdminDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      MyAlertDialog.showSnackbar(context, 'You are not logged in.',
          isSuccess: false);
      GoRouter.of(context).go('/');
    }
    adminDetails?['token'] = prefs.getString('token')!.substring(6) ?? '';
    adminDetails?['staffNumber'] = prefs.getString('staffNumber') ?? '';
    adminDetails?['email'] = prefs.getString('email') ?? '';
    adminDetails?['username'] = prefs.getString('username') ?? '';
    setState(() {});
    debugPrint('Admin details: $adminDetails');
    fetchSummaryData();
  }

  Future<void> fetchSummaryData() async {
    if (_isLoading) return;
    // Simulate a network request
    ProgressDialog pd = ProgressDialog(context: context);

    pd.show(
      max: 50,
      msg: 'Fetching Summary Data...',
      hideValue: true,
      closeWithDelay: 50,

      /// Assign the type of progress bar.
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/admin/dashboard-summary"),
        headers: {
          'Authorization': 'Bearer ${adminDetails?['token']}',
        },
      );
      log('$adminDetails');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Data from server: $data');
        setState(() {
          summaryData = data['data'];
        });
      } else {
        final errorData = (response.body);
        // log('Error from server: $errorData');
        MyAlertDialog.showSnackbar(context, 'Error: $errorData',
            isSuccess: false);
      }
    } on Exception catch (e) {
      debugPrint('An error occurred: $e');
      MyAlertDialog.showSnackbar(context, 'An error occurred: $e',
          isSuccess: false);
    } finally {
      pd.close();
      setState(() => _isLoading = false);
    }
  }

  // void _pushAttendanceData() async {
  //   final response = await http.post(
  //     Uri.parse("${ApiUtils.baseUrl}/admin/attendance"),
  //     headers: {
  //       'Authorization': 'Bearer ${adminDetails?['token']}',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'week': selectedWeek,
  //       'attendance': learners,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     // Show success message
  //   } else {
  //     // Handle error
  //   }
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Image.asset('assets/images/admin-icon.png'),
              ),
            );
          },
          items: const [
            SidebarXItem(icon: Icons.dashboard, label: ' Dashboard'),
            SidebarXItem(icon: Icons.school_sharp, label: ' Admissions'),
            SidebarXItem(icon: Icons.analytics, label: ' Attendance'),
            SidebarXItem(icon: Icons.attach_money, label: ' Fees Management'),
            SidebarXItem(icon: Icons.checklist, label: ' Results'),
            SidebarXItem(icon: Icons.schedule, label: ' Timetables'),
            SidebarXItem(icon: Icons.notifications, label: ' Notifications'),
          ],
        ),
      ),
      appBar: AppBar(
        title: adminDetails!.isNotEmpty
            ? Text(
                "Welcome, admin ${adminDetails?['username'].toString().split(' ').first}!")
            : const Text("Admin Dashboard"),
        backgroundColor: Colors.red[50],
        actions: [
          TextButton.icon(
          icon: const Icon(Icons.logout, color: Colors.black, size: 20),
          label: const Text('Logout'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red[400],
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
            onPressed: () async {
              final response = await http.post(
                Uri.parse("${ApiUtils.baseUrl}/admin/logout"),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${adminDetails!['token']}',
                },
              );

              if (response.statusCode == 200) {
                final responseBody = json.decode(response.body);
                if (responseBody['status'] == 'success') {
                  log("$responseBody");
                  debugPrint('Logged out successfully');
                } else {
                  debugPrint('Logout failed: ${responseBody['message']}');
                }
              } else {
                log(response.body);
                debugPrint('Failed to logout: ${response.reasonPhrase}');
              }
              MyAlertDialog.showSnackbar(context, 'Logout successfully.',
                  isSuccess: true);
              GoRouter.of(context).go('/');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          indicatorColor: primaryTheme,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
            Tab(icon: Icon(Icons.school_sharp), text: "Admissions"),
            Tab(icon: Icon(Icons.analytics), text: "Attendance"),
            Tab(icon: Icon(Icons.attach_money), text: "Fees Management"),
            Tab(icon: Icon(Icons.checklist), text: "Results"),
            Tab(icon: Icon(Icons.schedule), text: "Timetables"),
            Tab(icon: Icon(Icons.notifications), text: "Notifications"),
          ],
        ),
      ),
      body: adminDetails!.isEmpty
          ? const Center(child: CupertinoActivityIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildDashboardContent(),
                Admissions(
                  token: adminDetails?['token'] ?? "",
                  staffNumber: adminDetails?['staffNumber'] ?? "",
                ),
                Attendance(
                  token: adminDetails?['token'] ?? "",
                  staffNumber: adminDetails?['staffNumber'] ?? "",
                ),
                FeesManagement(
                  token: adminDetails?['token'] ?? "",
                  staffNumber: adminDetails?['staffNumber'] ?? "",
                ),
                Results(
                  token: adminDetails?['token'] ?? "",
                  staffNumber: adminDetails?['staffNumber'] ?? "",
                ),
                Timetables(
                  token: adminDetails?['token'] ?? "",
                  staffNumber: adminDetails?['staffNumber'] ?? "",
                ),
                Notifications(
                  token: adminDetails?['token'] ?? "",
                  staffNumber: adminDetails?['staffNumber'] ?? "",
                ),
              ],
            ),
    );
  }

  Widget buildDashboardContent() {
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
                child: const Text('Logout'),
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
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Admin dashboard'),
          trailing: GestureDetector(
            onTap: _isLoading ? null : fetchSummaryData,
            child: Icon(
              CupertinoIcons.refresh,
              color: _isLoading ? CupertinoColors.inactiveGray : null,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildSummaryCard(
                      icon: Icons.people,
                      title: 'Learners',
                      subtitle:
                          'Total: ${summaryData['learners']?['total'] ?? 'Loading...'}\nMale: ${summaryData['learners']?['male'] ?? 'Loading...'}\nFemale: ${summaryData['learners']?['female'] ?? 'Loading...'}',
                      color: Colors.blue,
                    ),
                    buildSummaryCard(
                      icon: Icons.attach_money,
                      title: 'Fees',
                      subtitle:
                          'Paid: ₦${summaryData['fees']?['paid'] ?? 'Loading...'}\nPending: ₦${summaryData['fees']?['pending'] ?? 'Loading...'}\nApprovals: ${summaryData['fees']?['approvals'] ?? 'Loading...'}',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildSummaryCard(
                      icon: Icons.check_circle,
                      title: 'Attendance',
                      subtitle:
                          'Absentees: ${summaryData['attendance']?['absentees'] ?? 'Loading...'}\nAvg: ${summaryData['attendance']?['average'] ?? 'Loading...'}',
                      color: Colors.orange,
                    ),
                    buildSummaryCard(
                      icon: Icons.school,
                      title: 'Exams',
                      subtitle:
                          'Upcoming: ${summaryData['results']?['upcoming'] ?? 'Loading...'}\nCompleted: ${summaryData['results']?['completed'] ?? 'Loading...'}',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    log('Shared Preferences cleared : admin_dashboard.dart');
    if (mounted) {
      GoRouter.of(context).go('/');
    }
  }

  Widget buildSummaryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
