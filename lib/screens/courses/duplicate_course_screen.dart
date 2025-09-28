import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';

class DuplicateCourseScreen extends StatefulWidget {
  static const String routeName = '/duplicate-course';

  const DuplicateCourseScreen({super.key});

  @override
  State<DuplicateCourseScreen> createState() => _DuplicateCourseScreenState();
}

class _DuplicateCourseScreenState extends State<DuplicateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _instructorController = TextEditingController();
  final _departmentController = TextEditingController();
  final _semesterController = TextEditingController();
  final _sectionController = TextEditingController();

  Course? _originalCourse;
  Course? _selectedCourse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_originalCourse == null) {
      _originalCourse = ModalRoute.of(context)?.settings.arguments as Course?;
      if (_originalCourse != null) {
        _populateFields(_originalCourse!);
      }
    }
  }

  void _populateFields(Course course) {
    _nameController.text = course.name;
    _codeController.text = course.code;
    _instructorController.text = course.instructor;

    // Handle potential null values for new fields (for migration)
    try {
      _departmentController.text = course.department;
      _semesterController.text = course.semester;
      _sectionController.text = course.section;
    } catch (e) {
      // Set default values if fields don't exist (for migration)
      _departmentController.text = 'General';
      _semesterController.text = 'Current';
      _sectionController.text = 'A';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _duplicateCourse() async {
    if (_formKey.currentState!.validate()) {
      final sourceCourse = _originalCourse ?? _selectedCourse;

      final duplicatedCourse = Course(
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        instructor: _instructorController.text.trim(),
        department: _departmentController.text.trim(),
        semester: _semesterController.text.trim(),
        section: _sectionController.text.trim(),
        studentIds:
            sourceCourse != null
                ? List<int>.from(
                  sourceCourse.studentIds,
                ) // Copy all students from source
                : [], // Empty student list if no source
      );

      try {
        await Provider.of<CourseProvider>(
          context,
          listen: false,
        ).addCourse(duplicatedCourse);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Course duplicated successfully with all students!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error duplicating course: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicate Course'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_originalCourse == null) ...[
                    // Course selection dropdown if not passed as argument
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Course to Duplicate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Course>(
                              value: _selectedCourse,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Choose a course to duplicate',
                              ),
                              items:
                                  courseProvider.courses.map((course) {
                                    return DropdownMenuItem(
                                      value: course,
                                      child: Text(
                                        '${course.code} - ${course.name}',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (course) {
                                setState(() {
                                  _selectedCourse = course;
                                  if (course != null) {
                                    _populateFields(course);
                                  }
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a course to duplicate';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // Show original course info if passed as argument
                    Card(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Duplicating from:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_originalCourse!.code} - ${_originalCourse!.name}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Instructor: ${_originalCourse!.instructor}'),
                            Text(
                              'Students: ${_originalCourse!.studentIds.length}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Text(
                    'New Course Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                      hintText: 'e.g., Introduction to Computer Science',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a course name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Course Code',
                      hintText: 'e.g., CS101',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a course code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _instructorController,
                    decoration: const InputDecoration(
                      labelText: 'Instructor Name',
                      hintText: 'e.g., Dr. John Smith',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the instructor name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Department Field
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      hintText: 'e.g., Computer Science, Mathematics',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Semester and Section in a row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _semesterController,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                            hintText: 'e.g., Fall 2024',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter semester';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _sectionController,
                          decoration: const InputDecoration(
                            labelText: 'Section',
                            hintText: 'e.g., A, B, C',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.class_),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter section';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_selectedCourse != null || _originalCourse != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This will copy ${(_selectedCourse ?? _originalCourse)!.studentIds.length} students from the original course.',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton(
                    onPressed: _duplicateCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Duplicate Course',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
