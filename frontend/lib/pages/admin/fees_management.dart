import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oviasogie_school_mis/api/api_utils.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../components/widgets/alert_dialog.dart';

import '../../theme/themes.dart';

class FeesManagement extends StatefulWidget {
  final String token;
  final String staffNumber;
  const FeesManagement(
      {super.key, required this.token, required this.staffNumber});

  @override
  State<FeesManagement> createState() => _FeesManagementState();
}

class _FeesManagementState extends State<FeesManagement> {
  List<Map<String, dynamic>> students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFeesData();
    });
  }

  // Replace _fetchFeesData with:
  void _fetchFeesData() async {
    if (_isLoading) return;
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Fetching Fees Data',
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/admin/fees"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Fetched fees $data');
        setState(
            () => students = List<Map<String, dynamic>>.from(data['data']));
      } else {
        log(response.body);
        MyAlertDialog.showSnackbar(context, "Failed to fetch fees data",
            isSuccess: false);
      }
    } catch (e) {
      log(e.toString());
      MyAlertDialog.showSnackbar(context, "Error: ${e.toString()}",
          isSuccess: false);
    } finally {
      pd.close();
      setState(() => _isLoading = false);
    }
  }

  void _resetFees() async {
    bool confirmReset = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text(
            'Are you sure you want to reset fees? This action cannot be undone.'),
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
        msg: 'Resetting Fees Data...',
        progressType: ProgressType.indeterminate,
      );

      try {
        final response = await http.post(
          Uri.parse("${ApiUtils.baseUrl}/admin/fees/reset"),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );

        if (response.statusCode == 200) {
          MyAlertDialog.showSnackbar(context, "Fees reset successfully");
          _fetchFeesData(); // Refresh data
        } else {
          MyAlertDialog.showSnackbar(context, "Failed to reset fees",
              isSuccess: false);
        }
        log(response.body);
      } catch (e) {
        log(e.toString());
        MyAlertDialog.showSnackbar(context, "Error: ${e.toString()}",
            isSuccess: false);
      } finally {
        pd.close();
      }
    }
  }

  void _saveFees() async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Saving Fees Data...',
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.post(
        Uri.parse("${ApiUtils.baseUrl}/admin/fees/save"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'students': students}),
      );

      if (response.statusCode == 200) {
        MyAlertDialog.showSnackbar(context, "Fees saved successfully");
      } else {
        MyAlertDialog.showSnackbar(context, "Failed to save fees",
            isSuccess: false);
      }
      log(response.body);
    } catch (e) {
      log(e.toString());
      MyAlertDialog.showSnackbar(context, "Error: ${e.toString()}",
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
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        middle: const Text('Fees Dashboard'),
        trailing: GestureDetector(
          onTap: _isLoading ? null : _fetchFeesData,
          child: Icon(
            CupertinoIcons.refresh,
            color: _isLoading ? CupertinoColors.inactiveGray : null,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top:32.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('SN')),
                    DataColumn(label: Text('Admission')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Paid Fees')),
                    DataColumn(label: Text('Pending Fees')),
                    DataColumn(label: Text('Approve')),
                  ],
                  rows: students.map((student) {
                    return DataRow(cells: [
                      DataCell(Text(student['no'].toString())),
                      DataCell(Text(student['admissionNumber'])),
                      DataCell(Text(student['name'])),
                      DataCell(Text('₦${student['paid_amount']}')),
                      DataCell(Text('₦${student['pending_amount']}')),
                      DataCell(ElevatedButton(
                        onPressed: (num.tryParse("${student['pending_amount']}") ??
                                    0) >
                                0
                            ? () {
                                setState(() {
                                  student['paid_amount'] = (num.tryParse(
                                              "${student['paid_amount']}") ??
                                          0) +
                                      (num.tryParse("${student['pending_amount']}") ??
                                          0);
                                  student['pending_amount'] = 0;
                                  student['approved'] = true;
                                });
                              }
                            : null,
                        child: Text('Approve',
                            style: customTextStyle(
                                color: (num.tryParse("${student['pending_amount']}") ??
                                            0) >
                                        0
                                    ? Colors.teal
                                    : Colors.black38,
                                fontSize: 10)),
                      )),
                    ]);
                  }).toList(),
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
                    onPressed: _resetFees,
                    label: const Text("Reset Fees",
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: _saveFees,
                    label: const Text("Save Fees",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
