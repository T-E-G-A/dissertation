import 'dart:async';
import 'dart:developer';
import 'dart:html' as html;
import 'dart:io';
import 'package:flutter/material.dart';

class PlatformSpecificImplementation {
  static Future<void> downloadFile(
      List<int> bytes, String filename, String fileType) async {
    log("Downloading file in web...");

    final blob = html.Blob([bytes], fileType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    // Open the file in a new tab
    html.window.open(url, '_blank');

    html.Url.revokeObjectUrl(url);
  }

  static void initializeBackButtonHandler(BuildContext context) {
    if (html.window.history.state == null) {
      html.window.history.pushState({}, '', html.window.location.href);
    }

    html.window.onPopState.listen((event) async {
      event.preventDefault();
      bool shouldExit = await _showExitConfirmationDialog(context);
      if (shouldExit) {
        // Perform logout logic here
        html.window.location.href = '/';
      } else {
        // Push a dummy state to prevent actual navigation
        html.window.history.pushState({}, '', html.window.location.href);
      }
    });
  }

  static Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Web Exit Confirmation'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
