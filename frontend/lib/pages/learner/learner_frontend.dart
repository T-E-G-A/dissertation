import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oviasogie_school_mis/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';
import '../../components/widgets/process_dialog.dart';
import '../../responsiveness/screen_type.dart';
import '../../theme/themes.dart';
import 'shared/platform_helpers.dart';

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
          title: const Text("Learner Dashboard"),
          backgroundColor: Colors.grey[200],
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                backgroundColor: const Color(0xFF007377),
              ),
              onPressed: () {
                MyAlertDialog.showSnackbar(context, 'Logout successfully.',
                    isSuccess: true);
                resetSharedPreferences(context);
              },
              label:
                  const Text("Logout", style: TextStyle(color: Colors.white)),
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
class Fees extends StatefulWidget {
  final String token;
  final String admissionNumber;
  final String username;


  const Fees({super.key, required this.token, required this.admissionNumber, required this.username});

  @override
  State<Fees> createState() => _FeesState();
}

class _FeesState extends State<Fees> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, double>? feeInformation = {};
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pullFeeInformation();
    });
  }

  void _pullFeeInformation() async {
    feeInformation = await fetchFeeInformation();
    setState(() {});
  }

  Future<Map<String, double>> fetchFeeInformation() async {
    // make the post request to the server
    // final response = await http.post(
    //   Uri.parse("https://api.example.com/fees"),
    //   body: {
    //     "token": widget.token,
    //     "admissionNumber": widget.admissionNumber,
    //   },
    // );
    // final data = jsonDecode(response.body);
    // return data;
    ProcessDialog.show(context: context, title: 'Fetching Fees', text: 'Please wait...');
    await Future.delayed(const Duration(seconds: 2));
    if(mounted) {
      Navigator.of(context).pop();
    }
    return {"total_fees": 1000, "paid_fees": 700, "pending_approval": 0};
  }

    void _payFee(double amount) async {
    debugPrint('$amount');
    if (amount <= 0) {
      MyAlertDialog.showSnackbar(context, "Enter a valid positive amount: $amount");
      return;
    }
    if (amount > feeInformation!['total_fees']!) {
      MyAlertDialog.showSnackbar(context, "Amount cannot exceed pending fees: $amount");
      return;
    }
    final newFeeInformation = await postFeePayment(amount);
    setState(() {
      feeInformation = newFeeInformation;
    });
  }
  
  Future<Map<String, double>> postFeePayment(double feeToPay) async {
    // make the post request to the server
    // final response = await http.post(
    //   Uri.parse("https://api.example.com/pay-fees"),
    //   body: {
    //     "student_id": "12345",
    //     "amount": feeToPay,
    //   },
    // );
    // final data = jsonDecode(response.body);
    // return data;
    ProcessDialog.show(context: context, title: 'Paying Fees: $feeToPay', text: 'Please wait...');
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();
    return {"total_fees": 1000, "paid_fees": 700, "pending_approval": feeToPay};
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeesSection(),
            const SizedBox(height: 10),
            _buildFeePaymentForm(context),
          ],
        ),
      ),
    );
  }

Widget _buildFeesSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                        'assets/images/credit-card.png',
                        width: 36, // Set the desired width
                        height: 36, // Set the desired height
                        color: Colors.blue,
                      ),
                  const SizedBox(width: 10),
                  const Text(
                    "Fees Overview",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1.5, height: 20),
              const SizedBox(height: 10),
              Text(
                "Total Fees: N${feeInformation!['total_fees']}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Fees Paid: N${feeInformation!['paid_fees']}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Pending Approval: N${feeInformation!['pending_approval']}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 30),
      const Text(
        "Pay Fees",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Image.asset(
            "assets/images/mastercard.png",
            height: 40,
          ),
          const SizedBox(width: 15),
          Image.asset(
            "assets/images/paypal.png",
            height: 40,
          ),
          const SizedBox(width: 15),
          Image.asset(
            "assets/images/visa.png", // Add more payment options if necessary
            height: 40,
          ),
        ],
      ),
    ],
  );
}
  Widget _buildFeePaymentForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 400,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter an amount";
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return "Enter a valid positive amount";
                }
                if (amount < 100) {
                  return "Amount cannot be below 100";
                }
                if (amount > feeInformation!['total_fees']!) {
                  return "Amount cannot exceed pending fees";
                }
                setState(() {
                  _amountController.text = amount.toString();
                });
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.admissionNumber,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Admission Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key_sharp),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.username,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: "${DateTime.now().toLocal()}".split(' ')[0],
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Payment Date",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
            icon: const Icon(Icons.payment, color: Colors.white),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 100),
              backgroundColor: const Color(0xFF001177),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                  // MyAlertDialog.showSnackbar(context, "Your payment was successful. Thank you!");
                  double? amount = double.tryParse(_amountController.text.toString());
                _formKey.currentState!.reset();
                _payFee(amount!);
                }
            },
            label: const Text("Pay Now", style: TextStyle(color: Colors.white)),
          ),
          ],
        ),
      ),
    );
  }
}

class Notifications extends StatefulWidget {
  final String token;
  final String admissionNumber;
  const Notifications(
      {super.key, required this.token, required this.admissionNumber});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Map<String, String>>? learnerNotifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pullLearnerNotifications();
    });
  }

  void _pullLearnerNotifications() async {
    learnerNotifications = await fetchNotifications();
    if(mounted) {
      setState(() {});
    }
  }

  Future<List<Map<String, String>>> fetchNotifications() async {
    // make the post request to the server
    // final response = await http.post(
    //   Uri.parse("https://api.example.com/notifications"),
    //   body: {
    //     "token": widget.token,
    //     "admissionNumber": widget.admissionNumber,
    //   },
    // );
    // final data = jsonDecode(response.body);
    // return data;
    ProcessDialog.show(
        context: context,
        title: 'Fetching Notifications',
        text: 'Please wait...');
    await Future.delayed(const Duration(seconds: 2));
    if(mounted) {
      Navigator.of(context).pop();
    }
    return [
      {
        "title": "Exam Reminder",
        "body": "Math exam on Monday.",
        "created_at": "2025-01-01 11:00:00"
      },
      {
        "title": "Fee Payment",
        "body": "Your fee payment is pending.",
        "created_at": "2025-01-01 09:00:00"
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _buildNotificationsSection();
  }

  Widget _buildNotificationsSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: learnerNotifications?.length,
      itemBuilder: (context, index) {
        final notification = learnerNotifications?[index];
        return Card(
          elevation: 4,
          child: ListTile(
            leading: const Icon(CupertinoIcons.bell_fill, color: Colors.blue),
            title: Text(notification!['title']!),
            subtitle: Text(notification['body']!),
            trailing: Text(notification['created_at']!, style: const TextStyle(fontStyle: FontStyle.italic)),
          ),
        );
      },
    );
  }
}

class Results extends StatefulWidget {
  final String token;
  final String admissionNumber;
  const Results({super.key, required this.token, required this.admissionNumber});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  Map<String, dynamic>? learnerResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pullLearnerResults();
    });
  }

  void _pullLearnerResults() async {
    learnerResult = await fetchResults();
    setState(() {});
  }

  Future<Map<String, dynamic>> fetchResults() async {
    ProcessDialog.show(
        context: context,
        title: 'Fetching Results',
        text: 'Please wait...');
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();
    return {
      "admission": widget.admissionNumber,
      "name": "Joseph Ali",
      "Maths": 85,
      "English": 90,
      "Science": 88,
    };
  }

  void _downloadResults() async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Results for ${learnerResult!['name']}',
                    style: const pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Text('Admission: ${learnerResult!['admission']}'),
                pw.Text('Maths: ${learnerResult!['Maths']}'),
                pw.Text('English: ${learnerResult!['English']}'),
                pw.Text('Science: ${learnerResult!['Science']}'),
              ],
            ),
          ),
        ),
      );

      final bytes = await pdf.save();
      final filename = '${learnerResult!['admission']}_results.pdf';
      const fileType = 'application/pdf';

      if (kIsWeb) {
      PlatformSpecificImplementation.downloadFile(bytes, filename, fileType);
      } else {
        PlatformSpecificImplementation.downloadFile(bytes, filename, fileType);
      }
    } catch (e) {
      MyAlertDialog.showSnackbar(context, 'Failed to download PDF: $e', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Results'),
        backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
      ),
      body: learnerResult == null
          ? const Center(child: CircularProgressIndicator())
          : _buildResultsSection(),
    );
  }

  Widget _buildResultsSection() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            learnerResult!['name'],
                            style: customTextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Admission: ${learnerResult!['admission']}',
                            style: customTextStyle(fontSize: 18, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Colors.white54),
                  Text(
                    'Results:',
                    style: customTextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Maths: ${learnerResult!['Maths']}', style: customTextStyle(color: Colors.white)),
                  Text('English: ${learnerResult!['English']}', style: customTextStyle(color: Colors.white)),
                  Text('Science: ${learnerResult!['Science']}', style: customTextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                      onPressed: _downloadResults,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Timetables extends StatefulWidget {
  final String token;
  final String admissionNumber;
  const Timetables({super.key, required this.token, required this.admissionNumber});

  @override
  State<Timetables> createState() => _TimetablesState();
}

class _TimetablesState extends State<Timetables> {
  List<Map<String, dynamic>> learnerTimetables = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pullLearnerTimetables();
    });
  }

  void _pullLearnerTimetables() async {
    learnerTimetables = await fetchTimetables();
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchTimetables() async {
    // make the post request to the server
    // final response = await http.post(
    //   Uri.parse("https://api.example.com/timetables"),
    //   body: {
    //     "token": widget.token,
    //     "admissionNumber": widget.admissionNumber,
    //   },
    // );
    // final data = jsonDecode(response.body);
    // return data;
    ProcessDialog.show(
        context: context,
        title: 'Fetching Timetables',
        text: 'Please wait...');
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();
    return List.generate(
      5,
      (index) => {
        "id": index + 1,
        "name": "Class ${index + 1} - Timetable",
        "description": "File Type: pdf, Size: ${index + 1} kb",
        "url": "https://annehill.school/wp-content/uploads/2021/07/AHI-Primary-School-Sample-Timetable.pdf",
        "created_at": "2025-01-0${index + 1} 09:10:19",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTimetablesSection();
  }

  Widget _buildTimetablesSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: learnerTimetables.length,
      itemBuilder: (context, index) {
        final timetable = learnerTimetables[index];
        return ListTile(
          leading: const Icon(Icons.schedule, color: Colors.orange),
          title: Text(timetable['name']),
          subtitle: Text(
            '${timetable['description']}\nCreated at: ${timetable['created_at']}',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          trailing: const Icon(Icons.download),
          onTap: () async {
            final url = timetable['url'];
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $url')),
              );
            }
          },
        );
      },
    );
  }
}