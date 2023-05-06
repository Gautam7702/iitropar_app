// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'dart:convert';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';

class addCoursecsv extends StatefulWidget {
  const addCoursecsv({super.key});

  @override
  State<addCoursecsv> createState() => _addCoursecsvState();
}

class _addCoursecsvState extends State<addCoursecsv> {
  List<List<dynamic>> _data = [];
  String? filePath;
  bool checkData(List<List<dynamic>> events) {
    int len = events.length;
    for (int i = 1; i < len; i++) {
      int num_of_courses = events[i].length;
      for (int j = 1; j < num_of_courses; j++) {
        print(events[i][j]);
      }
    }
    return false;
  }

  void uploadData(List<List<dynamic>> events) {
    //toDo
    int len = events.length;
    for (int i = 1; i < len; i++) {
      List<dynamic> courses = [];
      int num_of_courses = events[i].length;
      for (int j = 1; j < num_of_courses; j++) {
        if (events[i][j] != "") courses.add(events[i][j]);
      }
      firebaseDatabase.addCourseFB(events[i][0], courses);
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploaded data sucessfully")));
  }

  void _pickFile(ScaffoldMessengerState sm) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    print(result.files.first.name);
    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    print(fields[0]);
    if (!verifyHeader(fields[0])) {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv incorrect!")));
    } else {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv correct!")));
      uploadData(fields);
    }
    setState(() {
      _data = fields;
    });
  }

  bool verifyHeader(List<dynamic> header) {
    return header[0] == "entryNumber";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          automaticallyImplyLeading: false,
          title: buildTitleBar("ADD COURSES USING CSV", context),
        ),
        body: Center(
          child: Column(children: [
            const SizedBox(height: 50),
            ElevatedButton(
              child: const Text("Upload FIle"),
              onPressed: () {
                _pickFile(ScaffoldMessenger.of(context));
              },
            ),
            const SizedBox(height: 50),
            const Text('1 . Accepted CSV format is given below'),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image.asset('assets/admin_course_format.png'),
            ),
            const SizedBox(height: 5),
            const Text(
                '2 . Ensure that you enter valid entryNumber and courseCode'),
          ]),
        ));
  }
}
