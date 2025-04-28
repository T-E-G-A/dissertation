import 'dart:convert';
import 'dart:developer';
import 'dart:async' show TimeoutException;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:http/http.dart' as http;

import '../../components/widgets/alert_dialog.dart';
import '../../responsiveness/screen_type.dart';
import '../../api/api_utils.dart';

class Attendance extends StatefulWidget {
  final String token;
  final String staffNumber;
  const Attendance({super.key, required this.token, required this.staffNumber});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  List<Map<String, dynamic>> learners = [];
  String selectedWeek = "Week 1";
  final List<String> weeks = List.generate(10, (index) => "Week ${index + 1}");
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendanceData();
    });
  }

  void _fetchAttendanceData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Fetching Attendance Data',
      hideValue: true,
      closeWithDelay: 50,
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/admin/attendance?week=${Uri.encodeComponent(selectedWeek)}"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log(data.toString());
        if (data['status'] == 'success') {
          setState(() {
            learners = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          MyAlertDialog.showSnackbar(
            context,
            'Error: ${data['message'] ?? 'Failed to fetch attendance data'}',
            isSuccess: false,
          );
        }
      } else {
        MyAlertDialog.showSnackbar(
          context,
          'Error fetching attendance data',
          isSuccess: false,
        );
      }
    } catch (e) {
      MyAlertDialog.showSnackbar(
        context,
        'An error occurred: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      pd.close();
      setState(() => _isLoading = false);
    }
  }

  void _pushAttendanceData() async {
    if (_isLoading) return;

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Pushing Attendance Data...',
      hideValue: true,
      closeWithDelay: 50,
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.post(
        Uri.parse("${ApiUtils.baseUrl}/admin/attendance"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'week': selectedWeek,
          'attendance': learners,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          MyAlertDialog.showSnackbar(context, data['message']);
        } else {
          throw Exception(data['message'] ?? 'Failed to push attendance data');
        }
      } else {
        throw Exception('Failed to push attendance data');
      }
    } catch (e) {
      MyAlertDialog.showSnackbar(
        context,
        'An error occurred: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      pd.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Attendance'),
        trailing: GestureDetector(
          onTap: _isLoading ? null : _fetchAttendanceData,
          child: Icon(
            CupertinoIcons.refresh,
            color: _isLoading ? CupertinoColors.inactiveGray : null,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: width * 0.5,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedWeek,
                  onChanged: (value) {
                    setState(() {
                      selectedWeek = value!;
                      _fetchAttendanceData();
                    });
                  },
                  items: weeks.map((week) {
                    return DropdownMenuItem<String>(
                      value: week,
                      child: Text(week),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: learners.isEmpty
                  ? const Center(child: Text('No data available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: learners.length,
                      itemBuilder: (context, index) {
                        final learner = learners[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${learner['no']}. ${learner['name']} (${learner['admissionNumber']})",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: List.generate(5, (dayIndex) {
                                    return Column(
                                      children: [
                                        Text(
                                          ["Mon", "Tue", "Wed", "Thu", "Fri"][dayIndex],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Checkbox(
                                          value: learner['attendance'][dayIndex],
                                          onChanged: (value) {
                                            setState(() {
                                              learner['attendance'][dayIndex] = value!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload_sharp, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  backgroundColor: Colors.blue,
                ),
                onPressed: learners.isEmpty ? null : _pushAttendanceData,
                label: const Text("Upload", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}