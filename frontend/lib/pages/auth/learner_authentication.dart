import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';

import 'package:http/http.dart' as http;

class LearnerLoginDialog extends StatefulWidget {
  const LearnerLoginDialog({super.key});

  @override
  State<LearnerLoginDialog> createState() => _LearnerLoginDialogState();
}

class _LearnerLoginDialogState extends State<LearnerLoginDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  ValueNotifier<Map<String, String>> serverMessageNotifier = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _passwordController.text = 'password';
    _usernameController.text = 'LNR/0001/2025';
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Do not proceed if the form is invalid
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mock authentication logic
      // fetch login information from server using post request
      final response = await http.post(
        Uri.parse("${ApiUtils.baseUrl}/learner/login"),
        body: jsonEncode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Navigator.of(context).pop(); // Close the dialog
          MyAlertDialog.showSnackbar(context, "Learner Login successful");
          log(data.toString());
          // Save the token and admission number to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("admissionNumber", data['admissionNumber']);
          await prefs.setString("token", "learner;${data['token']}");
          await prefs.setString("username", data['username']);
          if (mounted) {
            Navigator.of(context).pop(); // Close the dialog
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GoRouter.of(context).go('/learner-dashboard', extra: true);
            });
          }
        } else {
          log(data.toString());
          MyAlertDialog.showSnackbar(
              context, "Invalid credentials: ${response.body}",
              isSuccess: false);
        }
      } else {
        log(response.body);
        MyAlertDialog.showSnackbar(
            context, "An error occurred: ${response.body}",
            isSuccess: false);
      }
      serverMessageNotifier.value = Map<String, String>.from(jsonDecode(response.body));
      serverMessageNotifier.value["status"]=response.statusCode == 200 ? "success" : "error";
      log(serverMessageNotifier.value.toString());
    } catch (e) {
      log(e.toString());
      if (mounted) {
        MyAlertDialog.showSnackbar(context, "An error occurred: $e",
            isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        "Learner Login",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add a success message or error message from server here : server_message
              ValueListenableBuilder<Map<String, String>>(
                  valueListenable: serverMessageNotifier,
                  builder: (context, serverMessage, child) {
                    return serverMessage.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: serverMessage['status'] == "error"
                                  ? Colors.red[100]
                                  : Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  serverMessage['status'] == "error"
                                      ? Icons.error_outline
                                      : Icons.check_circle_outline,
                                  color: serverMessage['status'] == "error"
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    serverMessage['message']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink();
                  }),

              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your username";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
