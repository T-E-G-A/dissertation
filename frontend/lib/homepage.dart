import 'dart:developer';
import 'dart:io';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oviasogie_school_mis/components/widgets/alert_dialog.dart';
import 'package:oviasogie_school_mis/components/widgets/app_drawer.dart';
import 'package:oviasogie_school_mis/pages/auth/online_admission.dart';
import 'package:oviasogie_school_mis/components/widgets/desktop_navigation.dart';
import 'package:oviasogie_school_mis/components/shapes/splash_clipper.dart';
import 'package:oviasogie_school_mis/components/widgets/mission_vision_goal_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_utils.dart';
import 'responsiveness/screen_type.dart';
import 'theme/colors.dart';
import 'theme/themes.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
 int _selectedServerIndex = 0; // 0 for Laravel, 1 for Node.js
@override
void initState() { 
  super.initState();
  if(mounted) {
    resetSharedPreferences(context);
    _loadSelectedServer();
  }
}

Future<void> _loadSelectedServer() async {
    await ApiUtils.loadSelectedServer();
    setState(() {
      _selectedServerIndex = ApiUtils.baseUrl.contains('8000') ? 0 : 1;

    });
  }
  Future<void> _onServerToggle(int? index) async {
    if (index == null) return;
    setState(() {
      _selectedServerIndex = index;
    });
    final serverValue = index == 0 ? 'laravel' : 'nodejs';
    await ApiUtils.setBaseUrl(serverValue);
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
  }
  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Screens.getType(context) == ScreenTypes.desktop;

    return WillPopScope(
    onWillPop: () async {
      // Show a confirmation dialog before logging out
      bool shouldExit = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit Confirmation'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        ),
      );

      if (shouldExit) {
        // Perform logout logic here
        if(mounted) {
          exit(0);
        }
      }

      // Return false to prevent the default back button action
      return false;
    },
    child: Scaffold(
        appBar:
            !isDesktop ? AppBar(
        title: const Text('Oviasogie Pre School'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ToggleSwitch(
              minWidth: 90.0,
              cornerRadius: 20.0,
              activeBgColors: const [[Color(0xFFfc4b3b)], [Color(0xFF3c863c)]],
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              initialLabelIndex: _selectedServerIndex,
              totalSwitches: 2,
              labels: const ['Laravel', 'Node.js'],
              radiusStyle: true,
              onToggle: _onServerToggle,
            ),
          ),
        ],
      ) : null, 
        drawer: !isDesktop
            ? const AppDrawer()
            : null,
        body: Row(
          children: [
            if (isDesktop)
              const DesktopNavigation(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Section
                    Stack(
                      children: [
                        Image.asset(
                          'assets/images/hero.jpg',
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * 0.96,
                          height: !isDesktop? 400 : 360,
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SelectableText(
                                  "WELCOME TO OVIASOGIE PRE SCHOOL",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fancyFont,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 5.0,
                                        color: Colors.black,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                const SelectableText(
                                  "At Oviasogie Pre School, we nurture young minds,\n"
                                  "foster creativity, and build a strong foundation\n"
                                  "for lifelong learning.",
                                  style: TextStyle(
                                    fontFamily: primaryFont,
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007377),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 32),
                                  ),
                                  onPressed: () {
                                    MyAlertDialog.showSnackbar(
                                        context, 'Online Admission');
                                    _showRegisterDialog(context);
                                  },
                                  child: Text(
                                    "Online Admission",
                                    style: customTextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Mission, Vision, Goal Section
                    // Row for Mission, Vision, and Goal
                    if(!isDesktop)
                    _buildMobileMissionVisionGoalSection(context)
                    else 
                    _buildDesktopMissionVisionGoalSection(context),
                    // Objectives Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SelectableText(
                            "Oviasogie Pre School Objectives 2025",
                            style: TextStyle(
                              fontFamily: primaryFont,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.teal,
                              color: Colors.teal
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ClipPath(
                                  clipper: SplashClipper(),
                                  child: Image.asset(
                                    'assets/images/play.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      "Play and Learn",
                                      style: customTextStyle(
                                          fontSize: 18,
                                          color: primaryTheme,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    SelectableText(
                                      "Our innovative programs combine play and learning, ensuring young children develop critical thinking and social skills.",
                                      style: customTextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      "Enhance Learning Environment",
                                      style: customTextStyle(
                                          fontSize: 18,
                                          color: primaryTheme,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    SelectableText(
                                      "Continuously improve facilities to provide the best environment for young learners.",
                                      style: customTextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ClipPath(
                                  clipper: SplashClipper(),
                                  child: Image.asset(
                                    'assets/images/learning.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ClipPath(
                                  clipper: SplashClipper(),
                                  child: Image.asset(
                                    'assets/images/community.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      "Strengthen Community Engagement",
                                      style: customTextStyle(
                                          fontSize: 18,
                                          color: primaryTheme,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    SelectableText(
                                      "Partner with parents and the community to ensure holistic development of every child.",
                                      style: customTextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
      
                    // Call to Action Section
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SelectableText(
                            "Join Us Today!",
                            style: customTextStyle(
                              fontSize: 14,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SelectableText(
                            "Whether you're a parent, guardian, or an administrator, Oviasogie Pre School is ready to welcome you. Click below to access your portal.",
                            style: customTextStyle(
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 32),
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  // Admin portal navigation
                                  GoRouter.of(context).go('/admin-dashboard');
                                },
                                child: const Text(
                                  "Admin Portal",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 32),
                                  backgroundColor: const Color(0xFF007377),
                                ),
                                onPressed: () {
                                  // Learner portal navigation
                                  GoRouter.of(context).go('/learner-dashboard');
                                },
                                child: const Text("Learner Portal",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildMobileMissionVisionGoalSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        // Mission
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: MissionVisionGoalCard(
            imagePath: 'assets/images/play.jpg',
            title: 'Our Mission',
            description:
                'Our mission is to nurture the curiosity, creativity, and confidence of our youngest learners. We believe that every child is unique and deserves a safe, joyful, and stimulating environment to grow and explore.',
            buttonText: 'Read More',
            onPressed: () {
              MyAlertDialog.showSnackbar(context, 'Mission details');
            },
          ),
        ),
        // Vision
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: MissionVisionGoalCard(
            imagePath: 'assets/images/community.jpg',
            title: 'Our Vision',
            description:
                'Our vision is to create a nurturing environment where children feel valued, supported, and inspired to explore the world around them. We aim to cultivate a love of learning that lasts a lifetime, encouraging our students to embrace new challenges with enthusiasm and creativity.',
            buttonText: 'Read More',
            onPressed: () {
              MyAlertDialog.showSnackbar(context, 'Vision details');
            },
          ),
        ),
        // Goal
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: MissionVisionGoalCard(
            imagePath: 'assets/images/learning.jpg',
            title: 'Our Goal',
            description:
                'Our goal is to create a nurturing and stimulating environment where every child feels valued and empowered to explore their full potential. We aim to foster a love for learning that extends beyond the classroom, encouraging curiosity, creativity, and critical thinking from the earliest years.',
            buttonText: 'Read More',
            onPressed: () {
              MyAlertDialog.showSnackbar(context, 'Goal details');
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildDesktopMissionVisionGoalSection(BuildContext context) {
  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Mission
                        Expanded(
                          child: MissionVisionGoalCard(
                            imagePath: 'assets/images/play.jpg',
                            title: 'Our Mission',
                            description:
                                'Our mission is to nurture the curiosity, creativity, and confidence of our youngest learners. We believe that every child is unique and deserves a safe, joyful, and stimulating environment to grow and explore.',
                            buttonText: 'Read More',
                            onPressed: () {
                              MyAlertDialog.showSnackbar(
                                  context, 'Mission details');
                            },
                          ),
                        ),
                        const SizedBox(width: 16), // Spacer
                        // Vision
                        Expanded(
                          child: MissionVisionGoalCard(
                            imagePath: 'assets/images/community.jpg',
                            title: 'Our Vision',
                            description:
                                'Our vision is to create a nurturing environment where children feel valued, supported, and inspired to explore the world around them. We aim to cultivate a love of learning that lasts a lifetime, encouraging our students to embrace new challenges with enthusiasm and creativity.',
                            buttonText: 'Read More',
                            onPressed: () {
                              MyAlertDialog.showSnackbar(
                                  context, 'Vision details');
                            },
                          ),
                        ),
                        const SizedBox(width: 16), // Spacer
                        // Goal
                        Expanded(
                          child: MissionVisionGoalCard(
                            imagePath: 'assets/images/learning.jpg',
                            title: 'Our Goal',
                            description:
                                'Our goal is to create a nurturing and stimulating environment where every child feels valued and empowered to explore their full potential. We aim to foster a love for learning that extends beyond the classroom, encouraging curiosity, creativity, and critical thinking from the earliest years.',
                            buttonText: 'Read More',
                            onPressed: () {
                              // Navigate to Goal details
                              MyAlertDialog.showSnackbar(
                                  context, 'Goal details');
                            },
                          ),
                        ),
                      ],
                    ),
                  );
}

  void _showRegisterDialog(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController genderController = TextEditingController();

    final TextEditingController parentNameController = TextEditingController();
    final TextEditingController parentEmailController = TextEditingController();
    final TextEditingController parentPhoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OnlineAdmission(formKey: formKey, firstNameController: firstNameController, lastNameController: lastNameController, ageController: ageController, genderController: genderController, parentNameController: parentNameController, parentEmailController: parentEmailController, parentPhoneController: parentPhoneController, passwordController: passwordController, context: context);
      },
    );
  }
}
