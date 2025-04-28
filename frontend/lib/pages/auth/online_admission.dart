import 'dart:developer';

import 'package:flutter/material.dart';
import '../../api/api_utils.dart';
import 'package:flutter/services.dart';
import '../../components/widgets/alert_dialog.dart';
import '../../responsiveness/screen_type.dart';

import 'package:http/http.dart' as http;

class OnlineAdmission extends StatefulWidget {
  const OnlineAdmission({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.ageController,
    required this.genderController,
    required this.parentNameController,
    required this.parentEmailController,
    required this.parentPhoneController,
    required this.passwordController,
    required this.context,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController ageController;
  final TextEditingController genderController;
  final TextEditingController parentNameController;
  final TextEditingController parentEmailController;
  final TextEditingController parentPhoneController;
  final TextEditingController passwordController;
  final BuildContext context;

  @override
  State<OnlineAdmission> createState() => _OnlineAdmissionState();
}

class _OnlineAdmissionState extends State<OnlineAdmission> {
  bool obscurePassword = false;
  bool _isLoading = false;

  void submitAdmissionForm() async {
    if (widget.formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      // Show a dialog while processing
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Submitting..."),
              ],
            ),
          );
        },
      );

      // Close the dialog
      Navigator.of(context).pop();

      // Uncomment and implement the network request
      try {
        final response = await http.post(
          Uri.parse("${ApiUtils.baseUrl}/learner/register"),
          body: {
            "firstName": widget.firstNameController.text,
            "lastName": widget.lastNameController.text,
            "age": widget.ageController.text,
            "gender": widget.genderController.text,
            "parentName": widget.parentNameController.text,
            "parentEmail": widget.parentEmailController.text,
            "parentPhone": widget.parentPhoneController.text,
            "password": widget.passwordController.text,
          },
        );

        // Handle the response
        if (response.statusCode == 200) {
          MyAlertDialog.showAlert(
            context,
            "Your admission request is under approval. When approved, you will be able to log in using your email and password. Please be patient or come back later.",
            exitOnComplete: true,
          );
          final data = (response.body);
          log(data);
        } else {
          log(response.body);
          MyAlertDialog.showSnackbar(
            context,
            "Failed to submit admission request. Please try again later.",
            isSuccess: false,
          );
        }
      } catch (error) {
        log(error.toString());
        if (mounted) {
          MyAlertDialog.showSnackbar(
            context,
            "Failed to submit admission request. Please try again later.",
            isSuccess: false,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Screens.getType(context) == ScreenTypes.mobile;
    final isTablet = Screens.getType(context) == ScreenTypes.tablet;
    final width = isMobile
        ? MediaQuery.of(context).size.width * 0.9
        : MediaQuery.of(context).size.width * 0.5;
    final height = MediaQuery.of(context).size.height;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        "Learner Registration",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: isTablet ? width * 0.6 : width * 0.33,
                    child: TextFormField(
                      controller: widget.firstNameController,
                      decoration: InputDecoration(
                        labelText: "First Name",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter the first name";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: isTablet ? width * 0.6 : width * 0.33,
                    child: TextFormField(
                      controller: widget.lastNameController,
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter the last name";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.ageController,
                      decoration: InputDecoration(
                        labelText: "Age",
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter the age";
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return "Please enter a valid age";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: width * 0.43,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Gender",
                        prefixIcon: const Icon(Icons.transgender),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ["Male", "Female"].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        widget.genderController.text = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a gender";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.parentNameController,
                      decoration: InputDecoration(
                        labelText: "Parent Name",
                        prefixIcon: const Icon(Icons.person_3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter the parent name";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.parentEmailController,
                      decoration: InputDecoration(
                        labelText: "Parent Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter the parent email";
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: widget.parentPhoneController,
                      decoration: InputDecoration(
                        labelText: "Parent Phone",
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // focusedBorder: const OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(Radius.circular(5)),
                        //   borderSide: BorderSide(color: primaryTheme),
                        // ),
                        // enabledBorder: const OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(Radius.circular(5)),
                        //   borderSide: BorderSide(color: primaryColor),
                        // ),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                            10), // Custom formatter to prevent leading zeros
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter the parent phone";
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return "Please enter a valid 10-digit phone number";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.passwordController,
                      decoration: InputDecoration(
                        labelText: "Portal Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            obscurePassword = !obscurePassword;
                            (context as Element).markNeedsBuild();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      obscureText: obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a password";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters long";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007377),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: submitAdmissionForm,
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
