import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';

class Notifications extends StatefulWidget {
  final String token;
  final String staffNumber;
  const Notifications(
      {super.key, required this.token, required this.staffNumber});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Map<String, dynamic>> students = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _feeThresholdController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStudentsData();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _feeThresholdController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudentsData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Fetching Students...',
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/admin/students"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      ).timeout(const Duration(seconds: 15));

      log('Students fetch response: {response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(
              () => students = List<Map<String, dynamic>>.from(data['data']));
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch students');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching students: $e');
      MyAlertDialog.showSnackbar(
        context,
        'Failed to fetch students: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      pd.close();
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendNotificationToStudent(
      String admissionNumber, String message) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Sending Notification...',
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http
          .post(
            Uri.parse("${ApiUtils.baseUrl}/admin/notifications/send"),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'admission_number': admissionNumber,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('Send notification response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          MyAlertDialog.showSnackbar(context, 'Notification sent successfully');
        } else {
          throw Exception(data['message'] ?? 'Failed to send notification');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('Error sending notification: $e');
      MyAlertDialog.showSnackbar(
        context,
        'Failed to send notification: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      pd.close();
    }
  }

  Future<void> _sendBulkNotification(String category) async {
    if (!_formKey.currentState!.validate()) return;

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Sending Bulk Notifications...',
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http
          .post(
            Uri.parse("${ApiUtils.baseUrl}/admin/notifications/send-bulk"),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'category': category,
              'message': _messageController.text,
              'fee_threshold': category == 'fee_defaulters'
                  ? int.parse(_feeThresholdController.text)
                  : null,
            }),
          )
          .timeout(const Duration(seconds: 30));

      log('Bulk notification response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          MyAlertDialog.showSnackbar(
            context,
            'Bulk notifications sent successfully to ${data['data']['recipients_count']} students',
          );
          Navigator.pop(context); // Close the bottom sheet
        } else {
          throw Exception(
              data['message'] ?? 'Failed to send bulk notifications');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('Error sending bulk notifications: $e');
      MyAlertDialog.showSnackbar(
        context,
        'Failed to send bulk notifications: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      pd.close();
    }
  }

  Future<void> _showMessageDialog(String admission, String studentName) async {
  final messageController = TextEditingController(text: "Please clear your fee balance");
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  return showCupertinoDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => CupertinoAlertDialog(
        title: Text(
          'Message to $studentName',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: CupertinoTextField(
                controller: messageController,
                placeholder: 'Type your message here...',
                maxLines: 4,
                minLines: 3,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                style: const TextStyle(fontSize: 15),
                enabled: !isLoading,
              ),
            ),
            if (messageController.text.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Message cannot be empty',
                  style: TextStyle(
                    color: Colors.red[200],
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: isLoading 
                ? null 
                : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: isLoading 
                ? null 
                : () async {
                    if (messageController.text.trim().isNotEmpty) {
                      setState(() => isLoading = true);
                      
                      try {
                        await _sendNotificationToStudent(
                          admission, 
                          messageController.text.trim()
                        );
                        Navigator.pop(context);
                        MyAlertDialog.showSnackbar(
                          context, 
                          'Message sent successfully',
                          isSuccess: true
                        );
                      } catch (e) {
                        setState(() => isLoading = false);
                        MyAlertDialog.showSnackbar(
                          context,
                          'Failed to send message: ${e.toString()}',
                          isSuccess: false
                        );
                      }
                    }
                  },
            child: Text(
              isLoading ? 'Sending...' : 'Send',
              style: TextStyle(
                fontWeight: isLoading 
                    ? FontWeight.normal 
                    : FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Notifications'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _fetchStudentsData,
              child: Icon(
                CupertinoIcons.refresh,
                color: _isLoading ? CupertinoColors.inactiveGray : null,
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () => _showBulkMessageSheet(context),
              child: const Icon(CupertinoIcons.mail_solid),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : students.isEmpty
                ? const Center(child: Text('No students available'))
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: CupertinoColors.activeBlue,
                            radius: 25,
                            child: Text(
                              student['name'][0].toUpperCase(),
                              style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            student['name'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Admission: ${student['admissionNumber']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    'Fee Balance: ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '₦ ${student['fee_balance']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: double.parse(student['fee_balance']
                                                  .toString()) >
                                              0
                                          ? CupertinoColors.destructiveRed
                                          : CupertinoColors.activeGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.chat_bubble_2_fill,
                              color: CupertinoColors.activeBlue,
                              size: 28,
                            ),
                            onPressed: () => _showMessageDialog(
                                student['admissionNumber'], student['name']),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _showBulkMessageSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        bool isLoading = false;

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.99,
            minChildSize: 0.7,
            maxChildSize: 0.99,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar with better visibility
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      
                      // Header with icon
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_rounded,
                            color: Color(0xFF007377),
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Bulk Messaging',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007377),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Message input with character count
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        maxLength: 500,
                        enabled: !isLoading,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: "Message Content",
                          hintText: "Enter your message here...",
                          alignLabelWithHint: true,
                          prefixIcon: const Icon(Icons.message_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF007377),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a message";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Fee threshold input with currency symbol
                      TextFormField(
                        controller: _feeThresholdController,
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: "Fee Threshold (KES)",
                          hintText: "Enter minimum fee balance",
                          prefixIcon: const Icon(Icons.payments_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF007377),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return "Please enter a valid amount";
                            }
                            if (int.parse(value) <= 0) {
                              return "Amount must be greater than 0";
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Action buttons with loading state
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007377),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading 
                            ? null 
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);
                                  Navigator.pop(context);
                                  _sendBulkNotification('all');
                                }
                              },
                        icon: isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white),
                        label: Text(
                          isLoading ? 'Sending...' : 'Message All Students',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007377),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading 
                            ? null 
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  if (_feeThresholdController.text.trim().isEmpty) {
                                    MyAlertDialog.showSnackbar(
                                      context, 
                                      "Please enter a fee threshold"
                                    );
                                    return;
                                  }
                                  setState(() => isLoading = true);
                                  Navigator.pop(context);
                                  _sendBulkNotification('fee_defaulters');
                                }
                              },
                        icon: isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                              ),
                        label: Text(
                          isLoading ? 'Sending...' : 'Message Fee Defaulters',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
}
