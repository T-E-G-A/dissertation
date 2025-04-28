import 'dart:convert';
import 'dart:developer';
import 'dart:async' show TimeoutException;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:http/http.dart' as http;

import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';

class Admissions extends StatefulWidget {
  final String token;
  final String staffNumber;
  const Admissions({super.key, required this.token, required this.staffNumber});

  @override
  State<Admissions> createState() => _AdmissionsState();
}

class _AdmissionsState extends State<Admissions> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  final List<String> filters = ["Unapproved", "All"];
  String filter = "All";
  bool _isLoading = false;
  // Track modified students
  Set<String> modifiedStudents = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStudentData();
    });
  }

  void _fetchStudentData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Fetching Student Data',
      hideValue: true,
      closeWithDelay: 50,
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/admin/students"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          students =
              filteredStudents = List<Map<String, dynamic>>.from(data['data']);
          modifiedStudents.clear(); // Reset modified students on fresh fetch
        });
      } else {
        final errorData = jsonDecode(response.body);
        log(errorData.toString());
        MyAlertDialog.showSnackbar(context,
            'Error: ${errorData['message'] ?? 'Unknown error occurred'}',
            isSuccess: false);
      }
    } on TimeoutException catch (_) {
      log('Request timed out. Please try again.');
      MyAlertDialog.showSnackbar(
          context, 'Request timed out. Please try again.',
          isSuccess: false);
    } catch (e) {
      log(e.toString());
      MyAlertDialog.showSnackbar(context, 'An error occurred: ${e.toString()}',
          isSuccess: false);
    } finally {
      pd.close();
      setState(() => _isLoading = false);
    }
  }

  void filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        if (filter == "Unapproved") {
          return student['admitted'] == 0;
        }
        return true;
      }).toList();
    });
  }

  Future<void> _pushStudentData() async {
    if (modifiedStudents.isEmpty) {
      MyAlertDialog.showSnackbar(context, 'No changes to save',
          isSuccess: true);
      return;
    }

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Saving Changes...',
      hideValue: true,
      closeWithDelay: 50,
      progressType: ProgressType.indeterminate,
    );

    try {
      // Filter only modified students
      final modifiedStudentsList = students
          .where((student) =>
              modifiedStudents.contains(student['admissionNumber']))
          .toList();

      final response = await http
          .post(
            Uri.parse("${ApiUtils.baseUrl}/admin/approve-learner"),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "staffNumber": widget.staffNumber,
              "students": modifiedStudentsList,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final apiResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && apiResponse['status'] == 'success') {
        modifiedStudents
            .clear(); // Clear the modified set after successful save
        log(apiResponse.toString());
        MyAlertDialog.showSnackbar(context, apiResponse['message']);
        _fetchStudentData(); // Refresh the list
      } else {
      log('Failed to save changes: ${apiResponse['message']}');
        throw Exception(apiResponse['message'] ?? 'Failed to save changes');
      }
    } on TimeoutException catch (_) {
      log('Request timed out. Please try again.');
      MyAlertDialog.showSnackbar(
          context, 'Request timed out. Please try again.',
          isSuccess: false);
    } catch (e) {
      log(e.toString());
      MyAlertDialog.showSnackbar(context, 'Error: ${e.toString()}',
          isSuccess: false);
    } finally {
      pd.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        middle: Text(
            'Admissions ${modifiedStudents.isNotEmpty ? "(Unsaved Changes)" : ""}'),
        trailing: GestureDetector(
          onTap: _isLoading ? null : _fetchStudentData,
          child: Icon(
            CupertinoIcons.refresh,
            color: _isLoading ? CupertinoColors.inactiveGray : null,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.01),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: width * 0.5,
              child: DropdownButton<String>(
                isExpanded: true,
                value: filter,
                onChanged: (value) {
                  setState(() {
                    filter = value!;
                    filterStudents();
                  });
                },
                items: filters.map((filter) {
                  return DropdownMenuItem<String>(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('SN')),
                    DataColumn(label: Text('Admission')),
                    DataColumn(label: Text('First Name')),
                    DataColumn(label: Text('Last Name')),
                    DataColumn(label: Text('Age')),
                    DataColumn(label: Text('Gender')),
                    DataColumn(label: Text('Parent Email')),
                    DataColumn(label: Text('Parent Phone')),
                    DataColumn(label: Text('Approved')),
                  ],
                  rows: filteredStudents.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    var student = entry.value;
                    bool isModified =
                        modifiedStudents.contains(student['admissionNumber']);

                    return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (isModified) return Colors.yellow.withValues(alpha: 0.1);
                          return null;
                        }),
                        cells: [
                          DataCell(Text(index.toString())),
                          DataCell(Text(student['admissionNumber'])),
                          DataCell(Text(student['firstName'])),
                          DataCell(Text(student['lastName'])),
                          DataCell(Text(student['age'].toString())),
                          DataCell(Text(student['gender'])),
                          DataCell(Text(student['parentEmail'])),
                          DataCell(Text(student['parentPhone'])),
                          DataCell(Switch(
                            value: student['admitted'] == 1,
                            onChanged: (value) {
                              setState(() {
                                student['admitted'] = value ? 1 : 0;
                                modifiedStudents
                                    .add(student['admissionNumber']);
                              });
                            },
                          )),
                        ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          if (modifiedStudents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  backgroundColor: Colors.blue,
                ),
                onPressed: _pushStudentData,
                label: Text("Save Changes (${modifiedStudents.length})",
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
