import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  Box<Student>? _studentBox;
  List<Student> _students = [];
  int? _selectedCourseId;

  List<Student> get students => _students;
  int? get selectedCourseId => _selectedCourseId;

  Future<void> init() async {
    _studentBox = Hive.box<Student>('students');
    loadStudents();
  }

  void loadStudents() {
    if (_studentBox != null) {
      _students = _studentBox!.values.toList();
      notifyListeners();
    }
  }

  Future<int> addStudent(Student student) async {
    if (_studentBox != null) {
      int key = await _studentBox!.add(student);
      loadStudents();
      return key;
    }
    return -1;
  }

  Future<void> updateStudent(int key, Student student) async {
    if (_studentBox != null) {
      await _studentBox!.put(key, student);
      loadStudents();
    }
  }

  Future<void> deleteStudent(int key) async {
    if (_studentBox != null) {
      await _studentBox!.delete(key);
      loadStudents();
    }
  }

  void setSelectedCourseId(int courseId) {
    _selectedCourseId = courseId;
    notifyListeners();
  }

  List<Student> getStudentsForCourse(List<int> studentIds) {
    return _students.where((student) {
      int? studentKey = getStudentKey(student);
      return studentKey != null && studentIds.contains(studentKey);
    }).toList();
  }

  Student? getStudentByKey(int key) {
    return _studentBox?.get(key);
  }

  Student? getStudentById(int id) {
    return getStudentByKey(id);
  }

  int? getStudentKey(Student student) {
    for (int i = 0; i < _studentBox!.length; i++) {
      if (_studentBox!.getAt(i) == student) {
        return _studentBox!.keyAt(i) as int?;
      }
    }
    return null;
  }
}
