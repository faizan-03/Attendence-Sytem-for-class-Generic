import 'package:hive/hive.dart';

import '../models/course.dart';
import '../models/student.dart';
import '../models/attendance.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  // Hive boxes
  late Box<Course> _courseBox;
  late Box<Student> _studentBox;
  late Box<AttendanceRecord> _attendanceBox;

  Future<void> init() async {
    _courseBox = Hive.box<Course>('courses');
    _studentBox = Hive.box<Student>('students');
    _attendanceBox = Hive.box<AttendanceRecord>('attendance');
  }

  // ================= COURSES =================
  List<Course> getAllCourses() => _courseBox.values.toList();

  Future<void> addCourse(Course course) async {
    await _courseBox.add(course);
  }

  Future<void> updateCourse(int key, Course course) async {
    await _courseBox.put(key, course);
  }

  Future<void> deleteCourse(int key) async {
    await _courseBox.delete(key);
  }

  // ================= STUDENTS =================
  List<Student> getAllStudents() => _studentBox.values.toList();

  Future<int> addStudent(Student student) async {
    return await _studentBox.add(student);
  }

  Future<void> updateStudent(int key, Student student) async {
    await _studentBox.put(key, student);
  }

  Future<void> deleteStudent(int key) async {
    await _studentBox.delete(key);
  }

  // ================= ATTENDANCE =================
  List<AttendanceRecord> getAttendanceForCourse(int courseId) {
    return _attendanceBox.values
        .where((record) => record.courseId == courseId)
        .toList();
  }

  AttendanceRecord? getAttendanceByDate(int courseId, String date) {
    return _attendanceBox.values.firstWhere(
      (record) => record.courseId == courseId && record.date == date,
      orElse: () => AttendanceRecord(courseId: -1, date: '', studentStatus: {}),
    );
  }

  Future<void> addAttendance(AttendanceRecord record) async {
    await _attendanceBox.add(record);
  }

  Future<void> updateAttendance(int key, AttendanceRecord record) async {
    await _attendanceBox.put(key, record);
  }

  Future<void> deleteAttendance(int key) async {
    await _attendanceBox.delete(key);
  }
}
