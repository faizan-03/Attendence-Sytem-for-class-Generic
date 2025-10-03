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
      // Log error in debug mode only
      assert(() {
        debugPrint('Error during initial load, clearing database: $e');
        return true;
      }());
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
        // Log error in debug mode only
        assert(() {
          debugPrint('Error loading courses: $e');
          return true;
        }());
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
        assert(() {
          debugPrint('Cleared corrupted course data');
          return true;
        }());
      } catch (e) {
        assert(() {
          debugPrint('Error clearing course data: $e');
          return true;
        }());
      }
    }
  }

  // Development helper method to clear all courses
  Future<void> clearAllCourses() async {
    if (_courseBox != null) {
      await _courseBox!.clear();
      _courses = [];
      notifyListeners();
      assert(() {
        debugPrint('All courses cleared');
        return true;
      }());
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
