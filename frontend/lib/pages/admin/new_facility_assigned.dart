// import 'dart:convert';
// import 'dart:developer';
// import 'dart:ffi';
// // import 'package:bomra/New%20Files/checklist_builder.dart';
// import 'package:bs_flutter/bs_flutter.dart';
// import 'package:change_notifier_builder/change_notifier_builder.dart';
// import 'package:connectivity_wrapper/connectivity_wrapper.dart';
// import 'package:cool_alert/cool_alert.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:intl/intl.dart';
// import 'package:overlay_support/overlay_support.dart';
// import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';
// import 'package:reactive_forms/reactive_forms.dart';
// import 'package:scientisst_db/scientisst_db.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:reactive_signature/reactive_signature.dart';
// import 'package:sn_progress_dialog/sn_progress_dialog.dart';
// import 'dart:typed_data';
// // import '../../Custom_widgets/customButton.dart';
// // import '../../Custom_widgets/custom_text_form_field.dart';
// // import '../../Custom_widgets/nodata.dart';
// // import '../../DBTransactions/LocalDb.dart';
// // import '../../DBTransactions/dbTransactions.dart';
// // import '../../custom_functions/custom_dropdown.dart';
// // import '../../custom_functions/ownFunctions.dart';
// // import '../UserPages/sharedInspectionPages/ChecklistTabs.dart';
// // import '../UserPages/sharedInspectionPages/InspectionFiles.dart';
// // import 'checklist_tab.dart';

// class NewFacilityAssignedApplication extends StatefulWidget {
//   const NewFacilityAssignedApplication({Key? key}) : super(key: key);

//   @override
//   State<NewFacilityAssignedApplication> createState() =>
//       _NewFacilityAssignedApplicationState();
// }

// class addUserModel extends ChangeNotifier {
//   String _name = "";

//   void add(name) {
//     _name = name;
//     notifyListeners();
//   }

//   void remove() {
//     _name = "";
//     notifyListeners();
//   }

//   String get name_ => _name;
// }

// class addFacilityRiskTypeModel extends ChangeNotifier {
//   int _RiskType = 0;

//   void add(RiskType) {
//     _RiskType = RiskType;
//     notifyListeners();
//   }

//   void remove() {
//     _RiskType = 0;
//     notifyListeners();
//   }

//   int get RiskType_ => _RiskType;
// }

// class _NewFacilityAssignedApplicationState
//     extends State<NewFacilityAssignedApplication>
//     with SingleTickerProviderStateMixin {
//   String personnel_name = "", personnel_reg = "";
//   int personnel_id = 0, personnel_pos = 0, personnel_qul = 0;
//   bool finalSave = false;
//   int? selectedPassStatus;
//   List<String> checklistList = ["What is your name", 'Where do you live'];

//   final TextEditingController _searchController = TextEditingController();
//   List<String> checklistTypeNames = [];
//   Map<String, dynamic>? foundItem;
//   String? responsible;
//   String? newPersonnel;

//   DateTime new_assessment_end_date = DateTime.now();

//   final detailsController = TextEditingController();

//   final addUserModel _addUserModel = addUserModel();
//   final addFacilityRiskTypeModel _addFacilityRiskTypeModel =
//       addFacilityRiskTypeModel();

//   loadPersonnelForm() {
//     final _formKey = GlobalKey<FormState>();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               insetPadding: EdgeInsets.zero,
//               title: Container(child: Text("Add Personnel")),
//               content: Container(
//                 height: MediaQuery.of(context).size.height,
//                 width: MediaQuery.of(context).size.width,
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         // label: 'Name',
//                         keyboardType: TextInputType.text,
//                         validator: (arg) {
//                           if (arg!.length < 3)
//                             return 'Name must be more than 2 characters';
//                           else
//                             return null;
//                         },
//                         onChanged: (String val) {
//                           setState(() {
//                             personnel_name = val;
//                           });
//                         },
//                       ),
//                       TextFormField(
//                         // label: 'Registration no',
//                         keyboardType: TextInputType.text,
//                         validator: (arg) {
//                           if (arg!.length < 3)
//                             return 'Registration no is required';
//                           else
//                             return null;
//                         },
//                         onChanged: (String val) {
//                           setState(() {
//                             personnel_reg = val;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text("Cancel"),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
// //    If all data are correct then save data to out variables
//                       _formKey.currentState!.save();

//                       _addUserModel.add(personnel_name);

//                       setState(() {
//                         personnel_id = 0;
//                       });

//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text("Save"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   ValueNotifier<String> query = ValueNotifier("");

//   loadForm(DocumentSnapshot snap, String inspectionID) async {
//     String starttime = "";
//     String endtime = "";
//     int x = 0;

//     Map<String, Object> controlsMap = {};

//     setState(() {
//       x = 1;
//     });

//     var application_id = 0,
//         module_id = 0,
//         sub_module_id = 0,
//         premise_id = 0,
//         process_id = 0,
//         application_code = 0,
//         workflow_stage_id = 0,
//         section_id = 0,
//         curr_stage_id = 0,
//         next_stage = 0,
//         isInspectionDone = 0;

//     try {
//       application_id = snap.data['main_details']['application_id']!;
//     } catch (ex) {}

//     try {
//       module_id = snap.data['main_details']['module_id']!;
//     } catch (ex) {}

//     try {
//       sub_module_id = snap.data['main_details']['sub_module_id']!;
//     } catch (ex) {}

//     try {
//       premise_id = snap.data['main_details']['premise_id']!;
//     } catch (ex) {}

//     try {
//       process_id = snap.data['main_details']['process_id']!;
//     } catch (ex) {}

//     try {
//       application_code = snap.data['main_details']['application_code']!;
//     } catch (ex) {}

//     try {
//       workflow_stage_id = snap.data['main_details']['workflow_stage_id']!;
//     } catch (ex) {}

//     try {
//       section_id = snap.data['main_details']['section_id']!;
//     } catch (ex) {}

//     try {
//       curr_stage_id = snap.data['main_details']['current_stage']!;
//     } catch (ex) {}

//     try {
//       next_stage = snap.data['main_details']['next_stage']!;
//     } catch (ex) {}

//     List main_personnel = [];

//     try {
//       isInspectionDone = snap.data!['main_details']['next_stage']!;
//     } catch (Ex) {}

//     try {
//       main_personnel = snap.data!['personnels'];
//     } catch (Ex) {}

//     List facility_type = [];
//     List facity_risk_type = [];
//     List facility_role = [];

//     List ActionList = [];
//     List responsible_usersList = [
//       "Onesmas Kung'u",
//       "Alpha MAcharia",
//       "Kennedy Musina"
//     ];
//     List predefinedText = [];
//     List predefinedpass = [];

//     try {
//       facility_type = snap.data!['tables']['facility_type'];
//     } catch (Ex) {
//       print(Ex.toString());
//     }
//     try {
//       facity_risk_type = snap.data!['tables']['facity_risk_type'];
//     } catch (Ex) {}
//     try {
//       facility_role = snap.data!['tables']['facility_role'];
//     } catch (Ex) {}
//     try {
//       ActionList = snap.data!['submission_details']['action'];
//     } catch (Ex) {}
//     try {
//       predefinedText = snap.data!['predefined_checklist'];
//     } catch (Ex) {}

//     int i = 0;

//     controlsMap.clear();

//     List uniqueList = [];
//     List uniqueItems = [];
//     Map<String, List<Map<String, dynamic>>> groupedItems = {};

//     for (i = 0; i < snap.data!['checklist_items'].length; i++) {
//       if (!uniqueList.contains(snap.data!['checklist_items'][i]['id'])) {
//         uniqueList.add(snap.data!['checklist_items'][i]['id']);
//         uniqueItems.add(snap.data!['checklist_items'][i]);
//         checklistTypeNames
//             .add(snap.data!['checklist_items'][i]['checklist_type']);
//       }
//     }
//     print("This is checklist items list: ${snap.data['checklist_items']}");
//     // Grouping items based on checklist_type
//     uniqueItems.forEach((item) {
//       if (groupedItems.containsKey(item['checklist_type'])) {
//         groupedItems[item['checklist_type']]!.add(item);
//         print('This is the item: $item \n\n');
//       } else {
//         groupedItems[item['checklist_type']] = [item];
//       }
//     });

//     // print(uniqueList);
//     snap.data!['checklist_items'] = uniqueItems;

//     for (i = 0; i < snap.data!['checklist_items'].length; i++) {
//       //print(snap.data!['checklist_items'][i]);
//       var yesno =
//           snap.data!['checklist_items'][i]['id'].toString() + "_" + "yesno";
//       var details =
//           snap.data!['checklist_items'][i]['id'].toString() + "_" + "details";

//       controlsMap.addAll({
//         yesno: FormControl<int>(),
//         details: FormControl<String>(),
//       });
//     }

//     var form_ = fb.group(controlsMap);

//     bool isChecklistFormFilled() {
//       for (var control in form_.controls.values) {
//         // Check if the control has a non-null and non-empty value
//         if (control.value == null || control.value.toString().isEmpty) {
//           return false; // Form is not completely filled
//         }
//       }
//       return true; // Form is completely filled
//     }

//     var recomendationKey = UniqueKey();

//     final formRecomendation = FormGroup({
//       // 'risk_premise_type_id': FormControl<int>(validators: [Validators.required]),
//       'risk_premise_type_id': FormControl<int>(),
//       'premise_type_id': FormControl<int>(),
//       'risk_premise_type_role_id': FormControl<int>(),
//       'recommendation_id': FormControl<int>(),
//       'assessment_start_date': FormControl<DateTime>(),
//       'assessment_end_date': FormControl<DateTime>(),
//       'recommendation_remarks': FormControl<String>(),
//       'prev_manager_recommendation': FormControl<String>(),
//       'distance': FormControl<String>(),
//     });
//     // 'signature': FormControl<Uint8List>(),

//     final formSignature = FormGroup({
//       'signature': FormControl<Uint8List>(),
//     });

//     final formSubmission = FormGroup({
//       'action': FormControl<int>(),
//       'curr_stage_id': FormControl<int>(),
//       'next_stage': FormControl<int>(),
//       'responsible_user': FormControl<int>(),
//       'remarks': FormControl<String>(),
//       // 'assessment_end_date': FormControl<DateTime>(),
//     });

//     final ValueNotifier<String> sig = ValueNotifier<String>("_");

//     try {
//       // ScientISSTdb.instance
//       //     .collection(ResponsesTime)
//       //     .document(snap.id.toString() + "_FCLT")
//       //     .get()
//       //     .then((Snapshot) {
//       //   try {
//       //     // print(Snapshot.data["start_time"]);

//       //     setState(() {
//       //       starttime = Snapshot.data["start_time"];
//       //       endtime = Snapshot.data["end_time"];
//       //     });
//       //   } catch (exp) {}
//       // });
//     } catch (exp) {}
//     try {
//       // ScientISSTdb.instance
//       //     .collection(Responses)
//       //     .document(snap.id.toString() + "_FCLT")
//       //     // .document(snap.id.toString() + "_FCLT")
//       //     .get()
//       //     .then((Snapshot) {
//       //   form_.value = Snapshot.data["form"];
//       //   formRecomendation.value = Snapshot.data["formRecomendation"];

//       //   try {
//       //     String _sig = Snapshot.data["formSignature"];

//       //     setState(() {
//       //       sig.value = _sig;
//       //     });
//       //   } catch (es) {
//       //     print(es);
//       //   }

//       //   // personnel_id = Snapshot.data["personnel_id"];

//       //   try {
//       //     if (personnel_id == 0) {
//       //       var newPersonnel = Snapshot.data["newPersonnel"];
//       //       _addUserModel.add(newPersonnel["name"]!);
//       //     }
//       //   } catch (err) {}
//       // });
//     } catch (exp) {}

//     // print(form_.value);

//     void updateDetails(String detailsControlName, String predefinedText) {
//       Future.delayed(Duration.zero, () {
//         form_.control(detailsControlName).value = predefinedText;
//       });
//     }

//     Widget widget(String mystarttime) {
//       // DateTime new_assessment_end_date = DateTime.now();
//       // String new_assessment_end_date = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

//       return DefaultTabController(
//         length: 5,
//         initialIndex: 0, // length of tabs
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Container(
//               child: TabBar(
//                 isScrollable: true,
//                 labelColor: Colors.black,
//                 unselectedLabelColor: Colors.grey,
//                 indicatorSize: TabBarIndicatorSize.tab,
//                 tabs: [
//                   Tab(text: 'CHECKLIST'),
//                   Tab(text: 'INSPECTION FORM'),
//                   Tab(text: 'PERSONNEL'),
//                   Tab(text: 'UPLOAD DOC'),
//                   Tab(text: 'SUBMIT'),
//                 ],
//               ),
//             ),
//             Container(
//               height: MediaQuery.of(context).size.height - kToolbarHeight * 2.8,
//               color: Colors.white,
//               //color: Colors.redAccent, //height of TabBarView
//               // padding: EdgeInsets.all(10),
//               child: TabBarView(
//                 children: <Widget>[
//                   // ChecklistBuilder(),
//                   Center(
//                     child: SingleChildScrollView(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 30),
//                         key: recomendationKey,
//                         child: ReactiveForm(
//                           formGroup: formRecomendation,
//                           child: Column(
//                             children: <Widget>[
//                               SizedBox(
//                                 height: 30,
//                               ),
//                               // Dunn_DropDownFormField(
//                               //   labelText: 'Risk Premise Type',
//                               //   theborder: OutlineInputBorder(
//                               //     borderRadius:
//                               //         BorderRadius.all(Radius.circular(20.0)),
//                               //   ),
//                               //   value: formRecomendation
//                               //       .control('risk_premise_type_id')
//                               //       .value,
//                               //   validator: (value) {
//                               //     if (value!.isEmpty) {
//                               //       return "Required";
//                               //     } else {
//                               //       return null;
//                               //     }
//                               //   },
//                               //   onSaved: (dt) {},
//                               //   onChanged: (value) async {
//                               //     setState(() {
//                               //       formRecomendation
//                               //           .control('risk_premise_type_id')
//                               //           .value = value;
//                               //       _addFacilityRiskTypeModel.add(value);

//                               //       recomendationKey = UniqueKey();
//                               //     });

//                               //     SharedPreferences prefs =
//                               //         await SharedPreferences.getInstance();

//                               //     int UserID = 0;
//                               //     String bearer = "";

//                               //     try {
//                               //       UserID = prefs.getInt('UserID')!;
//                               //     } catch (er) {}

//                               //     try {
//                               //       bearer = prefs.getString('bearer')!;
//                               //     } catch (er) {}

//                               //     //GLOBAL
//                               //     String formattedDate = "";

//                               //     if (starttime.isEmpty) {
//                               //       starttime = formRecomendation
//                               //           .value['assessment_start_date']
//                               //           .toString();
//                               //     }
//                               //     ;

//                               //     var OverallInspectionComment = {
//                               //       'stage_category_id': '2',
//                               //       'workflow_stage_id': workflow_stage_id,
//                               //       'assessment_start_date': starttime,
//                               //       'assessment_end_date': endtime,
//                               //       'risk_premise_type_id': formRecomendation
//                               //           .value['risk_premise_type_id']
//                               //           .toString(),
//                               //       'premise_type_id': formRecomendation
//                               //           .value['premise_type_id']
//                               //           .toString(),
//                               //       'risk_premise_type_role_id':
//                               //           formRecomendation
//                               //               .value['risk_premise_type_role_id']
//                               //               .toString(),
//                               //       'recommendation_id': formRecomendation
//                               //           .value['recommendation_id'],
//                               //       'recommendation_remarks': formRecomendation
//                               //           .value['recommendation_remarks']
//                               //           .toString(),
//                               //       'remarks': formRecomendation
//                               //           .value['prev_manager_recommendation']
//                               //           .toString(),
//                               //       'distance': formRecomendation
//                               //           .value['distance']
//                               //           .toString(),
//                               //       '_token': bearer.toString(),
//                               //       'application_code':
//                               //           application_code.toString(),
//                               //       'user_id': UserID.toString(),
//                               //     };

//                               //     ScientISSTdb.instance
//                               //         .collection(Responses)
//                               //         .document(snap.id.toString() + "_FCLT")
//                               //         .set({
//                               //       "type": "_FCLT",
//                               //       "id": snap.id,
//                               //       "form": form_.value,
//                               //       "formRecomendation":
//                               //           formRecomendation.value,
//                               //       "OverallInspectionComment":
//                               //           OverallInspectionComment,
//                               //     });
//                               //   },
//                               //   dataSource: facity_risk_type,
//                               //   textField: 'name',
//                               //   valueField: 'id',
//                               // ),
//                               const SizedBox(height: 20.0),
//                               // ChangeNotifierBuilder(
//                               //     notifier: _addFacilityRiskTypeModel,
//                               //     builder: (BuildContext context,
//                               //         addFacilityRiskTypeModel? model_, _) {
//                                     // return Dunn_DropDownFormField(
//                                     //   labelText: 'Premise Type',
//                                     //   theborder: OutlineInputBorder(
//                                     //     borderSide: BorderSide(
//                                     //         color:
//                                     //             Theme.of(context).primaryColor),
//                                     //     borderRadius: BorderRadius.all(
//                                     //         Radius.circular(20.0)),
//                                     //   ),
//                                     //   value: formRecomendation
//                                     //       .control('premise_type_id')
//                                     //       .value,
//                                     //   validator: (value) {
//                                     //     if (value!.isEmpty) {
//                                     //       return "Required";
//                                     //     } else {
//                                     //       return null;
//                                     //     }
//                                     //   },
//                                     //   onSaved: (dt) {},
//                                     //   onChanged: (value) async {
//                                     //     setState(() {
//                                     //       formRecomendation
//                                     //           .control('premise_type_id')
//                                     //           .value = value;
//                                     //     });

//                                     //     SharedPreferences prefs =
//                                     //         await SharedPreferences
//                                     //             .getInstance();

//                                     //     int UserID = 0;
//                                     //     String bearer = "";

//                                     //     try {
//                                     //       UserID = prefs.getInt('UserID')!;
//                                     //     } catch (er) {}

//                                     //     try {
//                                     //       bearer = prefs.getString('bearer')!;
//                                     //     } catch (er) {}

//                                     //     //GLOBAL
//                                     //     String formattedDate = "";

//                                     //     if (starttime.isEmpty) {
//                                     //       starttime = formRecomendation
//                                     //           .value['assessment_start_date']
//                                     //           .toString();
//                                     //     }
//                                     //     ;

//                                     //     var OverallInspectionComment = {
//                                     //       'stage_category_id': '2',
//                                     //       'workflow_stage_id':
//                                     //           workflow_stage_id,
//                                     //       'assessment_start_date': starttime,
//                                     //       'assessment_end_date': endtime,
//                                     //       'risk_premise_type_id':
//                                     //           formRecomendation
//                                     //               .value['risk_premise_type_id']
//                                     //               .toString(),
//                                     //       'premise_type_id': formRecomendation
//                                     //           .value['premise_type_id']
//                                     //           .toString(),
//                                     //       'risk_premise_type_role_id':
//                                     //           formRecomendation.value[
//                                     //                   'risk_premise_type_role_id']
//                                     //               .toString(),
//                                     //       'recommendation_id': formRecomendation
//                                     //           .value['recommendation_id'],
//                                     //       'recommendation_remarks':
//                                     //           formRecomendation.value[
//                                     //                   'recommendation_remarks']
//                                     //               .toString(),
//                                     //       'remarks': formRecomendation.value[
//                                     //               'prev_manager_recommendation']
//                                     //           .toString(),
//                                     //       'distance': formRecomendation
//                                     //           .value['distance']
//                                     //           .toString(),
//                                     //       '_token': bearer.toString(),
//                                     //       'application_code':
//                                     //           application_code.toString(),
//                                     //       'user_id': UserID.toString(),
//                                     //     };

//                                     //     ScientISSTdb.instance
//                                     //         .collection(Responses)
//                                     //         .document(
//                                     //             snap.id.toString() + "_FCLT")
//                                     //         .set({
//                                     //       "type": "_FCLT",
//                                     //       "id": snap.id,
//                                     //       "form": form_.value,
//                                     //       "formRecomendation":
//                                     //           formRecomendation.value,
//                                     //       "OverallInspectionComment":
//                                     //           OverallInspectionComment,
//                                     //     });
//                                     //   },
//                                     //   dataSource: facility_type
//                                     //       .where((element) =>
//                                     //           element['risk_premise_type_id'] ==
//                                     //           model_!.RiskType_)
//                                     //       .toList(),
//                                     //   textField: 'name',
//                                     //   valueField: 'risk_premise_type',
//                                     // );
//                                   // }),
//                               const SizedBox(height: 20.0),
//                               // ChangeNotifierBuilder(
//                               //     notifier: _addFacilityRiskTypeModel,
//                               //     builder: (BuildContext context,
//                               //         addFacilityRiskTypeModel? model_, _) {
//                               //       return Dunn_DropDownFormField(
//                               //         onTap: () {
//                               //           print("tab");
//                               //         },
//                               //         labelText: 'Risk Premise Type Role',
//                               //         decoration: InputDecoration(
//                               //           enabledBorder: OutlineInputBorder(
//                               //             borderSide: BorderSide(
//                               //                 color: Theme.of(context)
//                               //                     .primaryColor),
//                               //             borderRadius: BorderRadius.all(
//                               //                 Radius.circular(10.0)),
//                               //           ),
//                               //         ),
//                               //         theborder: OutlineInputBorder(
//                               //           borderRadius: BorderRadius.all(
//                               //               Radius.circular(20.0)),
//                               //         ),
//                               //         value: formRecomendation
//                               //             .control('risk_premise_type_role_id')
//                               //             .value,
//                               //         validator: (value) {
//                               //           if (value!.isEmpty) {
//                               //             return "Required";
//                               //           } else {
//                               //             return null;
//                               //           }
//                               //         },
//                               //         onSaved: (dt) {},
//                               //         onChanged: (value) async {
//                               //           setState(() {
//                               //             formRecomendation
//                               //                 .control(
//                               //                     'risk_premise_type_role_id')
//                               //                 .value = value;
//                               //           });
//                               //           SharedPreferences prefs =
//                               //               await SharedPreferences
//                               //                   .getInstance();

//                               //           int UserID = 0;
//                               //           String bearer = "";

//                               //           try {
//                               //             UserID = prefs.getInt('UserID')!;
//                               //           } catch (er) {}

//                               //           try {
//                               //             bearer = prefs.getString('bearer')!;
//                               //           } catch (er) {}

//                               //           //GLOBAL
//                               //           String formattedDate = "";

//                               //           if (starttime.isEmpty) {
//                               //             starttime = formRecomendation
//                               //                 .value['assessment_start_date']
//                               //                 .toString();
//                               //           }
//                               //           ;

//                               //           var OverallInspectionComment = {
//                               //             'stage_category_id': '2',
//                               //             'workflow_stage_id':
//                               //                 workflow_stage_id,
//                               //             'assessment_start_date': starttime,
//                               //             'assessment_end_date': endtime,
//                               //             'risk_premise_type_id':
//                               //                 formRecomendation
//                               //                     .value['risk_premise_type_id']
//                               //                     .toString(),
//                               //             'premise_type_id': formRecomendation
//                               //                 .value['premise_type_id']
//                               //                 .toString(),
//                               //             'risk_premise_type_role_id':
//                               //                 formRecomendation.value[
//                               //                         'risk_premise_type_role_id']
//                               //                     .toString(),
//                               //             'recommendation_id': formRecomendation
//                               //                 .value['recommendation_id'],
//                               //             'recommendation_remarks':
//                               //                 formRecomendation.value[
//                               //                         'recommendation_remarks']
//                               //                     .toString(),
//                               //             'remarks': formRecomendation.value[
//                               //                     'prev_manager_recommendation']
//                               //                 .toString(),
//                               //             'distance': formRecomendation
//                               //                 .value['distance']
//                               //                 .toString(),
//                               //             '_token': bearer.toString(),
//                               //             'application_code':
//                               //                 application_code.toString(),
//                               //             'user_id': UserID.toString(),
//                               //           };

//                               //           ScientISSTdb.instance
//                               //               .collection(Responses)
//                               //               .document(
//                               //                   snap.id.toString() + "_FCLT")
//                               //               .set({
//                               //             "type": "_FCLT",
//                               //             "id": snap.id,
//                               //             "form": form_.value,
//                               //             "formRecomendation":
//                               //                 formRecomendation.value,
//                               //             "OverallInspectionComment":
//                               //                 OverallInspectionComment,
//                               //           });
//                               //         },
//                               //         dataSource: facility_role
//                               //             .where((element) =>
//                               //                 element['risk_premise_type_id'] ==
//                               //                 model_!.RiskType_)
//                               //             .toList(),
//                               //         textField: 'name',
//                               //         valueField: 'id',
//                               //       );
//                               //     }),
//                               const SizedBox(height: 20.0),
//                               ReactiveDropdownField<int>(
//                                 formControlName: 'recommendation_id',
//                                 decoration: InputDecoration(
//                                     enabledBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color:
//                                               Theme.of(context).primaryColor),
//                                       borderRadius: BorderRadius.all(
//                                           Radius.circular(10.0)),
//                                     ),
//                                     labelText: 'Inspection Recommendation',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                           Radius.circular(20.0)),
//                                     )),
//                                 items: [
//                                   const DropdownMenuItem(
//                                     value: 1,
//                                     child: Text('Recommended'),
//                                   ),
//                                   const DropdownMenuItem(
//                                     value: 2,
//                                     child: Text('Not Recommended'),
//                                   ),
//                                 ],
//                                 onChanged: (value) async {
//                                   SharedPreferences prefs =
//                                       await SharedPreferences.getInstance();

//                                   int UserID = 0;
//                                   String bearer = "";

//                                   try {
//                                     UserID = prefs.getInt('UserID')!;
//                                   } catch (er) {}

//                                   try {
//                                     bearer = prefs.getString('bearer')!;
//                                   } catch (er) {}

//                                   //GLOBAL
//                                   String formattedDate = "";

//                                   if (starttime.isEmpty) {
//                                     starttime = formRecomendation
//                                         .value['assessment_start_date']
//                                         .toString();
//                                   }
//                                   ;

//                                   var OverallInspectionComment = {
//                                     'stage_category_id': '2',
//                                     'workflow_stage_id': workflow_stage_id,
//                                     'assessment_start_date': starttime,
//                                     'assessment_end_date': endtime,
//                                     'risk_premise_type_id': formRecomendation
//                                         .value['risk_premise_type_id']
//                                         .toString(),
//                                     'premise_type_id': formRecomendation
//                                         .value['premise_type_id']
//                                         .toString(),
//                                     'risk_premise_type_role_id':
//                                         formRecomendation
//                                             .value['risk_premise_type_role_id']
//                                             .toString(),
//                                     'recommendation_id': formRecomendation
//                                         .value['recommendation_id'],
//                                     'recommendation_remarks': formRecomendation
//                                         .value['recommendation_remarks']
//                                         .toString(),
//                                     'remarks': formRecomendation
//                                         .value['prev_manager_recommendation']
//                                         .toString(),
//                                     'distance': formRecomendation
//                                         .value['distance']
//                                         .toString(),
//                                     '_token': bearer.toString(),
//                                     'application_code':
//                                         application_code.toString(),
//                                     'user_id': UserID.toString(),
//                                   };

//                                   // ScientISSTdb.instance
//                                   //     .collection(Responses)
//                                   //     .document(snap.id.toString() + "_FCLT")
//                                   //     .set({
//                                   //   "type": "_FCLT",
//                                   //   "id": snap.id,
//                                   //   "form": form_.value,
//                                   //   "formRecomendation":
//                                   //       formRecomendation.value,
//                                   //   "OverallInspectionComment":
//                                   //       OverallInspectionComment,
//                                   // });
//                                 },
//                               ),
//                               const SizedBox(height: 20.0),
//                               ReactiveTextField(
//                                 formControlName: 'recommendation_remarks',
//                                 decoration: InputDecoration(
//                                     labelText: 'Recommendations Remarks',
//                                     enabledBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color:
//                                               Theme.of(context).primaryColor),
//                                       borderRadius: BorderRadius.all(
//                                           Radius.circular(10.0)),
//                                     ),
//                                     labelStyle:
//                                         TextStyle(fontWeight: FontWeight.bold),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                           Radius.circular(20.0)),
//                                     )),
//                                 //  textAlign: TextAlign.center,
//                                 keyboardType: TextInputType.multiline,
//                                 minLines: 4,
//                                 maxLines: 5,
//                                 style: TextStyle(backgroundColor: Colors.white),
//                                 onChanged: (value) async {
//                                   SharedPreferences prefs =
//                                       await SharedPreferences.getInstance();

//                                   int UserID = 0;
//                                   String bearer = "";

//                                   try {
//                                     UserID = prefs.getInt('UserID')!;
//                                   } catch (er) {}

//                                   try {
//                                     bearer = prefs.getString('bearer')!;
//                                   } catch (er) {}

//                                   //GLOBAL
//                                   String formattedDate = "";

//                                   if (starttime.isEmpty) {
//                                     starttime = formRecomendation
//                                         .value['assessment_start_date']
//                                         .toString();
//                                   }
//                                   ;

//                                   var OverallInspectionComment = {
//                                     'stage_category_id': '2',
//                                     'workflow_stage_id': workflow_stage_id,
//                                     'assessment_start_date': starttime,
//                                     'assessment_end_date': endtime,
//                                     'risk_premise_type_id': formRecomendation
//                                         .value['risk_premise_type_id']
//                                         .toString(),
//                                     'premise_type_id': formRecomendation
//                                         .value['premise_type_id']
//                                         .toString(),
//                                     'risk_premise_type_role_id':
//                                         formRecomendation
//                                             .value['risk_premise_type_role_id']
//                                             .toString(),
//                                     'recommendation_id': formRecomendation
//                                         .value['recommendation_id']
//                                         .toString(),
//                                     'recommendation_remarks': formRecomendation
//                                         .value['recommendation_remarks']
//                                         .toString(),
//                                     'remarks': formRecomendation
//                                         .value['prev_manager_recommendation']
//                                         .toString(),
//                                     'distance': formRecomendation
//                                         .value['distance']
//                                         .toString(),
//                                     '_token': bearer.toString(),
//                                     'application_code':
//                                         application_code.toString(),
//                                     'user_id': UserID.toString(),
//                                   };

//                                   // ScientISSTdb.instance
//                                   //     .collection(Responses)
//                                   //     .document(snap.id.toString() + "_FCLT")
//                                   //     .set({
//                                   //   "type": "_FCLT",
//                                   //   "id": snap.id,
//                                   //   "form": form_.value,
//                                   //   "formRecomendation":
//                                   //       formRecomendation.value,
//                                   //   "OverallInspectionComment":
//                                   //       OverallInspectionComment,
//                                   // });
//                                 },
//                               ),
//                               const SizedBox(height: 20.0),
//                               ReactiveTextField(
//                                 formControlName: 'distance',
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   labelText: 'Distances From HQ in KM/s',
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(
//                                         color: Theme.of(context).primaryColor),
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(10.0)),
//                                   ),
//                                   labelStyle:
//                                       TextStyle(fontWeight: FontWeight.bold),
//                                   border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(20.0)),
//                                   ),
//                                 ),
//                                 style: TextStyle(backgroundColor: Colors.white),
//                                 onChanged: (value) async {
//                                   SharedPreferences prefs =
//                                       await SharedPreferences.getInstance();

//                                   int UserID = 0;
//                                   String bearer = "";

//                                   try {
//                                     UserID = prefs.getInt('UserID')!;
//                                   } catch (er) {}

//                                   try {
//                                     bearer = prefs.getString('bearer')!;
//                                   } catch (er) {}

//                                   //GLOBAL

//                                   String formattedDate = "";

//                                   if (starttime.isEmpty) {
//                                     starttime = formRecomendation
//                                         .value['assessment_start_date']
//                                         .toString();
//                                   }
//                                   ;

//                                   var OverallInspectionComment = {
//                                     'stage_category_id': '2',
//                                     'workflow_stage_id': workflow_stage_id,
//                                     'assessment_start_date': starttime,
//                                     'assessment_end_date': endtime,
//                                     'risk_premise_type_id': formRecomendation
//                                         .value['risk_premise_type_id']
//                                         .toString(),
//                                     'premise_type_id': formRecomendation
//                                         .value['premise_type_id']
//                                         .toString(),
//                                     'risk_premise_type_role_id':
//                                         formRecomendation
//                                             .value['risk_premise_type_role_id']
//                                             .toString(),
//                                     'recommendation_id': formRecomendation
//                                         .value['recommendation_id'],
//                                     'recommendation_remarks': formRecomendation
//                                         .value['recommendation_remarks']
//                                         .toString(),
//                                     'remarks': formRecomendation
//                                         .value['prev_manager_recommendation']
//                                         .toString(),
//                                     'distance': formRecomendation
//                                         .value['distance']
//                                         .toString(),
//                                     '_token': bearer.toString(),
//                                     'application_code':
//                                         application_code.toString(),
//                                     'user_id': UserID.toString(),
//                                   };

//                                   // ScientISSTdb.instance
//                                   //     .collection(Responses)
//                                   //     .document(snap.id.toString() + "_FCLT")
//                                   //     .set({
//                                   //   "type": "_FCLT",
//                                   //   "id": snap.id,
//                                   //   "form": form_.value,
//                                   //   "formRecomendation":
//                                   //       formRecomendation.value,
//                                   //   "OverallInspectionComment":
//                                   //       OverallInspectionComment,
//                                   // });
//                                 },
//                               ),
//                               const SizedBox(height: 20.0),
//                               Visibility(
//                                 visible: false,
//                                 child: ReactiveTextField<DateTime>(
//                                   formControlName: 'assessment_end_date',
//                                   decoration: InputDecoration(
//                                       labelText: 'Inspection End Date',
//                                       enabledBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color:
//                                                 Theme.of(context).primaryColor),
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(10.0)),
//                                       ),
//                                       border: OutlineInputBorder(
//                                           borderRadius: const BorderRadius.all(
//                                               Radius.circular(20.0)))),
//                                   //  textAlign: TextAlign.center,
//                                   style:
//                                       TextStyle(backgroundColor: Colors.white),
//                                   onChanged: (value) async {
//                                     SharedPreferences prefs =
//                                         await SharedPreferences.getInstance();

//                                     int UserID = 0;
//                                     String bearer = "";

//                                     try {
//                                       UserID = prefs.getInt('UserID')!;
//                                     } catch (er) {}

//                                     try {
//                                       bearer = prefs.getString('bearer')!;
//                                     } catch (er) {}

//                                     //GLOBAL
//                                     String formattedDate = "";

//                                     if (starttime.isEmpty) {
//                                       starttime = formRecomendation
//                                           .value['assessment_start_date']
//                                           .toString();
//                                     }
//                                     ;

//                                     var OverallInspectionComment = {
//                                       'stage_category_id': '2',
//                                       'workflow_stage_id': workflow_stage_id,
//                                       'assessment_start_date': starttime,
//                                       'assessment_end_date': endtime,
//                                       'risk_premise_type_id': formRecomendation
//                                           .value['risk_premise_type_id']
//                                           .toString(),
//                                       'premise_type_id': formRecomendation
//                                           .value['premise_type_id']
//                                           .toString(),
//                                       'risk_premise_type_role_id':
//                                           formRecomendation.value[
//                                                   'risk_premise_type_role_id']
//                                               .toString(),
//                                       'recommendation_id': formRecomendation
//                                           .value['recommendation_id'],
//                                       'recommendation_remarks':
//                                           formRecomendation
//                                               .value['recommendation_remarks']
//                                               .toString(),
//                                       'remarks': formRecomendation
//                                           .value['prev_manager_recommendation']
//                                           .toString(),
//                                       'distance': formRecomendation
//                                           .value['distance']
//                                           .toString(),
//                                       '_token': bearer.toString(),
//                                       'application_code':
//                                           application_code.toString(),
//                                       'user_id': UserID.toString(),
//                                     };

//                                     // ScientISSTdb.instance
//                                     //     .collection(Responses)
//                                     //     .document(snap.id.toString() + "_FCLT")
//                                     //     .set({
//                                     //   "type": "_FCLT",
//                                     //   "id": snap.id,
//                                     //   "form": form_.value,
//                                     //   "formRecomendation":
//                                     //       formRecomendation.value,
//                                     //   "OverallInspectionComment":
//                                     //       OverallInspectionComment,
//                                     // });
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 30,
//                               ),
//                               // CustomButton(
//                               //   "Save Inspection Details",
//                               //   Color(0xff0A5533),
//                               //   Colors.white,
//                               //   () async {
//                               //     SharedPreferences prefs =
//                               //         await SharedPreferences.getInstance();

//                               //     int UserID = 0;
//                               //     String bearer = "";

//                               //     try {
//                               //       UserID = prefs.getInt('UserID')!;
//                               //     } catch (er) {}

//                               //     try {
//                               //       bearer = prefs.getString('bearer')!;
//                               //     } catch (er) {}

//                               //     //GLOBAL
//                               //     String formattedDate = "";

//                               //     if (starttime.isEmpty) {
//                               //       starttime = formRecomendation
//                               //           .value['assessment_start_date']
//                               //           .toString();
//                               //     }
//                               //     ;

//                               //     var OverallInspectionComment = {
//                               //       'stage_category_id': '2',
//                               //       'workflow_stage_id': workflow_stage_id,
//                               //       'assessment_start_date': starttime,
//                               //       'assessment_end_date': endtime,
//                               //       'risk_premise_type_id': formRecomendation
//                               //           .value['risk_premise_type_id']
//                               //           .toString(),
//                               //       'premise_type_id': formRecomendation
//                               //           .value['premise_type_id']
//                               //           .toString(),
//                               //       'risk_premise_type_role_id':
//                               //           formRecomendation
//                               //               .value['risk_premise_type_role_id']
//                               //               .toString(),
//                               //       'recommendation_id': formRecomendation
//                               //           .value['recommendation_id'],
//                               //       'recommendation_remarks': formRecomendation
//                               //           .value['recommendation_remarks']
//                               //           .toString(),
//                               //       'remarks': formRecomendation
//                               //           .value['prev_manager_recommendation']
//                               //           .toString(),
//                               //       'distance': formRecomendation
//                               //           .value['distance']
//                               //           .toString(),
//                               //       '_token': bearer.toString(),
//                               //       'application_code':
//                               //           application_code.toString(),
//                               //       'user_id': UserID.toString(),
//                               //     };

//                               //     if (formRecomendation.valid) {
//                               //       // print(formRecomendation.value);
//                               //       if (await ConnectivityWrapper
//                               //           .instance.isConnected) {
//                               //         showModalBottomSheet(
//                               //           context: context,
//                               //           builder: (context) {
//                               //             return Wrap(
//                               //               children: [
//                               //                 ListTile(
//                               //                     leading: Icon(Icons.copy),
//                               //                     title: Text(
//                               //                         'Saved Inspection Details as Draft'),
//                               //                     onTap: () {
//                               //                       Navigator.pop(context);
//                               //                       ScientISSTdb.instance
//                               //                           .collection(Responses)
//                               //                           .document(
//                               //                               snap.id.toString() +
//                               //                                   "_FCLT")
//                               //                           .set({
//                               //                         "type": "_FCLT",
//                               //                         "id": snap.id,
//                               //                         "form": form_.value,
//                               //                         "formRecomendation":
//                               //                             formRecomendation
//                               //                                 .value,
//                               //                         "OverallInspectionComment":
//                               //                             OverallInspectionComment,
//                               //                       });

//                               //                       showSimpleNotification(
//                               //                           leading: Icon(Icons
//                               //                               .check_circle_rounded),
//                               //                           Text(
//                               //                               "Saved Inspection Details as draft !!"),
//                               //                           background:
//                               //                               Colors.green,
//                               //                           duration: Duration(
//                               //                               seconds: 2));
//                               //                     }),
//                               //                 ListTile(
//                               //                   leading: Icon(Icons.cancel),
//                               //                   title: Text('Cancel'),
//                               //                   onTap: () {
//                               //                     Navigator.pop(context);
//                               //                   },
//                               //                 ),
//                               //               ],
//                               //             );
//                               //           },
//                               //         );
//                               //       } else {
//                               //         // print(OverallInspectionComment);
//                               //         ScientISSTdb.instance
//                               //             .collection(Responses)
//                               //             .document(
//                               //                 snap.id.toString() + "_FCLT")
//                               //             .set({
//                               //           "type": "_FCLT",
//                               //           "id": snap.id,
//                               //           "formRecomendation":
//                               //               formRecomendation.value,
//                               //           "OverallInspectionComment":
//                               //               OverallInspectionComment,
//                               //         });
//                               //         showSimpleNotification(
//                               //             leading:
//                               //                 Icon(Icons.check_circle_rounded),
//                               //             Text(
//                               //                 "Inspection Details saved as a draft"),
//                               //             background: Colors.green,
//                               //             duration: Duration(seconds: 2));
//                               //       }
//                               //     } else {
//                               //       formRecomendation.markAllAsTouched();
//                               //     }
//                               //   },
//                               // ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           ChangeNotifierBuilder(
//                             // supply the instance of `ChangeNotifier` model,
//                             // whether you get it from the build context or anywhere
//                             notifier: _addUserModel,
//                             // this builder function will be executed,
//                             // once the `ChangeNotifier` model is updated
//                             builder: (BuildContext context,
//                                 addUserModel? model_, _) {
//                               return Column(
//                                 children: [
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 30),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: model_!.name_.isEmpty
//                                               ? DropdownButtonFormField<String>(
//                                                   value: newPersonnel,
//                                                   items: [
//                                                     'Onesmas Kungu',
//                                                     'Alpha Macharia',
//                                                     'Kennedy Musina'
//                                                   ]
//                                                       .map((score) =>
//                                                           DropdownMenuItem(
//                                                             value: score,
//                                                             child: Text(score),
//                                                           ))
//                                                       .toList(),
//                                                   decoration: InputDecoration(
//                                                     labelText:
//                                                         'Select Personnel',
//                                                     labelStyle: TextStyle(
//                                                         fontFamily:
//                                                             'Montserrat'),
//                                                     border:
//                                                         OutlineInputBorder(),
//                                                   ),
//                                                   onChanged: (value) {
//                                                     setState(() {
//                                                       newPersonnel = value;
//                                                     });
//                                                   },
//                                                 ) :  const Text("BoxTextField")
//                                               // : BoxTextField(
//                                               //     label: 'New personnel',
//                                               //     readOnly: true,
//                                               //     controller:
//                                               //         TextEditingController(
//                                               //             text: model_!.name_),
//                                               //     onChanged: (value) async {
//                                               //       var newPersonnel = {
//                                               //         "application_code":
//                                               //             application_code
//                                               //                 .toString(),
//                                               //         "name": personnel_name
//                                               //             .toString(),
//                                               //         "reg_no": personnel_reg
//                                               //             .toString(),
//                                               //         "position_id":
//                                               //             personnel_pos,
//                                               //         "qualification_id":
//                                               //             personnel_qul,
//                                               //         "premise_id": premise_id,
//                                               //         "signature": sig.value
//                                               //       };
//                                               //       var exisitingPersonel = {
//                                               //         "application_id":
//                                               //             application_id
//                                               //                 .toString(),
//                                               //         "application_code":
//                                               //             application_code
//                                               //                 .toString(),
//                                               //         //"_token": bearer.toString(),
//                                               //         "personnel_id":
//                                               //             personnel_id,
//                                               //         "premise_id": premise_id,
//                                               //         // "signature": sig.value,
//                                               //       };
//                                               //       ScientISSTdb.instance
//                                               //           .collection(Responses)
//                                               //           .document(
//                                               //               snap.id.toString() +
//                                               //                   "_FCLT")
//                                               //           .set({
//                                               //         "type": "_FCLT",
//                                               //         "id": snap.id,
//                                               //         "form": form_.value,
//                                               //         "formRecomendation":
//                                               //             formRecomendation
//                                               //                 .value,
//                                               //         "newPersonnel":
//                                               //             newPersonnel,
//                                               //         "exisitingPersonel":
//                                               //             exisitingPersonel,
//                                               //       });
//                                               //     },
//                                               //   ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         Material(
//                                           type: MaterialType.transparency,
//                                           child: Ink(
//                                             decoration: BoxDecoration(
//                                               border: Border.all(
//                                                   color: Theme.of(context)
//                                                       .primaryColor,
//                                                   width: 2.0),
//                                               color: Theme.of(context)
//                                                   .primaryColor
//                                                   .withValues(alpha: 0.8),
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: InkWell(
//                                               borderRadius:
//                                                   BorderRadius.circular(500.0),
//                                               onTap: () {
//                                                 if (model_!.name_.isEmpty) {
//                                                   loadPersonnelForm();
//                                                 } else {
//                                                   setState(() {
//                                                     _addUserModel.remove();
//                                                     personnel_name = "";
//                                                   });
//                                                 }
//                                               },
//                                               child: Padding(
//                                                 padding: EdgeInsets.all(10.0),
//                                                 child: Icon(
//                                                     model_!.name_.isEmpty
//                                                         ? Icons.add
//                                                         : Icons.close,
//                                                     size: 20.0,
//                                                     color: Colors.white),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 10.0),
//                           InkWell(
//                             child: Container(
//                               padding: EdgeInsets.symmetric(horizontal: 20),
//                               child: Column(
//                                 children: [
//                                   SizedBox(
//                                     height: 20,
//                                   ),
//                                   Container(child: Text("Signature")),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   ValueListenableBuilder<String>(
//                                     builder: (BuildContext context,
//                                         String value, Widget? child) {
//                                       // This builder will only get called when the _counter
//                                       // is updated.
//                                       return Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 10),
//                                         child: DottedBorder(
//                                           borderType: BorderType.RRect,
//                                           radius: Radius.circular(12),
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(12)),
//                                             child: (Container(
//                                                 width: MediaQuery.of(context)
//                                                     .size
//                                                     .width,
//                                                 height: 70,
//                                                 padding: EdgeInsets.all(20),
//                                                 color: Colors.white,
//                                                 child: sig.value == '_'
//                                                     ? Container(
//                                                         child: Image.asset(
//                                                           "assets/images/signature_.png",
//                                                           width: 240,
//                                                           height: 150,
//                                                         ),
//                                                       )
//                                                     : Container(
//                                                         width: MediaQuery.of(
//                                                                 context)
//                                                             .size
//                                                             .width,
//                                                         color: Colors.white,
//                                                         //color: Colors.grey[300],
//                                                         child: Image.memory(
//                                                           base64Decode(
//                                                             sig.value
//                                                                 .replaceAll(
//                                                               "data:image/png;base64,",
//                                                               "",
//                                                             ),
//                                                           ),
//                                                           width: 240,
//                                                           height: 150,
//                                                           // fit: BoxFit.fitWidth,
//                                                         ),
//                                                       ))),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     valueListenable: sig,
//                                     child: SizedBox(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             onTap: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (context) {
//                                   return StatefulBuilder(
//                                     builder: (context, setState) {
//                                       return AlertDialog(
//                                         //title: Text("Sign Here"),
//                                         content: Container(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               .8,
//                                           height: 300,
//                                           //color: Colors.grey[300],
//                                           child: Padding(
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 30, vertical: 10),
//                                             child: ReactiveForm(
//                                               formGroup: formSignature,
//                                               child: Column(
//                                                 children: <Widget>[
//                                                   ReactiveSignature<Uint8List>(
//                                                     exportBackgroundColor:
//                                                         Color.fromARGB(
//                                                             255, 255, 255, 255),
//                                                     height: 150,
//                                                     backgroundColor:
//                                                         Color.fromARGB(
//                                                             255, 255, 255, 255),
//                                                     formControlName:
//                                                         'signature',
//                                                     decoration:
//                                                         const InputDecoration(
//                                                       labelText: 'Signature',
//                                                       // border: OutlineInputBorder(),
//                                                       helperText: '',
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 16),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         actions: <Widget>[
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.pop(context),
//                                             child: Text("Cancel"),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               if (formSignature.valid) {
//                                                 Navigator.pop(context);
//                                                 var signature1 = formSignature
//                                                         .value['signature']!
//                                                     as Uint8List;

//                                                 var signature_ = "";
//                                                     // uint8ListTob64(signature1);

//                                                 String _sig = signature_;

//                                                 setState(() {
//                                                   sig.value = _sig;
//                                                 });

//                                                 var exisitingPersonel = {
//                                                   "application_id":
//                                                       application_id.toString(),
//                                                   "application_code":
//                                                       application_code
//                                                           .toString(),
//                                                   //"_token": bearer.toString(),
//                                                   "personnel_id": personnel_id,
//                                                   "premise_id": premise_id,
//                                                   // "signature": sig.value,
//                                                 };
//                                                 var newPersonnel = {
//                                                   "application_code":
//                                                       application_code
//                                                           .toString(),
//                                                   "name":
//                                                       personnel_name.toString(),
//                                                   "reg_no":
//                                                       personnel_reg.toString(),
//                                                   "position_id": personnel_pos,
//                                                   "qualification_id":
//                                                       personnel_qul,
//                                                   "premise_id": premise_id,
//                                                   // "signature": sig.value
//                                                 };
//                                                 // ScientISSTdb.instance
//                                                 //     .collection(Responses)
//                                                 //     .document(
//                                                 //         snap.id.toString() +
//                                                 //             "_FCLT")
//                                                 //     .set({
//                                                 //   "type": "_FCLT",
//                                                 //   "id": snap.id,
//                                                 //   "form": form_.value,
//                                                 //   "formRecomendation":
//                                                 //       formRecomendation.value,
//                                                 //   "exisitingPersonel":
//                                                 //       exisitingPersonel,
//                                                 //   "newPersonnel": newPersonnel,
//                                                 //   // "formSignature": sig.value,
//                                                 // });
//                                               }
//                                             },
//                                             child: Text("Save"),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Center(
//                   //   child: InspectionFiles(),
//                   // ),
//                   Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 30),
//                       child: ReactiveForm(
//                         formGroup: formSubmission,
//                         child: Column(
//                           children: <Widget>[
//                             const SizedBox(height: 16),
//                             DropdownButtonFormField(
//                               // labelText: 'Action ',
//                               // theborder: OutlineInputBorder(
//                               //   borderRadius:
//                               //       BorderRadius.all(Radius.circular(20.0)),
//                               // ),
//                               value: formSubmission.control('action').value,
//                               validator: (value) {
//                                 if (value == null) {
//                                   return "Required";
//                                 } else {
//                                   return null;
//                                 }
//                               },
//                               onSaved: (dt) {},
//                               onChanged: (value) {
//                                 formSubmission.control('action').value = value;
//                               }, items: [],
//                               // dataSource: ActionList,
//                               // textField: 'name',
//                               // valueField: 'id',
//                             ),
//                             const SizedBox(height: 20.0),
//                             DropdownButtonFormField<String>(
//                               value: responsible,
//                               items: [
//                                 'Onesmas Kungu',
//                                 'Alpha Macharia',
//                                 'Kennedy Musina'
//                               ]
//                                   .map((score) => DropdownMenuItem(
//                                         value: score,
//                                         child: Text(score),
//                                       ))
//                                   .toList(),
//                               decoration: InputDecoration(
//                                 labelText: 'Risk Score',
//                                 labelStyle: TextStyle(fontFamily: 'Montserrat'),
//                                 border: OutlineInputBorder(),
//                               ),
//                               onChanged: (value) {
//                                 setState(() {
//                                   responsible = value;
//                                 });
//                               },
//                             ),
//                             const SizedBox(height: 20.0),
//                             ReactiveTextField(
//                               formControlName: 'remarks',
//                               decoration: InputDecoration(
//                                   labelText: 'Remarks',
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(
//                                         color: Theme.of(context).primaryColor),
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(10.0)),
//                                   ),
//                                   border: OutlineInputBorder(
//                                       borderRadius: const BorderRadius.all(
//                                           Radius.circular(20.0)))),
//                               //  textAlign: TextAlign.center,
//                               keyboardType: TextInputType.multiline,
//                               minLines: 4,
//                               maxLines: 5,
//                               style: TextStyle(backgroundColor: Colors.white),
//                             ),
//                             const SizedBox(height: 10),
//                             // IgnorePointer(
//                             //   ignoring: true,
//                             //   child: ReactiveDateTimePicker(
//                             //     formControlName: 'assessment_end_date',
//                             //     decoration: InputDecoration(
//                             //         labelText: 'Inspection End Date',
//                             //         enabledBorder: OutlineInputBorder(
//                             //           borderSide: BorderSide(
//                             //               color: Theme.of(context).primaryColor),
//                             //           borderRadius:
//                             //           BorderRadius.all(Radius.circular(10.0)),
//                             //         ),
//                             //         border: OutlineInputBorder(
//                             //           borderRadius: BorderRadius.all(
//                             //               Radius.circular(20.0)),
//                             //         )),
//                             //     style: TextStyle(backgroundColor: Colors.white),
//                             //     dateFormat: DateFormat("yyyy-MM-dd kk:mm:ss"),
//                             //
//                             //   ),
//                             // ),
//                             const SizedBox(height: 10),
//                             InkWell(
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 20),
//                                 child: Column(
//                                   children: [
//                                     SizedBox(
//                                       height: 20,
//                                     ), // ---
//                                     Container(
//                                         child: Text("Inspector Signature")),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     ValueListenableBuilder<String>(
//                                       builder: (BuildContext context,
//                                           String value, Widget? child) {
//                                         // This builder will only get called when the _counter
//                                         // is updated.
//                                         return Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: DottedBorder(
//                                             borderType: BorderType.RRect,
//                                             radius: Radius.circular(12),
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(12)),
//                                               child: (Container(
//                                                   width: MediaQuery.of(context)
//                                                       .size
//                                                       .width,
//                                                   height: 70,
//                                                   padding: EdgeInsets.all(20),
//                                                   color: Colors.white,
//                                                   child: sig.value == '_'
//                                                       ? Container(
//                                                           child: Image.asset(
//                                                             "assets/images/signature_.png",
//                                                             width: 240,
//                                                             height: 150,
//                                                           ),
//                                                         )
//                                                       : Container(
//                                                           width: MediaQuery.of(
//                                                                   context)
//                                                               .size
//                                                               .width,
//                                                           color: Colors.white,
//                                                           //color: Colors.grey[300],
//                                                           child: Image.memory(
//                                                             base64Decode(
//                                                               sig.value
//                                                                   .replaceAll(
//                                                                 "data:image/png;base64,",
//                                                                 "",
//                                                               ),
//                                                             ),
//                                                             width: 240,
//                                                             height: 150,
//                                                             // fit: BoxFit.fitWidth,
//                                                           ),
//                                                         ))),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       valueListenable: sig,
//                                       child: SizedBox(),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               onTap: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return StatefulBuilder(
//                                       builder: (context, setState) {
//                                         return AlertDialog(
//                                           //title: Text("Sign Here"),
//                                           content: Container(
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 .8,
//                                             height: 300,
//                                             //color: Colors.grey[300],
//                                             child: Padding(
//                                               padding: EdgeInsets.symmetric(
//                                                   horizontal: 30, vertical: 10),
//                                               child: ReactiveForm(
//                                                 formGroup: formSignature,
//                                                 child: Column(
//                                                   children: <Widget>[
//                                                     ReactiveSignature<
//                                                         Uint8List>(
//                                                       exportBackgroundColor:
//                                                           Color.fromARGB(255,
//                                                               255, 255, 255),
//                                                       height: 150,
//                                                       backgroundColor:
//                                                           Color.fromARGB(255,
//                                                               255, 255, 255),
//                                                       formControlName:
//                                                           'signature',
//                                                       decoration:
//                                                           const InputDecoration(
//                                                         labelText: 'Signature',
//                                                         // border: OutlineInputBorder(),
//                                                         helperText: '',
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 16),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           actions: <Widget>[
//                                             TextButton(
//                                               onPressed: () =>
//                                                   Navigator.pop(context),
//                                               child: Text("Cancel"),
//                                             ),
//                                             TextButton(
//                                               onPressed: () {
//                                                 if (formSignature.valid) {
//                                                   Navigator.pop(context);
//                                                   var signature1 = formSignature
//                                                           .value['signature']!
//                                                       as Uint8List;

//                                                   var signature_ =
//                                                       "uint8ListTob64(signature1)";

//                                                   String _sig = signature_;

//                                                   setState(() {
//                                                     sig.value = _sig;
//                                                   });
//                                                 }
//                                               },
//                                               child: Text("Save"),
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                             TextButton(
//                                 onPressed: () {
//                                   showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         return AlertDialog(
//                                           content: Container(
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 .8,
//                                             height: 50,
//                                             child: Text(
//                                                 "Set Inspection End Time as $new_assessment_end_date"),
//                                           ),
//                                           title: Text("Inspection End Time"),
//                                           actions: <Widget>[
//                                             TextButton(
//                                               onPressed: () =>
//                                                   Navigator.pop(context),
//                                               child: Text("Cancel"),
//                                             ),
//                                             TextButton(
//                                               onPressed: () async {
//                                                 // setState(() {
//                                                 //   formRecomendation
//                                                 //       .control(
//                                                 //       'assessment_end_date').value = new_assessment_end_date;
//                                                 // });
//                                                 DateTime now = DateTime.now();
//                                                 String end_date = DateFormat(
//                                                         'yyyy-MM-dd kk:mm:ss')
//                                                     .format(now);
//                                                 setState(() {
//                                                   endtime = end_date;
//                                                   print(
//                                                       "This is the end date: $endtime");
//                                                 });
//                                                 // ScientISSTdb.instance
//                                                 //     .collection(ResponsesTime)
//                                                 //     .document(
//                                                 //         snap.id.toString() +
//                                                 //             "_FCLT")
//                                                 //     .set({
//                                                 //   "end_time": end_date,
//                                                 // });
//                                                 Navigator.pop(context);
//                                               },
//                                               child: Text("Save"),
//                                             ),
//                                           ],
//                                         );
//                                       });
//                                 },
//                                 child: Text(
//                                   "Generate End Date",
//                                   style: TextStyle(color: Color(0xff0A5533)),
//                                 )),
//                             const SizedBox(height: 50),
//                             // mystarttime.length < 5
//                             //     ? CustomButton(
//                             //         "Save", Color(0xff158DC9), Colors.white,
//                             //         () {
//                             //         showSimpleNotification(
//                             //             leading: Icon(Icons.warning),
//                             //             Text(
//                             //                 "WARNING !! Set Inspection Date!!."),
//                             //             background: Colors.orange,
//                             //             duration: Duration(seconds: 2));
//                             //         Navigator.pop(context);
//                             //       })
//                             //     : CustomButton(
//                             //         "Final Save",
//                             //         Color(0xff0A5533),
//                             //         Colors.white,
//                             //         () async {
//                             //           SharedPreferences prefs =
//                             //               await SharedPreferences.getInstance();

//                             //           DateTime now = DateTime.now();
//                             //           String end_date =
//                             //               DateFormat('yyyy-MM-dd kk:mm:ss')
//                             //                   .format(now);
//                             //           setState(() {
//                             //             endtime = end_date;
//                             //             print("This is the end date: $endtime");
//                             //           });
//                             //           int UserID = 0;
//                             //           String bearer = "";

//                             //           try {
//                             //             UserID = prefs.getInt('UserID')!;
//                             //           } catch (er) {}

//                             //           try {
//                             //             bearer = prefs.getString('bearer')!;
//                             //           } catch (er) {}

//                             //           //GLOBAL
//                             //           var _results = form_.value;

//                             //           var screening_details = [];

//                             //           for (i = 0;
//                             //               i <
//                             //                   snap.data!['checklist_items']
//                             //                       .length;
//                             //               i++) {
//                             //             if (true) {
//                             //               String id = snap
//                             //                   .data!['checklist_items'][i]['id']
//                             //                   .toString();
//                             //               var item_resp_id =
//                             //                   snap.data!['checklist_items'][i]
//                             //                       ['item_resp_id'];

//                             //               var yesno = id + "_" + "yesno";
//                             //               var details = id + "_" + "details";

//                             //               // var response = yesno;

//                             //               var checklist_item_id = id;

//                             //               var pass_status = _results[yesno];
//                             //               var comment = _results[details];

//                             //               var dt = {
//                             //                 "application_id":
//                             //                     application_id.toString(),
//                             //                 "application_code":
//                             //                     application_code.toString(),
//                             //                 "item_resp_id":
//                             //                     item_resp_id.toString(),
//                             //                 "created_by": UserID.toString(),
//                             //                 "checklist_item_id":
//                             //                     (checklist_item_id.toString()),
//                             //                 "pass_status":
//                             //                     pass_status.toString(),
//                             //                 "comment": comment.toString(),
//                             //                 "auditor_comment": null,
//                             //                 "auditorpass_status": 0,
//                             //                 "observation": null
//                             //               };

//                             //               try {
//                             //                 if (int.parse(
//                             //                       pass_status.toString(),
//                             //                     ) >
//                             //                     0) {
//                             //                   screening_details.add(dt);
//                             //                 }
//                             //               } catch (er) {}
//                             //             }

//                             //             //yesno
//                             //           }

//                             //           var SavefacilityChecklist = {
//                             //             "application_id":
//                             //                 application_id.toString(),
//                             //             "application_code":
//                             //                 application_code.toString(),
//                             //             "checklist_type": null,
//                             //             "screening_details":
//                             //                 jsonEncode(screening_details),
//                             //             "_token": bearer.toString(),
//                             //           };

//                             //           var OverallInspectionComment = {
//                             //             'stage_category_id': '2',
//                             //             'workflow_stage_id': workflow_stage_id,
//                             //             'assessment_start_date': starttime,
//                             //             'assessment_end_date': endtime,
//                             //             'risk_premise_type_id':
//                             //                 formRecomendation
//                             //                     .value['risk_premise_type_id']
//                             //                     .toString(),
//                             //             'premise_type_id': formRecomendation
//                             //                 .value['premise_type_id']
//                             //                 .toString(),
//                             //             'risk_premise_type_role_id':
//                             //                 formRecomendation.value[
//                             //                         'risk_premise_type_role_id']
//                             //                     .toString(),
//                             //             'recommendation_id': formRecomendation
//                             //                 .value['recommendation_id'],
//                             //             'recommendation_remarks':
//                             //                 formRecomendation
//                             //                     .value['recommendation_remarks']
//                             //                     .toString(),
//                             //             'remarks': formRecomendation.value[
//                             //                     'prev_manager_recommendation']
//                             //                 .toString(),
//                             //             'distance': formRecomendation
//                             //                 .value['distance']
//                             //                 .toString(),
//                             //             '_token': bearer.toString(),
//                             //             'application_code':
//                             //                 application_code.toString(),
//                             //             'user_id': UserID.toString(),
//                             //           };

//                             //           var newPersonnel = {
//                             //             "application_code":
//                             //                 application_code.toString(),
//                             //             "name": personnel_name.toString(),
//                             //             "reg_no": personnel_reg.toString(),
//                             //             "position_id": personnel_pos,
//                             //             "qualification_id": personnel_qul,
//                             //             "premise_id": premise_id,
//                             //             "signature": sig.value
//                             //           };

//                             //           var exisitingPersonel = {
//                             //             "application_id":
//                             //                 application_id.toString(),
//                             //             "application_code":
//                             //                 application_code.toString(),
//                             //             "_token": bearer.toString(),
//                             //             "personnel_id": personnel_id,
//                             //             "premise_id": premise_id,
//                             //             // "signature": sig.value,
//                             //           };

//                             //           var SubmitDetails = {
//                             //             'application_id':
//                             //                 application_id.toString(),
//                             //             'application_code':
//                             //                 application_code.toString(),
//                             //             'section_id': section_id.toString(),
//                             //             'module_id': module_id.toString(),
//                             //             'sub_module_id':
//                             //                 sub_module_id.toString(),
//                             //             'remarks': formSubmission
//                             //                 .value['remarks']
//                             //                 .toString(),
//                             //             'process_id': process_id.toString(),
//                             //             'action': formSubmission.value['action']
//                             //                 .toString(),
//                             //             'responsible_user': formSubmission
//                             //                 .value['responsible_user']
//                             //                 .toString(),
//                             //             'curr_stage_id':
//                             //                 curr_stage_id.toString(),
//                             //             'next_stage': next_stage.toString(),
//                             //             'is_dataammendment_request': '0',
//                             //             'is_inspection_submission': '0',
//                             //             'is_external_usersubmission': '0',
//                             //             'user_id': UserID.toString(),
//                             //           };

//                             //           if (form_.valid &&
//                             //               formRecomendation.valid) {
//                             //             print(form_.value);

//                             //             ScientISSTdb.instance!
//                             //                 .collection(AssignedInspections)
//                             //                 .document(snap.id.toString())
//                             //                 .update(
//                             //               {
//                             //                 "isDone": "1",
//                             //               },
//                             //             );

//                             //             if (await ConnectivityWrapper
//                             //                 .instance.isConnected) {
//                             //               showModalBottomSheet(
//                             //                 context: context,
//                             //                 builder: (context) {
//                             //                   return Wrap(
//                             //                     children: [
//                             //                       ListTile(
//                             //                           leading: Icon(Icons.copy),
//                             //                           title:
//                             //                               Text('Save as Draft'),
//                             //                           onTap: () {
//                             //                             // Navigator.pop(context);
//                             //                             showSimpleNotification(
//                             //                                 leading: Icon(Icons
//                             //                                     .check_circle_rounded),
//                             //                                 Text(
//                             //                                     "Saved Application as draft !!"),
//                             //                                 background:
//                             //                                     Colors.green,
//                             //                                 duration: Duration(
//                             //                                     seconds: 2));
//                             //                             Navigator.of(context)
//                             //                                 .pop();
//                             //                           }),
//                             //                       ListTile(
//                             //                           leading: Icon(
//                             //                               Icons.copy_sharp),
//                             //                           title: Text(
//                             //                               'Submit Application'),
//                             //                           onTap: () {
//                             //                             Navigator.pop(context);
//                             //                             showSimpleNotification(
//                             //                               leading: Icon(Icons
//                             //                                   .check_circle_outline),
//                             //                               Text(
//                             //                                   "Applications Submitted Successfully"),
//                             //                               background:
//                             //                                   Colors.green,
//                             //                               duration: Duration(
//                             //                                   seconds: 2),
//                             //                             );
//                             //                           }),
//                             //                       ListTile(
//                             //                         leading: Icon(Icons.cancel),
//                             //                         title: Text('Cancel'),
//                             //                         onTap: () {
//                             //                           Navigator.pop(context);
//                             //                         },
//                             //                       ),
//                             //                     ],
//                             //                   );
//                             //                 },
//                             //               );
//                             //             } else {
//                             //               // print(SavefacilityChecklist);
//                             //               ScientISSTdb.instance
//                             //                   .collection(Responses)
//                             //                   .document(
//                             //                       snap.id.toString() + "_FCLT")
//                             //                   .set({
//                             //                 "type": "_FCLT",
//                             //                 "id": snap.id,
//                             //                 "form": form_.value,
//                             //                 "formRecomendation":
//                             //                     formRecomendation.value,
//                             //                 "formSignature": sig.value,
//                             //                 "SavefacilityChecklist":
//                             //                     SavefacilityChecklist,
//                             //                 "OverallInspectionComment":
//                             //                     OverallInspectionComment,
//                             //                 "personnel_id": personnel_id,
//                             //                 "newPersonnel": newPersonnel,
//                             //                 "exisitingPersonel":
//                             //                     exisitingPersonel,
//                             //                 "SubmitDetails": SubmitDetails
//                             //               });

//                             //               showSimpleNotification(
//                             //                   Text("Saved as a draft"),
//                             //                   background: Colors.green,
//                             //                   duration: Duration(seconds: 2));
//                             //               Navigator.of(context).pop();
//                             //             }
//                             //           } else {
//                             //             form_.markAllAsTouched();
//                             //             formRecomendation.markAllAsTouched();
//                             //           }
//                             //         },
//                             //       ),
//                             const SizedBox(height: 20.0),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       );
//     }

//     ProgressDialog pd = ProgressDialog(context: context);

//     pd.show(
//       max: 50,
//       msg: 'loading Inspection...',
//       hideValue: true,
//       closeWithDelay: 50,

//       /// Assign the type of progress bar.
//       progressType: ProgressType.normal,
//     );

//     await Future.delayed(Duration(seconds: 1));

//     pd.close();

//     if (starttime.length > 5) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => Scaffold(
//                   key: UniqueKey(),
//                   appBar: AppBar(
//                     elevation: 0,
//                     title: Text("Inspections"),
//                     backgroundColor: Color(0xff0A5533),
//                   ),
//                   body: SingleChildScrollView(child: widget(starttime)),
//                 )),
//       );
//     } else {
//       DateTime now = DateTime.now();
//       String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
//       CoolAlert.show(
//               width: 240,
//               context: context,
//               type: CoolAlertType.confirm,
//               backgroundColor: Theme.of(context).primaryColor,
//               title: starttime,
//               cancelBtnText: "No",
//               confirmBtnText: "Yes",
//               text:
//                   "Inspection Start time has not been set. Do you want to use current Time $formattedDate} as the Start Time",
//               onConfirmBtnTap: () {
//                 starttime = formattedDate;
//                 // ScientISSTdb.instance
//                 //     .collection(ResponsesTime)
//                 //     .document(snap.id.toString() + "_FCLT")
//                 //     .set({"start_time": formattedDate, "end_time": endtime});
//               },
//               onCancelBtnTap: () {})
//           .then((value) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => Scaffold(
//                     key: UniqueKey(),
//                     appBar: AppBar(
//                       elevation: 0,
//                       title: Text("Inspection Form"),
//                     ),
//                     body: SingleChildScrollView(child: widget(starttime)),
//                   )),
//         );
//       });
//     }
//     return;
//   }

//   List<String> _filteredData = [];
//   String _query = '';

//   void search(String query) {
//     print(_query);

//     setState(
//       () {
//         _query = query;

//         _filteredData = checklistTypeNames
//             .where(
//               (item) => item.toLowerCase().contains(
//                     query.toLowerCase(),
//                   ),
//             )
//             .toList();
//         // print(_filteredData);
//       },
//     );
//   }

//   Future<void> _pendingInspections() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     int isDone;
//     isDone = prefs.getInt("isDone")!;

//     if (isDone == null) {
//       print("HERE");
//     } else {
//       print("HERE1");
//     }
//   }

//   Future<void> _savedInspections() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     int isDone;
//     isDone = prefs.getInt("isDone")!;

//     print(isDone);

//     if (isDone == null) {
//       print("HERE2");
//     } else {
//       print("HERE3");
//     }
//   }

//   int isDone = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: FutureBuilder(
//           future: ScientISSTdb.instance
//               .collection('inspections')
//               .orderBy("id", descending: false)
//               .getDocuments(),
//           builder: (BuildContext context,
//               AsyncSnapshot<List<DocumentSnapshot>> snap) {
//             if (snap == null || snap.hasError || snap.data == null) {
//               return Container(
//                 child: Center(child: CircularProgressIndicator()),
//               );
//             } else if (snap.data!.length < 1) {
//               return Text("no data");
//             } else {
//               if (snap.hasData) {
//                 List pendingData = [];
//               } else {}
//               return DefaultTabController(
//                 length: 2,
//                 initialIndex: 0,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Container(
//                       color: Colors.white,
//                       child: TabBar(
//                         onTap: (x) {
//                           setState(() {
//                             isDone = x;
//                           });
//                         },
//                         isScrollable: true,
//                         unselectedLabelColor: Colors.grey,
//                         indicatorSize: TabBarIndicatorSize.tab,
//                         labelStyle: TextStyle(fontSize: 15),
//                         // tabAlignment: TabAlignment.start,
//                         tabs: [
//                           Tab(icon: Icon(Icons.receipt), text: 'PENDING '),
//                           Tab(
//                               icon: Icon(Icons.edit_note_rounded),
//                               text: 'WORKED ON'),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       color: Colors.white,
//                       height: 10,
//                       child: TabBarView(
//                         children: [
//                           SizedBox(),
//                           SizedBox(),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: RefreshIndicator(
//                         onRefresh: _pendingInspections,
//                         child: Container(
//                           color: Colors.white,
//                           child: ListView.builder(
//                               itemCount: snap.data!.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 bool isVisibility = false;
//                                 try {
//                                   if (snap.data![index].data!['isDone']
//                                               .toString() ==
//                                           "1" &&
//                                       isDone == 1) {
//                                     isVisibility = true;
//                                   } else if (isDone == 0 &&
//                                       (snap.data![index].data!['isDone']
//                                               .toString() !=
//                                           "1")) {
//                                     isVisibility = true;
//                                   } else {
//                                     isVisibility = false;
//                                   }
//                                 } catch (e) {
//                                   isVisibility = false;
//                                 }

//                                 return Visibility(
//                                   visible: isVisibility,
//                                   child: Slidable(
//                                     // Specify a key if the Slidable is dismissible.
//                                     key: ValueKey(index),

//                                     // The end action pane is the one at the right or the bottom side.
//                                     endActionPane: ActionPane(
//                                       motion: ScrollMotion(),
//                                       children: [
//                                         SlidableAction(
//                                           // An action can be bigger than the others.
//                                           flex: 2,
//                                           onPressed: (context) async {
//                                             final prefs =
//                                                 await SharedPreferences
//                                                     .getInstance();
//                                             await prefs.setString(
//                                                 'inspectionID',
//                                                 snap.data![index]
//                                                     .data!['main_details']["id"]
//                                                     .toString());
//                                             // Print the entire document's data to the console
//                                             // print("Data for inspection ID ${snap.data![index].data['main_details']["id"]}:");
//                                             // print('This is the document data${snap.data![index].data}');
//                                             // debugPrint("${snap.data![index].data}");
//                                             loadForm(
//                                                 snap.data![index],
//                                                 snap.data![index]
//                                                     .data['main_details']["id"]
//                                                     .toString());
//                                           },
//                                           backgroundColor: Colors.transparent,
//                                           foregroundColor: Colors.blue,
//                                           icon: Icons.edit,
//                                           label: 'Inspect',
//                                         ),
//                                         SlidableAction(
//                                           onPressed: (context) async {
//                                             final prefs =
//                                                 await SharedPreferences
//                                                     .getInstance();
//                                             await prefs.setString(
//                                                 'inspectionID',
//                                                 snap.data![index]
//                                                     .data!['main_details']["id"]
//                                                     .toString());

//                                             await prefs.setInt(
//                                                 'inspectionIDType', 1);
//                                             // Navigator.push(
//                                             //   context,
//                                             //   MaterialPageRoute(
//                                             //       builder: (context) =>
//                                             //           InspectionTabs()),
//                                             // );

//                                             return;
//                                           },
//                                           backgroundColor: Colors.transparent,
//                                           foregroundColor: Colors.grey,
//                                           icon: Icons.more_horiz_outlined,
//                                           label: 'Details',
//                                         ),
//                                       ],
//                                     ),

//                                     child: ListTile(
//                                         title: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "FL/25/code_0001",
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 20),
//                                             ),
//                                             Text(
//                                               "mediplus pha",
//                                             ),
//                                           ],
//                                         ),
//                                         subtitle: Text(
//                                           "Medplus Pharmaceuticals",
//                                         ),
//                                         onTap: () async {
//                                           print("listtile index");
//                                           print(index);
//                                         }),
//                                   ),
//                                 );
//                               }),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
