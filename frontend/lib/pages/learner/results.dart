// results.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'shared/platform_helpers.dart';

import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';
import '../../components/widgets/process_dialog.dart';
import '../../theme/themes.dart';
import 'dart:developer';

// Conditional imports
class Results extends StatefulWidget {
  final String token;
  final String admissionNumber;
  const Results(
      {super.key, required this.token, required this.admissionNumber});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  Map<String, dynamic>? learnerResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pullLearnerResults();
    });
  }

  void _pullLearnerResults() async {
    final results = await fetchResults();
    setState(() {
      learnerResult = results;
    });
  }

  Future<Map<String, dynamic>> fetchResults() async {
    log('Starting to fetch results...');

    ProcessDialog.show(
      context: context,
      title: 'Fetching Results',
      text: 'Please wait...',
    );

    try {
      final response = await http.post(
        Uri.parse("${ApiUtils.baseUrl}/learner/results"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'admissionNumber': widget.admissionNumber}),
      );

      log('Results response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Navigator.of(context).pop(); // Dismiss ProcessDialog
          return data['data'];
        } else {
          throw Exception('Failed to fetch results: ${data['message']}');
        }
      } else {
        log('Failed to fetch results: ${response.reasonPhrase}');
        throw Exception('Failed to fetch results: ${response.reasonPhrase}');
      }
    } catch (e) {
      log('Error fetching results: $e');
      if (mounted) {
        MyAlertDialog.showSnackbar(context, 'Failed to fetch results: $e',
            isSuccess: false);
      }
      return {};
    } finally {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Dismiss ProcessDialog if still showing
      }
    }
  }

  void _downloadResults() async {
    try {
      final bytes = await generateReportCard(learnerResult!);
      final filename =
          '${learnerResult!['admissionNumber'].replaceAll('/', '-')}_${learnerResult!['name'].replaceAll(' ', '_')}_Results.pdf';
      const String fileType = 'application/pdf';

      if (kIsWeb) {
        PlatformSpecificImplementation.downloadFile(bytes, filename, fileType);
      } else {
        PlatformSpecificImplementation.downloadFile(bytes, filename, fileType);
      }
    } catch (e) {
      MyAlertDialog.showSnackbar(context, 'Failed to download PDF: $e',
          isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Results'),
        backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
      ),
      body: learnerResult == null
          ? const Center(child: CircularProgressIndicator())
          : _buildResultsSection(),
    );
  }

  Widget _buildResultsSection() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            learnerResult!['name'] ?? '',
                            style: customTextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Admission: ${learnerResult!['admissionNumber']}',
                            style: customTextStyle(
                                fontSize: 18,
                                color: Colors.white.withAlpha(200)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Colors.white54),
                  Text(
                    'Results:',
                    style: customTextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Maths: ${learnerResult!['maths']}',
                      style: customTextStyle(color: Colors.white)),
                  Text('English: ${learnerResult!['english']}',
                      style: customTextStyle(color: Colors.white)),
                  Text('Science: ${learnerResult!['science']}',
                      style: customTextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                      onPressed: _downloadResults,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
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
  }

  Future<Uint8List> generateReportCard(Map<String, dynamic> results) async {
    final pdf = pw.Document();

    // Define colors that match the UI
    final deepPurple = PdfColor.fromHex('#673AB7');
    final purpleAccent = PdfColor.fromHex('#E040FB');

    pdf.addPage(
      pw.Page(
        // pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [deepPurple, purpleAccent],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ACADEMIC REPORT CARD',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Generated on: ${DateTime.now().toString().split(' ')[0]}',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Student Information
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 20),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.white, width: 0.5),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Student Name:',
                              style: const pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey100,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              results['name'],
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                        pw.Spacer(),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Admission Number:',
                              style: const pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey100,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              results['admissionNumber'],
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Grades Section
                  pw.SizedBox(height: 30),
                  pw.Text(
                    'SUBJECT GRADES',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  _buildGradesTable(results),

                  // Summary Section
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.deepPurple,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Performance Summary',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Average Score: ${_calculateAverage(results)}%',
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildGradesTable(Map<String, dynamic> results) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.white, width: 0.5),
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.purple100),
          children: [
            _buildTableCell('Subject', isHeader: true),
            _buildTableCell('Score', isHeader: true),
            _buildTableCell('Grade', isHeader: true),
          ],
        ),
        // Subject Rows
        _buildSubjectRow('Mathematics', results['maths']),
        _buildSubjectRow('English', results['english']),
        _buildSubjectRow('Science', results['science']),
      ],
    );
  }

  pw.TableRow _buildSubjectRow(String subject, int score) {
    return pw.TableRow(
      children: [
        _buildTableCell(subject),
        _buildTableCell('$score%'),
        _buildTableCell(_calculateGrade(score)),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 14 : 12,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  String _calculateGrade(int score) {
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C';
    if (score >= 40) return 'D';
    return 'F';
  }

  double _calculateAverage(Map<String, dynamic> results) {
    double sum = results['maths'] + results['english'] + results['science'];
    return (sum / 3).roundToDouble();
  }
}
