import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/course.dart';

class CourseProvider extends ChangeNotifier {
  Box<Course>? _courseBox;
  List<Course> _courses = [];
  Course? _selectedCourse;

  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;

  Future<void> init() async {
    _courseBox = Hive.box<Course>('courses');

    // Development: Clear corrupted data if needed
    try {
      loadCourses();
    } catch (e) {
      print('Error during initial load, clearing database: $e');
      await clearAllCourses();
      loadCourses();
    }
  }

  void loadCourses() {
    if (_courseBox != null) {
      try {
        _courses = _courseBox!.values.toList();
        notifyListeners();
      } catch (e) {
        print('Error loading courses: $e');
        // If there's an error loading courses, try to recover
        _courses = [];
        _recoverCourses();
        notifyListeners();
      }
    }
  }

  Future<void> _recoverCourses() async {
    if (_courseBox != null) {
      // Try to recover courses by clearing corrupted data
      try {
        await _courseBox!.clear();
        print('Cleared corrupted course data');
      } catch (e) {
        print('Error clearing course data: $e');
      }
    }
  }

  // Development helper method to clear all courses
  Future<void> clearAllCourses() async {
    if (_courseBox != null) {
      await _courseBox!.clear();
      _courses = [];
      notifyListeners();
      print('All courses cleared');
    }
  }

  Future<void> addCourse(Course course) async {
    if (_courseBox != null) {
      await _courseBox!.add(course);
      loadCourses();
    }
  }

  Future<void> updateCourse(int key, Course course) async {
    if (_courseBox != null) {
      await _courseBox!.put(key, course);
      loadCourses();
    }
  }

  Future<void> deleteCourse(int key) async {
    if (_courseBox != null) {
      await _courseBox!.delete(key);
      loadCourses();
    }
  }

  void selectCourse(Course course) {
    _selectedCourse = course;
    notifyListeners();
  }

  Course? getCourseByKey(int key) {
    return _courseBox?.get(key);
  }

  int? getCourseKey(Course course) {
    for (int i = 0; i < _courseBox!.length; i++) {
      if (_courseBox!.getAt(i) == course) {
        return _courseBox!.keyAt(i) as int?;
      }
    }
    return null;
  }
}
