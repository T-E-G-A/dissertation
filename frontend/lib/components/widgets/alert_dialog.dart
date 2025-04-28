import 'package:flutter/material.dart';
import 'package:oviasogie_school_mis/theme/colors.dart';

import '../../responsiveness/screen_type.dart';
import '../../theme/themes.dart';

class MyAlertDialog {
  static void showAlert(BuildContext context, String message,
      {bool isSuccess = true, bool exitOnComplete = false}) {
    IconData icon;
    Color iconColor;
    Color titleColor;
    final isMobile = Screens.getType(context) == ScreenTypes.mobile;
    final width = MediaQuery.of(context).size.width;

    if (isSuccess) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
      titleColor = Colors.green;
    } else {
      icon = Icons.warning;
      iconColor = Colors.red;
      titleColor = Colors.red;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                isSuccess ? 'Success' : 'Error',
                style: TextStyle(color: titleColor, fontFamily: primaryFont),
              ),
            ],
          ),
          content: SizedBox(
          width: isMobile ? width : 200,
            child: Text(
              message,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert dialog
                //exit from the payment checklist screen
                if (isSuccess && exitOnComplete) {
                  Navigator.pop(context); // Exit the current screen
                }
              },
              child: Text(
                'OK',
                style: customTextStyle(color: primaryTheme),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showSnackbar(BuildContext context, String message,
      {int seconds=4, bool isSuccess = true}) {
    Color bgColor;

    if (isSuccess) {
      bgColor = Colors.green;
    } else {
      bgColor = Colors.red;
    }
    var snackBar = SnackBar(
      content: SelectableText(
        message,
        style: const TextStyle(
          fontFamily: primaryFont,
          color: Colors.white,
        ),
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: seconds),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

// how to use

// for successfully msg
// MyAlertDialog.showAlert(context, 'your success message', isSuccess: true);

// for error msg
// MyAlertDialog.showAlert(context, 'your error message', isSuccess: false);

