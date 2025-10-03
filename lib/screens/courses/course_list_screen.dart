import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/attendance_tab_content.dart';
import '../../widgets/reports_tab_content.dart';
import '../../widgets/about_tab_content.dart';
import '../../widgets/custom_dialog.dart';
import '../../models/course.dart';
import 'add_course_screen.dart';
import 'edit_course_screen.dart';
import 'duplicate_course_screen.dart';
import '../students/student_list_screen.dart';

class CourseListScreen extends StatefulWidget {
  static const String routeName = '/course-list';

  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Shared App Header
            const AppHeader(),

            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildCoursesTab(),
                  const AttendanceTabContent(),
                  const ReportsTabContent(),
                  const AboutTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, const Color(0xFFF8FAFC)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment_outlined),
              activeIcon: Icon(Icons.assessment),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesTab() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        return SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Courses',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${courseProvider.courses.length} courses available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Add Course Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AddCourseScreen.routeName);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Courses List
              Expanded(
                child:
                    courseProvider.courses.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No courses yet',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first course to get started\nwith attendance management',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AddCourseScreen.routeName);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Course'),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: courseProvider.courses.length,
                          itemBuilder: (context, index) {
                            final course = courseProvider.courses[index];
                            return CourseCard(
                              course: course,
                              onTap: () {
                                courseProvider.selectCourse(course);
                                Navigator.of(
                                  context,
                                ).pushNamed(StudentListScreen.routeName);
                              },
                              onEdit: () => _editCourse(course),
                              onDelete: () => _deleteCourse(course),
                              onDuplicate: () => _duplicateCourse(course),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editCourse(Course course) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final courseKey = courseProvider.getCourseKey(course);

    if (courseKey != null) {
      Navigator.of(context).pushNamed(
        EditCourseScreen.routeName,
        arguments: {'course': course, 'key': courseKey},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not find course to edit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCourse(Course course) {
    showDialog(
      context: context,
      builder:
          (context) => CustomDialog(
            title: 'Delete Course',
            content:
                'Are you sure you want to delete "${course.name}"? This action cannot be undone.',
            confirmText: 'Delete',
            confirmColor: Colors.red,
            onConfirm: () {
              final courseProvider = Provider.of<CourseProvider>(
                context,
                listen: false,
              );
              final courseKey = courseProvider.getCourseKey(course);
              if (courseKey != null) {
                courseProvider.deleteCourse(courseKey);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Course "${course.name}" deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
    );
  }

  void _duplicateCourse(Course course) {
    Navigator.of(
      context,
    ).pushNamed(DuplicateCourseScreen.routeName, arguments: course);
  }
}
