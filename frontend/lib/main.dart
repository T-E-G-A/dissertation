import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_utils.dart';
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    resetSharedPreferences();
    _loadTheme();
  }

// Load saved theme from SharedPreferences
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'system';
    setState(() {
      _themeMode = _themeFromString(themeString);
    });
  }

// Save theme to SharedPreferences
  void saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', themeMode.toString().split('.').last);
  }

  void resetSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await ApiUtils.loadIpAddress();
    await ApiUtils.loadSelectedServer();
    String selectedServer = ApiUtils.baseUrl;
    String selectedIp = ApiUtils.currentIp;

    prefs.clear();
    await ApiUtils.setIpAddress(selectedIp);
    await ApiUtils.setBaseUrl(selectedServer);
  }

// Convert string to ThemeMode
  ThemeMode _themeFromString(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

// Convert ThemeMode to string
  String themeToString(ThemeMode themeMode) {
    return themeMode.toString().split('.').last;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Oviasogie Pre School',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      routerConfig: router,
    );
  }
}
