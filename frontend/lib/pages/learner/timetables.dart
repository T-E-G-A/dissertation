import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oviasogie_school_mis/components/widgets/alert_dialog.dart';
import 'dart:convert';
import 'shared/platform_helpers.dart';
import '../../api/api_utils.dart';
import '../../components/widgets/process_dialog.dart';

class Timetables extends StatefulWidget {
  final String token;
  final String admissionNumber;
  const Timetables(
      {super.key, required this.token, required this.admissionNumber});

  @override
  State<Timetables> createState() => _TimetablesState();
}

class _TimetablesState extends State<Timetables> {
  List<Map<String, dynamic>> learnerTimetables = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pullLearnerTimetables();
      // Initialize back button handler for web
      PlatformSpecificImplementation.initializeBackButtonHandler(context);
    });
  }

  void _pullLearnerTimetables() async {
    setState(() => isLoading = true);
    try {
      final timetables = await fetchTimetables();
      setState(() => learnerTimetables = timetables);
    } catch (e) {
      log('Error fetching timetables: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading timetables: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchTimetables() async {
    ProcessDialog.show(
      context: context,
      title: 'Fetching Timetables',
      text: 'Please wait...',
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/learner/timetables"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      log('Timetables response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to load timetables');
    } catch (e) {
      log('Error in fetchTimetables: $e');
      rethrow;
    } finally {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss ProcessDialog
      }
    }
  }

  Future<void> _downloadTimetable(
      String downloadUrl, String filename, String fileType) async {
    ProcessDialog.show(
      context: context,
      title: 'Downloading File',
      text: 'Please wait...',
    );

    try {
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Use platform-specific implementation to handle the download
        await PlatformSpecificImplementation.downloadFile(
            response.bodyBytes, filename, fileType);

        if (mounted) {
          MyAlertDialog.showSnackbar(context, 'File downloaded successfully');
        }
      } else {
        log('Failed to download file: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to download file');
      }
    } catch (e) {
      log('Error downloading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    } finally {
      if (mounted) {
        Navigator.pop(context); // Dismiss ProcessDialog
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _pullLearnerTimetables,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : learnerTimetables.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No Timetables Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for updates',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _pullLearnerTimetables(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: learnerTimetables.length,
                    itemBuilder: (context, index) {
                      final timetable = learnerTimetables[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                const Icon(Icons.schedule, color: Colors.blue),
                          ),
                          title: Text(
                            timetable['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            timetable['description'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.download_rounded),
                            color: Colors.blue,
                            onPressed: () => _downloadTimetable(
                              timetable['download_url'],
                              timetable['name'],
                              timetable['file_type'],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
