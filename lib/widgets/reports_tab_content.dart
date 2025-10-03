import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/course_provider.dart';
import '../providers/student_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/course.dart';
import '../models/attendance.dart';
import '../services/pdf_service.dart';

class ReportsTabContent extends StatefulWidget {
  const ReportsTabContent({super.key});

  @override
  State<ReportsTabContent> createState() => _ReportsTabContentState();
}

class _ReportsTabContentState extends State<ReportsTabContent> {
  int? _selectedCourseKey;
  String? _generatingSessionId;

  Course? _getSelectedCourse(CourseProvider courseProvider) {
    if (_selectedCourseKey == null) return null;
    return courseProvider.getCourseByKey(_selectedCourseKey!);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CourseProvider, StudentProvider, AttendanceProvider>(
      builder: (
        context,
        courseProvider,
        studentProvider,
        attendanceProvider,
        child,
      ) {
        // Debug: Check if courses are loaded
        print('Reports Tab - Courses count: ${courseProvider.courses.length}');

        // Validate and reset selected course key if it's no longer valid
        if (_selectedCourseKey != null) {
          final selectedCourse = courseProvider.getCourseByKey(
            _selectedCourseKey!,
          );
          if (selectedCourse == null) {
            // The selected course was deleted, reset the selection
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedCourseKey = null;
                });
              }
            });
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Reports',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Generate PDF reports for attendance sessions',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Course Selection
              _buildCourseDropdown(courseProvider, attendanceProvider),

              if (_selectedCourseKey != null) ...[
                const SizedBox(height: 24),
                // Section 1: Course Overview & Statistics
                _buildStatistics(courseProvider, attendanceProvider),
                const SizedBox(height: 24),
                // Section 2: Course Sections & Details
                _buildCourseSections(courseProvider),
                const SizedBox(height: 24),
                // Section 3: Recent Attendance Sessions
                _buildRecentSessions(
                  courseProvider,
                  studentProvider,
                  attendanceProvider,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseDropdown(
    CourseProvider courseProvider,
    AttendanceProvider attendanceProvider,
  ) {
    if (courseProvider.courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
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
            children: [
              Icon(Icons.school_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No courses available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add courses first to generate reports',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Course',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<int>(
                value:
                    _selectedCourseKey != null &&
                            courseProvider.getCourseByKey(
                                  _selectedCourseKey!,
                                ) !=
                                null
                        ? _selectedCourseKey
                        : null,
                isExpanded: true,
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
                      final courseKey = courseProvider.getCourseKey(course);
                      final sectionText =
                          course.section.isNotEmpty
                              ? ' (Sec ${course.section})'
                              : '';
                      return DropdownMenuItem(
                        value: courseKey,
                        child: Text(
                          '${course.code} - ${course.name}$sectionText',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                onChanged: (courseKey) {
                  setState(() {
                    _selectedCourseKey = courseKey;
                  });
                },
              ),
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
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Course Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<AttendanceProvider>(
              builder: (context, provider, child) {
                final selectedCourse = _getSelectedCourse(courseProvider);
                if (selectedCourse == null) return const SizedBox.shrink();

                final courseKey = _selectedCourseKey!;
                final stats = provider.getAttendanceStats(
                  courseKey,
                  selectedCourse.studentIds,
                );

                final attendancePercentage =
                    stats['attendance_percentage'] ?? 0.0;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Use different layouts based on available width
                    if (constraints.maxWidth < 400) {
                      // Stack vertically on narrow screens
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Students',
                                  '${selectedCourse.studentIds.length}',
                                  const Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'Classes',
                                  '${stats['total_classes']?.toInt() ?? 0}',
                                  const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Average Attendance',
                            '${attendancePercentage.toStringAsFixed(1)}%',
                            attendancePercentage >= 75
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ],
                      );
                    } else {
                      // Use horizontal layout on wider screens
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Students',
                              '${selectedCourse.studentIds.length}',
                              const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Total Classes',
                              '${stats['total_classes']?.toInt() ?? 0}',
                              const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Avg Attendance',
                              '${attendancePercentage.toStringAsFixed(1)}%',
                              attendancePercentage >= 75
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      );
                    }
                  },
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
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(
    CourseProvider courseProvider,
    StudentProvider studentProvider,
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
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF6366F1),
                size: 16,
              ),
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
        Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            final selectedCourse = _getSelectedCourse(courseProvider);
            if (selectedCourse == null || _selectedCourseKey == null) {
              return const SizedBox.shrink();
            }

            final records = provider.getAttendanceForCourse(
              _selectedCourseKey!,
            );

            if (records.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
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
                    children: [
                      Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No attendance records found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mark attendance first to generate reports',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Sort records by date (newest first)
            records.sort(
              (a, b) =>
                  DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
            );

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final presentCount =
                    record.studentStatus.values
                        .where((present) => present)
                        .length;
                final totalStudents = record.studentStatus.length;
                final percentage =
                    totalStudents > 0
                        ? (presentCount / totalStudents * 100)
                        : 0.0;

                final sessionId =
                    '${record.courseId}_${record.date}_${record.effectiveClassType}';

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
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Attendance Percentage Circle
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  percentage >= 75
                                      ? [
                                        const Color(0xFF10B981),
                                        const Color(0xFF059669),
                                      ]
                                      : percentage >= 50
                                      ? [
                                        const Color(0xFFF59E0B),
                                        const Color(0xFFD97706),
                                      ]
                                      : [
                                        const Color(0xFFFF6B6B),
                                        const Color(0xFFEE5A52),
                                      ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: (percentage >= 75
                                        ? const Color(0xFF10B981)
                                        : percentage >= 50
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFFF6B6B))
                                    .withValues(alpha: 0.25),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${percentage.toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Session Details
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
                                  color: Colors.black87,
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
                                'Class Type: ${record.effectiveClassType}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Individual PDF Button
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  _generatingSessionId == sessionId
                                      ? null
                                      : () => _generatePdfForSession(
                                        record,
                                        sessionId,
                                        courseProvider,
                                        studentProvider,
                                        attendanceProvider,
                                      ),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.red, Color(0xFFDC2626)],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child:
                                      _generatingSessionId == sessionId
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Icon(
                                            Icons.picture_as_pdf,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                ),
                              ),
                            ),
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
      ],
    );
  }

  Widget _buildCourseSections(CourseProvider courseProvider) {
    final selectedCourse = _getSelectedCourse(courseProvider);
    if (selectedCourse == null) return const SizedBox.shrink();

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
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Color(0xFF3B82F6),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Course Sections',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Course Details Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[50]!, Colors.purple[50]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Course Code:', selectedCourse.code),
                  _buildDetailRow('Course Name:', selectedCourse.name),
                  _buildDetailRow('Instructor:', selectedCourse.instructor),
                  _buildDetailRow('Department:', selectedCourse.department),
                  _buildDetailRow('Semester:', selectedCourse.semester),
                  _buildDetailRow('Section:', selectedCourse.section),
                  _buildDetailRow(
                    'Enrolled Students:',
                    '${selectedCourse.studentIds.length}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdfForSession(
    AttendanceRecord record,
    String sessionId,
    CourseProvider courseProvider,
    StudentProvider studentProvider,
    AttendanceProvider attendanceProvider,
  ) async {
    setState(() {
      _generatingSessionId = sessionId;
    });

    try {
      // Get the selected course
      final selectedCourse = _getSelectedCourse(courseProvider);
      if (selectedCourse == null) return;

      // Get students for this course
      final courseStudents =
          studentProvider.students
              .where(
                (student) => selectedCourse.studentIds.contains(
                  studentProvider.getStudentKey(student),
                ),
              )
              .toList();

      // Generate PDF for this specific session
      await PdfService.generateAttendanceReport(
        selectedCourse,
        courseStudents,
        [record], // Only this specific record
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PDF report generated for ${DateFormat('MMM d, yyyy').format(DateTime.parse(record.date))}',
            ),
            backgroundColor: Colors.green,
          ),
        );
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
          _generatingSessionId = null;
        });
      }
    }
  }
}
