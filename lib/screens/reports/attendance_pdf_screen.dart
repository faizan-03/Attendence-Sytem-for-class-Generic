import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/course_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/course.dart';
import '../../models/attendance.dart';
import '../../services/pdf_service.dart';

class AttendancePdfScreen extends StatefulWidget {
  static const String routeName = '/attendance-pdf';

  const AttendancePdfScreen({super.key});

  @override
  State<AttendancePdfScreen> createState() => _AttendancePdfScreenState();
}

class _AttendancePdfScreenState extends State<AttendancePdfScreen> {
  Course? _selectedCourse;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Consumer3<CourseProvider, StudentProvider, AttendanceProvider>(
        builder: (
          context,
          courseProvider,
          studentProvider,
          attendanceProvider,
          child,
        ) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Selection Card
                _buildCourseSelection(courseProvider),
                const SizedBox(height: 24),

                // Statistics Display
                if (_selectedCourse != null) ...[
                  _buildStatistics(courseProvider, attendanceProvider),
                  const SizedBox(height: 24),
                  _buildRecentRecords(courseProvider, attendanceProvider),
                  const SizedBox(height: 24),
                  _buildGeneratePdfButton(
                    courseProvider,
                    studentProvider,
                    attendanceProvider,
                  ),
                ] else
                  _buildEmptyState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseSelection(CourseProvider courseProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Course',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Course>(
              value: _selectedCourse,
              decoration: InputDecoration(
                hintText: 'Choose a course',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              items:
                  courseProvider.courses.map((course) {
                    return DropdownMenuItem(
                      value: course,
                      child: Text('${course.code} - ${course.name}'),
                    );
                  }).toList(),
              onChanged: (course) {
                setState(() {
                  _selectedCourse = course;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(
    CourseProvider courseProvider,
    AttendanceProvider attendanceProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Course Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<AttendanceProvider>(
              builder: (context, provider, child) {
                final courseKey = courseProvider.getCourseKey(_selectedCourse!);
                final stats =
                    courseKey != null
                        ? provider.getAttendanceStats(
                          courseKey,
                          _selectedCourse!.studentIds,
                        )
                        : {'attendance_percentage': 0.0, 'total_classes': 0.0};

                final attendancePercentage =
                    stats['attendance_percentage'] ?? 0.0;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Students',
                        '${_selectedCourse!.studentIds.length}',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Classes',
                        '${stats['total_classes']?.toInt() ?? 0}',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Average Attendance',
                        '${attendancePercentage.toStringAsFixed(1)}%',
                        attendancePercentage >= 75 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.2)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords(
    CourseProvider courseProvider,
    AttendanceProvider attendanceProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            const Text(
              'Recent Attendance Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: Consumer<AttendanceProvider>(
            builder: (context, provider, child) {
              final courseKey = courseProvider.getCourseKey(_selectedCourse!);
              final attendanceRecords =
                  courseKey != null
                      ? provider.getAttendanceForCourse(courseKey)
                      : <AttendanceRecord>[];

              if (attendanceRecords.isEmpty) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start marking attendance to see records here',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort records by date (newest first)
              attendanceRecords.sort(
                (a, b) =>
                    DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
              );

              return ListView.builder(
                shrinkWrap: true,
                itemCount: attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = attendanceRecords[index];
                  final presentCount =
                      record.studentStatus.values
                          .where((present) => present)
                          .length;
                  final totalStudents = record.studentStatus.length;
                  final attendancePercentage =
                      totalStudents > 0
                          ? (presentCount / totalStudents * 100)
                          : 0.0;

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
                          // Attendance Percentage Circle
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    attendancePercentage >= 75
                                        ? [Colors.green, Colors.green[700]!]
                                        : attendancePercentage >= 50
                                        ? [Colors.orange, Colors.orange[700]!]
                                        : [Colors.red, Colors.red[700]!],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '${attendancePercentage.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Date and Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEEE, MMMM d, yyyy',
                                  ).format(DateTime.parse(record.date)),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Present: $presentCount/$totalStudents students',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Class Type: ${record.classType}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratePdfButton(
    CourseProvider courseProvider,
    StudentProvider studentProvider,
    AttendanceProvider attendanceProvider,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed:
            _isGenerating
                ? null
                : () async {
                  setState(() {
                    _isGenerating = true;
                  });

                  try {
                    final courseKey = courseProvider.getCourseKey(
                      _selectedCourse!,
                    );
                    if (courseKey != null) {
                      final attendanceRecords = attendanceProvider
                          .getAttendanceForCourse(courseKey);

                      // Get students for this course using the student IDs
                      final courseStudents =
                          studentProvider.students
                              .where(
                                (student) =>
                                    _selectedCourse!.studentIds.contains(
                                      studentProvider.getStudentKey(student),
                                    ),
                              )
                              .toList();

                      // Call PDF service with correct parameter order
                      await PdfService.generateAttendanceReport(
                        _selectedCourse!,
                        courseStudents,
                        attendanceRecords,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF report generated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error generating PDF: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isGenerating = false;
                      });
                    }
                  }
                },
        icon:
            _isGenerating
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: Text(
          _isGenerating ? 'Generating PDF...' : 'Generate PDF Report',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Select a course to generate reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a course from the dropdown above to view statistics and generate PDF reports',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
