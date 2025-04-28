import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';
import '../../components/widgets/process_dialog.dart';
import 'package:intl/intl.dart';

import 'dart:developer';

class Fees extends StatefulWidget {
  final String token;
  final String admissionNumber;
  final String username;

  const Fees({
    super.key, 
    required this.token, 
    required this.admissionNumber, 
    required this.username
  });

  @override
  State<Fees> createState() => _FeesState();
}

class _FeesState extends State<Fees> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, double>? feeInformation;
  final TextEditingController _amountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pullFeeInformation();
    });
  }

  Future<void> _pullFeeInformation() async {
    try {
      final fees = await fetchFeeInformation();
      if (mounted) {
        setState(() {
        log("Fee information: $fees");
          feeInformation = fees;
        });
      }
    } catch (e) {
      if (mounted) {
        MyAlertDialog.showSnackbar(
          context, 
          'Failed to fetch fee information: $e',
          isSuccess: false
        );
      }
    }
  }

  Future<Map<String, double>> fetchFeeInformation() async {
    ProcessDialog.show(
      context: context, 
      title: 'Fetching Fees', 
      text: 'Please wait...'
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/learner/fees"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success' && data['data'] != null) {
          final feeData = data['data'];
          return {
            'total_amount': double.parse(feeData['total_amount'].toString()),
            'paid_amount': double.parse(feeData['paid_amount'].toString()),
            'pending_amount': double.parse(feeData['pending_amount'].toString()),
          };
        }
      }
      throw Exception('Failed to fetch fee information');
    } catch (e) {
      throw Exception('Error fetching fee information: $e');
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _payFee(double amount) async {
    if (amount <= 0) {
      MyAlertDialog.showSnackbar(
        context, 
        "Please enter a valid amount",
        isSuccess: false
      );
      return;
    }

    final remainingBalance = feeInformation!['total_amount']! - 
                           feeInformation!['paid_amount']! - 
                           feeInformation!['pending_amount']!;

    if (amount > remainingBalance) {
      MyAlertDialog.showSnackbar(
        context, 
        "Amount exceeds remaining balance of ${currencyFormat.format(remainingBalance)}",
        isSuccess: false
      );
      return;
    }

    try {
      await postFeePayment(amount);
      await _pullFeeInformation();
      _amountController.clear();
      if (mounted) {
        MyAlertDialog.showSnackbar(
          context, 
          "Payment submitted successfully! Awaiting approval.",
          isSuccess: true
        );
      }
    } catch (e) {
      if (mounted) {
        MyAlertDialog.showSnackbar(
          context, 
          "Failed to process payment: $e",
          isSuccess: false
        );
      }
    }
  }
  
  Future<void> postFeePayment(double amount) async {
    ProcessDialog.show(
      context: context, 
      title: 'Processing Payment', 
      text: 'Please wait...'
    );

    try {
      final response = await http.post(
        Uri.parse("${ApiUtils.baseUrl}/learner/pay-fees"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Payment failed. Please try again.');
      }

      final data = jsonDecode(response.body);
      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Payment failed');
      }
    } catch (e) {
      throw Exception('Error processing payment: $e');
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: feeInformation == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeeOverview(),
                    const SizedBox(height: 24),
                    _buildPaymentSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeeOverview() {
    final remainingBalance = feeInformation!['total_amount']! - 
                           feeInformation!['paid_amount']! - 
                           feeInformation!['pending_amount']!;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade700,
              Colors.grey.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Overview',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(feeInformation!['paid_amount']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeeInfoColumn(
                    'Paid',
                    feeInformation!['paid_amount']!,
                    Colors.green.shade300,
                  ),
                  _buildFeeInfoColumn(
                    'Pending',
                    feeInformation!['pending_amount']!,
                    Colors.orange.shade300,
                  ),
                  _buildFeeInfoColumn(
                    'Remaining',
                    remainingBalance,
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalAmount = feeInformation!['total_amount']!;
    final paidAmount = feeInformation!['paid_amount']!;
    final pendingAmount = feeInformation!['pending_amount']!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Row(
                children: [
                  Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width * 
                          (paidAmount / totalAmount) * 0.8,
                    color: Colors.green.shade300,
                  ),
                  Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width * 
                          (pendingAmount / totalAmount) * 0.8,
                    color: Colors.orange.shade300,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${((paidAmount + pendingAmount) / totalAmount * 100).toStringAsFixed(1)}% of total fees',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeInfoColumn(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Make a Payment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: 'Enter amount to pay',
                      prefixIcon: const Icon(Icons.payments_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.blue.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      if (amount < 100) {
                        return 'Minimum payment amount is ₦100';
                      }
                      final remainingBalance = feeInformation!['total_amount']! - 
                                           feeInformation!['paid_amount']! - 
                                           feeInformation!['pending_amount']!;
                      if (amount > remainingBalance) {
                        return 'Amount exceeds remaining balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentInfo(),
                  const SizedBox(height: 24),
                  _buildPaymentButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Student', widget.username),
          _buildInfoRow('Admission', widget.admissionNumber),
          _buildInfoRow('Date', DateFormat('MMM dd, yyyy').format(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final amount = double.parse(_amountController.text);
            _payFee(amount);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Pay Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}