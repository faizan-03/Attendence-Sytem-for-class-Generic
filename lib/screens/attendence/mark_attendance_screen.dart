import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/course_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/course.dart';
import '../../models/student.dart';
import '../../models/attendance.dart';

class MarkAttendanceScreen extends StatefulWidget {
  static const String routeName = '/mark-attendance';

  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  Course? _course;
  String? _date;
  String? _classType;
  Map<int, bool> _attendanceStatus = {};
  bool _isLoading = true;
  List<Student> _students = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_course == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _course = args['course'] as Course?;
        _date = args['date'] as String?;
        _classType = args['classType'] as String? ?? 'Regular Class';
        _loadStudentsAndAttendance();
      }
    }
  }

  void _loadStudentsAndAttendance() {
    if (_course == null || _date == null) return;

    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    _students = studentProvider.getStudentsForCourse(_course!.studentIds);

    final courseKey = courseProvider.getCourseKey(_course!);
    if (courseKey != null) {
      final existingAttendance = attendanceProvider.getAttendanceByDate(
        courseKey,
        _date!,
      );

      if (existingAttendance != null) {
        _attendanceStatus = Map.from(existingAttendance.studentStatus);
      } else {
        for (int studentId in _course!.studentIds) {
          _attendanceStatus[studentId] = false;
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAttendance() async {
    if (_course == null || _date == null) return;

    try {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      final courseKey = courseProvider.getCourseKey(_course!);
      if (courseKey != null) {
        final attendanceRecord = AttendanceRecord(
          courseId: courseKey,
          date: _date!,
          studentStatus: _attendanceStatus,
          classType: _classType,
        );

        await attendanceProvider.saveAttendance(attendanceRecord);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attendance: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_course == null || _date == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('Mark ${_classType ?? 'Attendance'}'),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Invalid course or date selection.')),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('Mark ${_classType ?? 'Attendance'}'),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final presentCount =
        _attendanceStatus.values.where((present) => present).length;
    final totalStudents = _students.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Mark ${_classType ?? 'Attendance'}'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saveAttendance,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Course Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _course!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Code: ${_course!.code} | ${_course!.instructor}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, MMM d, yyyy',
                            ).format(DateTime.parse(_date!)),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Class Type: ${_classType ?? 'Regular'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                presentCount == totalStudents
                                    ? [Colors.green, Colors.green[700]!]
                                    : presentCount > totalStudents / 2
                                    ? [Colors.orange, Colors.orange[700]!]
                                    : [Colors.red, Colors.red[700]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$presentCount/$totalStudents',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Actions
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          for (int studentId in _course!.studentIds) {
                            _attendanceStatus[studentId] = true;
                          }
                        });
                      },
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Mark All Present'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          for (int studentId in _course!.studentIds) {
                            _attendanceStatus[studentId] = false;
                          }
                        });
                      },
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text('Mark All Absent'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child:
                _students.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No students enrolled',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add students to this course first',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : Consumer<StudentProvider>(
                      builder: (context, studentProvider, child) {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final studentKey = studentProvider.getStudentKey(
                              student,
                            );

                            if (studentKey == null) {
                              return const SizedBox.shrink();
                            }

                            final isPresent =
                                _attendanceStatus[studentKey] ?? false;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Student Avatar
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              isPresent
                                                  ? [
                                                    Colors.green,
                                                    Colors.green[700]!,
                                                  ]
                                                  : [
                                                    Colors.red,
                                                    Colors.red[700]!,
                                                  ],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          student.name.isNotEmpty
                                              ? student.name[0].toUpperCase()
                                              : 'S',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Student Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Roll No: ${student.roll}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Status Toggle
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isPresent
                                                    ? Colors.green[50]
                                                    : Colors.red[50],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isPresent
                                                      ? Colors.green[200]!
                                                      : Colors.red[200]!,
                                            ),
                                          ),
                                          child: Text(
                                            isPresent ? 'Present' : 'Absent',
                                            style: TextStyle(
                                              color:
                                                  isPresent
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Checkbox(
                                          value: isPresent,
                                          onChanged: (value) {
                                            setState(() {
                                              _attendanceStatus[studentKey] =
                                                  value ?? false;
                                            });
                                          },
                                          activeColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
