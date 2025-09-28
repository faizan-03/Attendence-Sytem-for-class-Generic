import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/attendance.dart';

class AttendanceProvider extends ChangeNotifier {
  Box<AttendanceRecord>? _attendanceBox;
  List<AttendanceRecord> _attendanceRecords = [];
  String _selectedDate = '';
  int? _selectedCourseId;

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  String get selectedDate => _selectedDate;
  int? get selectedCourseId => _selectedCourseId;

  Future<void> init() async {
    _attendanceBox = Hive.box<AttendanceRecord>('attendance');
    loadAttendanceRecords();
  }

  void loadAttendanceRecords() {
    if (_attendanceBox != null) {
      _attendanceRecords = _attendanceBox!.values.toList();
      notifyListeners();
    }
  }

  Future<void> saveAttendance(AttendanceRecord record) async {
    if (_attendanceBox != null) {
      // Check if attendance for this date, course, and class type already exists
      AttendanceRecord? existing = getAttendanceByDateAndType(
        record.courseId,
        record.date,
        record.effectiveClassType,
      );
      if (existing != null) {
        // Update existing record
        int? key = getAttendanceKey(existing);
        if (key != null) {
          await _attendanceBox!.put(key, record);
        }
      } else {
        // Add new record
        await _attendanceBox!.add(record);
      }
      loadAttendanceRecords();
    }
  }

  Future<void> updateAttendanceRecord(int key, AttendanceRecord record) async {
    if (_attendanceBox != null) {
      await _attendanceBox!.put(key, record);
      loadAttendanceRecords();
    }
  }

  Future<void> deleteAttendance(int key) async {
    if (_attendanceBox != null) {
      await _attendanceBox!.delete(key);
      loadAttendanceRecords();
    }
  }

  List<AttendanceRecord> getAttendanceForCourse(int courseId) {
    return _attendanceRecords
        .where((record) => record.courseId == courseId)
        .toList();
  }

  AttendanceRecord? getAttendanceByDate(int courseId, String date) {
    try {
      return _attendanceRecords.firstWhere(
        (record) => record.courseId == courseId && record.date == date,
      );
    } catch (e) {
      return null;
    }
  }

  AttendanceRecord? getAttendanceByDateAndType(
    int courseId,
    String date,
    String classType,
  ) {
    try {
      return _attendanceRecords.firstWhere(
        (record) =>
            record.courseId == courseId &&
            record.date == date &&
            record.effectiveClassType == classType,
      );
    } catch (e) {
      return null;
    }
  }

  List<AttendanceRecord> getAttendanceByDateOnly(int courseId, String date) {
    return _attendanceRecords
        .where((record) => record.courseId == courseId && record.date == date)
        .toList();
  }

  void setSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedCourseId(int courseId) {
    _selectedCourseId = courseId;
    notifyListeners();
  }

  int? getAttendanceKey(AttendanceRecord attendance) {
    if (_attendanceBox == null) return null;

    for (int i = 0; i < _attendanceBox!.length; i++) {
      final record = _attendanceBox!.getAt(i);
      if (record != null &&
          record.courseId == attendance.courseId &&
          record.date == attendance.date &&
          record.effectiveClassType == attendance.effectiveClassType) {
        return _attendanceBox!.keyAt(i) as int?;
      }
    }
    return null;
  }

  // Calculate attendance statistics
  Map<String, double> getAttendanceStats(int courseId, List<int> studentIds) {
    List<AttendanceRecord> courseAttendance = getAttendanceForCourse(courseId);
    if (courseAttendance.isEmpty) {
      return {'attendance_percentage': 0.0, 'total_classes': 0.0};
    }

    int totalClasses = courseAttendance.length;
    Map<int, int> studentAttendanceCount = {};

    for (int studentId in studentIds) {
      studentAttendanceCount[studentId] = 0;
    }

    for (AttendanceRecord record in courseAttendance) {
      record.studentStatus.forEach((studentId, isPresent) {
        if (isPresent && studentIds.contains(studentId)) {
          studentAttendanceCount[studentId] =
              (studentAttendanceCount[studentId] ?? 0) + 1;
        }
      });
    }

    double averageAttendance = 0.0;
    if (studentIds.isNotEmpty && totalClasses > 0) {
      int totalPresentCount = studentAttendanceCount.values.fold(
        0,
        (sum, count) => sum + count,
      );
      averageAttendance =
          totalPresentCount / (studentIds.length * totalClasses);
    }

    return {
      'attendance_percentage': averageAttendance * 100,
      'total_classes': totalClasses.toDouble(),
    };
  }

  // Calculate attendance percentage for a specific student
  double getStudentAttendancePercentage(int courseId, int studentId) {
    List<AttendanceRecord> courseAttendance = getAttendanceForCourse(courseId);
    if (courseAttendance.isEmpty) {
      return 0.0;
    }

    int totalClasses = courseAttendance.length;
    int presentCount = 0;

    for (AttendanceRecord record in courseAttendance) {
      if (record.studentStatus[studentId] == true) {
        presentCount++;
      }
    }

    return totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0.0;
  }
}
