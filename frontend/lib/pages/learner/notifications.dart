import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/api_utils.dart';
import '../../components/widgets/process_dialog.dart';
import 'package:intl/intl.dart';

// Define a class to handle notification data
class NotificationItem {
  final String message;
  final String category;
  final DateTime createdAt;

  NotificationItem({
    required this.message,
    required this.category,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      message: json['message'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Notifications extends StatefulWidget {
  final String token;
  final String admissionNumber;
  
  const Notifications({
    super.key, 
    required this.token, 
    required this.admissionNumber
  });

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<NotificationItem>? learnerNotifications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pullLearnerNotifications();
    });
  }

  void _pullLearnerNotifications() async {
    final notifications = await fetchNotifications();
    if (mounted) {
      setState(() {
        learnerNotifications = notifications;
      });
    }
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      ProcessDialog.show(
        context: context,
        title: 'Fetching Notifications',
        text: 'Please wait...'
      );

      final response = await http.post(
        Uri.parse("${ApiUtils.baseUrl}/learner/notifications"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'admission_number': widget.admissionNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Fetched notifications $data');
        
        if (data['status'] == 'success' && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => NotificationItem.fromJson(item))
              .toList();
        }
        return [];
      } else {
        log('Failed to fetch notifications. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching notifications: $e');
      return [];
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within last week - show day name
      return DateFormat('EEEE').format(dateTime);
    } else {
      // Older - show date
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildNotificationsSection();
  }

  Widget _buildNotificationsSection() {
    if (learnerNotifications == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (learnerNotifications!.isEmpty) {
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: learnerNotifications!.length,
      itemBuilder: (context, index) {
        final notification = learnerNotifications![index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _getCategoryIcon(notification.category),
            title: Text(
              notification.message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, 
                      vertical: 4
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(notification.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      notification.category.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getCategoryColor(notification.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'fee_defaulters':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.account_balance_wallet, color: Colors.red),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(CupertinoIcons.bell_fill, color: Colors.blue),
        );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'fee_defaulters':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}