import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api_utils.dart';
import '../../components/widgets/alert_dialog.dart';

class Timetables extends StatefulWidget {
  final String token;
  final String staffNumber;
  const Timetables({super.key, required this.token, required this.staffNumber});

  @override
  State<Timetables> createState() => _TimetablesState();
}

class _TimetablesState extends State<Timetables> {
  List<Map<String, dynamic>> timetables = [];
  bool _isLoading = false;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTimetablesData();
    });
  }

  void _fetchTimetablesData() async {
    if (_isLoading) return;
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Fetching Timetables...',
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.get(
        Uri.parse("${ApiUtils.baseUrl}/admin/timetables"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Timetables: $data");
        setState(
            () => timetables = List<Map<String, dynamic>>.from(data['data']));
      } else {
        log(response.body);
        MyAlertDialog.showSnackbar(context, "Failed to fetch timetables",
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

  void _uploadTimetable() async {
    // Create state variables for the upload dialog
    PlatformFile? selectedFile;
    final formKey = GlobalKey<FormState>();
    final TextEditingController descriptionController = TextEditingController();
    bool hasError = false;

    // Function to get file type icon
    IconData getFileIcon(String? extension) {
      switch (extension?.toLowerCase()) {
        case 'pdf':
          return Icons.picture_as_pdf;
        case 'doc':
        case 'docx':
          return Icons.description;
        case 'xls':
        case 'xlsx':
        case 'csv':
          return Icons.table_chart;
        default:
          return Icons.insert_drive_file;
      }
    }

    // Show the upload dialog
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Upload Timetable'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // File upload container with validation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: hasError && selectedFile == null
                              ? Colors.red
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          if (selectedFile == null) ...[
                            const Icon(Icons.cloud_upload,
                                size: 48, color: Colors.blue),
                            const SizedBox(height: 8),
                            const Text(
                                'Drag and drop a file here or click to upload'),
                          ] else ...[
                            Row(
                              children: [
                                Icon(getFileIcon(selectedFile?.extension),
                                    size: 36, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedFile!.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${(selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      selectedFile = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'pdf',
                                  'doc',
                                  'docx',
                                  'xls',
                                  'xlsx',
                                  'csv'
                                ],
                                allowMultiple: false,
                                withData: true,
                              );
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  selectedFile = result.files.first;
                                  hasError = false;
                                });
                                log('Selected file: ${selectedFile!.name}');
                              }
                            },
                            child: Text(selectedFile == null
                                ? 'Choose File'
                                : 'Change File'),
                          ),
                        ],
                      ),
                    ),
                    if (hasError && selectedFile == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Please select a file',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Description text field with validation
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter a description for the timetable',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      hasError = selectedFile == null;
                    });

                    if (formKey.currentState!.validate() &&
                        selectedFile != null) {
                      Navigator.pop(context);
                      _performUpload(selectedFile!, descriptionController.text);
                    }
                  },
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _performUpload(PlatformFile file, String description) async {
    // Validate file size (10MB limit)
    if (file.size > 10 * 1024 * 1024) {
      MyAlertDialog.showSnackbar(context, 'File size must be less than 10MB',
          isSuccess: false);
      return;
    }

    // Show progress dialog
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'Uploading Timetable...',
      progressType: ProgressType.valuable,
      valueFontSize: 12,
    );

    try {
      // Create form data
      FormData formData = FormData.fromMap({
        'file': kIsWeb
            ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
            : MultipartFile.fromFileSync(file.path!, filename: file.name),
        'description': description,
      });

      // Upload the file
      final response = await _dio.post(
        "${ApiUtils.baseUrl}/admin/timetables/upload",
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer ${widget.token}'},
        ),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toInt();
          pd.update(value: progress, msg: 'Uploading: $progress%');
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        MyAlertDialog.showSnackbar(context, 'Timetable uploaded successfully',
            isSuccess: true);
        _fetchTimetablesData(); // Refresh the list
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } on DioException catch (e) {
      log('Dio error: ${e.message}');
      MyAlertDialog.showSnackbar(context, 'Error: ${e.message}',
          isSuccess: false);
    } catch (e) {
      log('Upload error: ${e.toString()}');
      MyAlertDialog.showSnackbar(context, 'Error: ${e.toString()}',
          isSuccess: false);
    } finally {
      pd.close();
    }
  }

  void _deleteTimetable(int id) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 50,
      msg: 'Deleting Timetable...',
      progressType: ProgressType.indeterminate,
    );

    try {
      final response = await http.delete(
        Uri.parse("${ApiUtils.baseUrl}/admin/timetables/$id"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        log("Timetable deleted successfully $response");
        MyAlertDialog.showSnackbar(context, "Timetable deleted successfully");
        _fetchTimetablesData(); // Refresh data
      } else {
        log(response.body);
        MyAlertDialog.showSnackbar(context, "Failed to delete timetable",
            isSuccess: false);
      }
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Timetables Management'),
        trailing: GestureDetector(
          onTap: _isLoading ? null : _fetchTimetablesData,
          child: Icon(
            CupertinoIcons.refresh,
            color: _isLoading ? CupertinoColors.inactiveGray : null,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : timetables.isEmpty
                      ? const Center(child: Text('No timetables available.'))
                      : ListView.builder(
                          itemCount: timetables.length,
                          itemBuilder: (context, index) {
                            final timetable = timetables[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: ListTile(
                                leading: const Icon(CupertinoIcons.calendar),
                                title: Text(timetable['filename']),
                                subtitle: Text(timetable['description']),
                                trailing: IconButton(
                                  icon: const Icon(CupertinoIcons.delete),
                                  onPressed: () =>
                                      _deleteTimetable(timetable['id']),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoButton(
                color: CupertinoColors.activeGreen,
                onPressed: _isLoading ? null : _uploadTimetable,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.cloud_upload, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Upload Timetable',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
