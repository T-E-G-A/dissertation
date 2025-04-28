import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/auth/admin_authentication.dart';
import 'pages/auth/learner_authentication.dart';
import 'pages/admin/dashboard.dart';
import 'pages/learner/dashboard.dart';
import 'homepage.dart';
import 'pages/settings_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Homepage(),
    ),
    // goto settings
    GoRoute(
      path: '/settings',
      builder: (context, state) {
        log('/settings'); // Log the route for debugging purposes

        return const SettingsPage();
      },
    ),
    // add to goto admin dashboard
    GoRoute(
      path: '/admin-login',
      builder: (context, state) {
        log('/admin-login'); // Log the route for debugging purposes

        return const AdminLoginDialog();
        // FutureBuilder<bool>(
        //   future: _isAuthenticated(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const CircularProgressIndicator();
        //     } else if (snapshot.hasData && snapshot.data!) {
        //       return const AdminDashboard();
        //     } else {
        //       WidgetsBinding.instance.addPostFrameCallback((_) {
        //         showDialog(
        //           context: context,
        //           builder: (context) => const AdminLoginDialog(),
        //         );
        //       });
        //       return const Homepage();
        //     }
        //   },
        // );
      },
    ),
    GoRoute(
      path: '/learner-login',
      builder: (context, state) {
        log('/learner-login'); // Log the route for debugging purposes

        return const LearnerLoginDialog();
        // FutureBuilder<bool>(
        //   future: _isAuthenticated(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const CircularProgressIndicator();
        //     } else if (snapshot.hasData && snapshot.data!) {
        //       return const LearnerDashboard();
        //     } else {
        //       WidgetsBinding.instance.addPostFrameCallback((_) {
        //         showDialog(
        //           context: context,
        //           builder: (context) => const LearnerLoginDialog(),
        //         ).whenComplete(() {
        //           GoRouter.of(context).go('/');
        //           log('Dialog closed');
        //         });
        //       });
        //       return const Homepage();
        //     }
        //   },
        // );
      },
    ),
    // Secure route for Admin Dashboard
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) {
        log('/admin-dashboard : ${state.extra}'); // Log the route for debugging purposes
        if (state.extra != null) {
          return const AdminDashboard();
        } else {
          return FutureBuilder<bool>(
            future: _isAuthenticated('admin'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData && snapshot.data!) {
                return const AdminDashboard();
              } else {
                log("Admin : Not logged in");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    builder: (context) => const AdminLoginDialog(),
                  ).whenComplete(() {
                    // GoRouter.of(context).go('/');
                    log('Dialog closed');
                  });
                });
                return const Homepage();
              }
            },
          );
        }
      },
    ),
    GoRoute(
      path: '/learner-dashboard',
      builder: (context, state) {
        log('/learner-dashboard : ${state.extra}');
        if (state.extra != null) {
          return const LearnerDashboard();
        } else {
          return FutureBuilder<bool>(
            future: _isAuthenticated('learner'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData && snapshot.data!) {
                return const LearnerDashboard();
              } else {
                log("Learner : Not logged in");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    builder: (context) => const LearnerLoginDialog(),
                  );
                });
                return const Homepage();
              }
            },
          );
        }
      },
    ),
  ],
);

Future<bool> _isAuthenticated(String type) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");
  final isAuth =
      prefs.containsKey("token") && token != null && token.startsWith(type);
  log('isAuthenticated: $isAuth');
  return isAuth;
}
