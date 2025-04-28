import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:http/http.dart' as http;

import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';

class Results extends StatefulWidget {
  final String token;
  final String staffNumber;
  const Results({super.key, required this.token, required this.staffNumber});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  List<Map<String, dynamic>> students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchResultsData();
    });
  }

  void _fetchResultsData() async {
    if (_isLoading) return;
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Fetching Results Data',
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/admin/results"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Results: $data");
        setState(
            () => students = List<Map<String, dynamic>>.from(data['data']));
      } else {
        MyAlertDialog.showSnackbar(context, "Failed to fetch results",
            isSuccess: false);
      }
    } catch (e) {
      MyAlertDialog.showSnackbar(context, "Error: ${e.toString()}",
          isSuccess: false);
    } finally {
      pd.close();
      setState(() => _isLoading = false);
    }
  }

  void _resetResults() async {
    bool confirmReset = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text(
            'Are you sure you want to reset results? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmReset) {
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(
        max: 50,
        msg: 'Resetting Results Data...',
        progressType: ProgressType.indeterminate,
      );

      try {
        final response = await http.post(
          Uri.parse("${ApiUtils.baseUrl}/admin/results/reset"),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );

        if (response.statusCode == 200) {
          MyAlertDialog.showSnackbar(context, "Results reset successfully");
          _fetchResultsData(); // Refresh data
        } else {
          MyAlertDialog.showSnackbar(context, "Failed to reset results",
              isSuccess: false);
        }
      } catch (e) {
        MyAlertDialog.showSnackbar(context, "Error: ${e.toString()}",
            isSuccess: false);
      } finally {
        pd.close();
      }
    }
  }

  void _saveResults() async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Saving Results Data...',
      progressType: ProgressType.indeterminate,
    );

    try {
      // Filter out students with all-zero marks
      final filteredStudents = students.where((student) {
        return student['maths'] != 0 ||
            student['english'] != 0 ||
            student['science'] != 0;
      }).toList();

      final response = await http.post(
        Uri.parse("${ApiUtils.baseUrl}/admin/results/save"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'students': filteredStudents}),
      );

      if (response.statusCode == 200) {
        MyAlertDialog.showSnackbar(context, "Results saved successfully");
      } else {
        MyAlertDialog.showSnackbar(context, "Failed to save results",
            isSuccess: false);
      }
    } catch (e) {
      MyAlertDialog.showSnackbar(context, "Error: ${e.toString()}",
          isSuccess: false);
    } finally {
      pd.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Results dashboard'),
        trailing: GestureDetector(
          onTap: _isLoading ? null : _fetchResultsData,
          child: Icon(
            CupertinoIcons.refresh,
            color: _isLoading ? CupertinoColors.inactiveGray : null,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('SN')),
                    DataColumn(label: Text('Admission')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Maths')),
                    DataColumn(label: Text('English')),
                    DataColumn(label: Text('Science')),
                  ],
                  rows: students.map((student) {
                    return DataRow(cells: [
                      DataCell(Text(student['no'].toString())),
                      DataCell(Text(student['admissionNumber'])),
                      DataCell(Text(student['name'])),
                      DataCell(
                        TextFormField(
                          initialValue: student['maths'].toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            student['maths'] = int.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          initialValue: student['english'].toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            student['english'] = int.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          initialValue: student['science'].toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            student['science'] = int.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.restore, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 32),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: _resetResults,
                  label: const Text("Reset Results",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 32),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _saveResults,
                  label: const Text("Save Results",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
