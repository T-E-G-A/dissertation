// mobile_utils.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:developer';

// ignore: avoid_classes_with_only_static_members
class PlatformSpecificImplementation {
  static Future<void> downloadFile(List<int> bytes, String filename, String fileType) async {
   // Implementation specific to Android or iOS goes here
    log('-----------------------------------------------------------------');
    log('Platform: ${Platform.operatingSystem}');
    log('Downloading file...');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path).then((value) {
      log('File saved successfully');
    }).catchError((error) {
      log('Error opening file: $error');
    });
  }

  static void initializeBackButtonHandler(BuildContext context) {}
}
