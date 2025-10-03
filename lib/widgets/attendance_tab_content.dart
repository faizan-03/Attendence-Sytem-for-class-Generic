import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/course.dart';
import '../models/attendance.dart';
import '../providers/course_provider.dart';
import '../providers/attendance_provider.dart';
import '../screens/attendence/edit_attendance_screen.dart';

class AttendanceTabContent extends StatefulWidget {
  const AttendanceTabContent({super.key});

  @override
  State<AttendanceTabContent> createState() => _AttendanceTabContentState();
}

class _AttendanceTabContentState extends State<AttendanceTabContent> {
  int? _selectedCourseKey;
  DateTime _selectedDate = DateTime.now();
  String _selectedClassType = 'Regular';

  final List<String> _classTypes = ['Regular', 'Lab', 'Makeup'];

  // Helper method to get the selected course from its key
  Course? _getSelectedCourse(CourseProvider courseProvider) {
    if (_selectedCourseKey == null) return null;
    return courseProvider.getCourseByKey(_selectedCourseKey!);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CourseProvider, AttendanceProvider>(
      builder: (context, courseProvider, attendanceProvider, child) {
        // Debug: Check if courses are loaded (debug mode only)
        assert(() {
          debugPrint(
            'Attendance Tab - Courses count: ${courseProvider.courses.length}',
          );
          return true;
        }());

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

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    const Text(
                      'Attendance Management',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mark and track student attendance',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Course Selection Card
                    Container(
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
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.1),
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

                            if (courseProvider.courses.isEmpty)
                              // Empty state
                              Container(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
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
                                      'Create a course first to manage attendance',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            else
                              // Course dropdown
                              DropdownButtonFormField<int>(
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
                                  hintText: 'Choose a course to get started',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                items:
                                    courseProvider.courses.map((course) {
                                      final courseKey = courseProvider
                                          .getCourseKey(course);
                                      return DropdownMenuItem(
                                        value: courseKey,
                                        child: Text(
                                          '${course.code} - ${course.name}${course.section.isNotEmpty ? ' (Sec ${course.section})' : ''}',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (courseKey) {
                                  setState(() {
                                    _selectedCourseKey = courseKey;
                                  });
                                  if (courseKey != null) {
                                    attendanceProvider.setSelectedCourseId(
                                      courseKey,
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (_selectedCourseKey != null) ...[
                      const SizedBox(height: 20),

                      // Date and Class Type Selection
                      Row(
                        children: [
                          Expanded(
                            child: Container(
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
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                    attendanceProvider.setSelectedDate(
                                      DateFormat('yyyy-MM-dd').format(date),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF6366F1,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.calendar_today,
                                              color: Color(0xFF6366F1),
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Date',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        DateFormat(
                                          'MMM d, yyyy',
                                        ).format(_selectedDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // Show bottom sheet or dialog to select class type
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder:
                                          (context) => Container(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Select Class Type',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                ..._classTypes.map((type) {
                                                  return ListTile(
                                                    leading: Icon(
                                                      Icons.class_,
                                                      color:
                                                          _selectedClassType ==
                                                                  type
                                                              ? const Color(
                                                                0xFF6366F1,
                                                              )
                                                              : Colors.grey,
                                                    ),
                                                    title: Text(type),
                                                    trailing:
                                                        _selectedClassType ==
                                                                type
                                                            ? const Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color: Color(
                                                                0xFF6366F1,
                                                              ),
                                                            )
                                                            : null,
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedClassType =
                                                            type;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF6366F1,
                                                ).withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.class_,
                                                color: Color(0xFF6366F1),
                                                size: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Class Type',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _selectedClassType,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Generate Session Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            final selectedCourse = _getSelectedCourse(
                              courseProvider,
                            );
                            if (selectedCourse == null) return;

                            // Navigate to attendance screen
                            Navigator.pushNamed(
                              context,
                              '/mark-attendance',
                              arguments: {
                                'course': selectedCourse,
                                'date': DateFormat(
                                  'yyyy-MM-dd',
                                ).format(_selectedDate),
                                'classType': _selectedClassType,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.how_to_reg_rounded,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  'Generate Session',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Recent Sessions
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.grey.shade50],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
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
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.history_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Recent Sessions',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Display actual recent sessions
                              _buildRecentSessionsList(
                                attendanceProvider,
                                courseProvider,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ], // Close the if (_selectedCourse != null) list
                  ], // Close the inner Column's children list
                ), // Close the inner Column
              ), // Close the SingleChildScrollView
            ), // Close the Expanded
          ], // Close the outer Column's children list
        ); // Close the outer Column
      }, // Close the builder function
    ); // Close the Consumer2
  }

  Widget _buildRecentSessionsList(
    AttendanceProvider attendanceProvider,
    CourseProvider courseProvider,
  ) {
    final selectedCourse = _getSelectedCourse(courseProvider);
    if (selectedCourse == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No recent sessions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Get course key for the selected course
    final courseKey = _selectedCourseKey!;

    // Get recent attendance records for this course
    final courseAttendance = attendanceProvider.getAttendanceForCourse(
      courseKey,
    );

    // Group by date and class type to show unique sessions
    final Map<String, AttendanceRecord> uniqueSessions = {};
    for (final record in courseAttendance) {
      final sessionKey = '${record.date}_${record.effectiveClassType}';
      uniqueSessions[sessionKey] = record;
    }

    // Sort by date (most recent first)
    final sortedSessions =
        uniqueSessions.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    // Take only the last 5 sessions
    final recentSessions = sortedSessions.take(5).toList();

    if (recentSessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No recent sessions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mark attendance to see sessions here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentSessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = recentSessions[index];

        // Calculate attendance statistics for this session
        final totalStudents = record.studentStatus.length;
        final presentStudents =
            record.studentStatus.values.where((present) => present).length;
        final attendancePercentage =
            totalStudents > 0
                ? (presentStudents / totalStudents * 100).round()
                : 0;

        return Container(
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
                // Left side - Attendance Percentage
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          attendancePercentage == 100
                              ? [
                                const Color(
                                  0xFFFFD700,
                                ), // Gold gradient for perfect attendance
                                const Color(0xFFFFA500),
                              ]
                              : attendancePercentage >= 80
                              ? [
                                const Color(0xFF10B981),
                                const Color(0xFF059669),
                              ]
                              : attendancePercentage >= 60
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
                        color: (attendancePercentage == 100
                                ? const Color(0xFFFFD700)
                                : attendancePercentage >= 80
                                ? const Color(0xFF10B981)
                                : attendancePercentage >= 60
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
                    child:
                        attendancePercentage == 100
                            ? Tooltip(
                              message: 'Perfect Attendance!',
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.school_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  Positioned(
                                    top: 1,
                                    right: 1,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            spreadRadius: 0,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFFFD700),
                                        size: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Text(
                              '$attendancePercentage%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 16),

                // Session Details - Expanded to prevent overflow
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
                        'Present: $presentStudents/$totalStudents students',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        'Class Type: ${record.effectiveClassType}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Right side - Edit Button
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(
                              EditAttendanceScreen.routeName,
                              arguments: {
                                'course': selectedCourse,
                                'date': record.date,
                                'attendance': record,
                                'classType': record.effectiveClassType,
                              },
                            )
                            .then((_) {
                              setState(() {});
                            });
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit_rounded,
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
  }
}
