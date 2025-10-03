import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import 'models/course.dart';
import 'models/student.dart';
import 'models/attendance.dart';

// Providers
import 'providers/course_provider.dart';
import 'providers/student_provider.dart';
import 'providers/attendance_provider.dart';

// Screens
import 'screens/courses/course_list_screen.dart';
import 'screens/courses/add_course_screen.dart';
import 'screens/courses/edit_course_screen.dart';
import 'screens/courses/duplicate_course_screen.dart';
import 'screens/students/student_list_screen.dart';
import 'screens/students/add_student_screen.dart';
import 'screens/students/edit_student_screen.dart';
import 'screens/attendence/mark_attendance_screen.dart';
import 'screens/attendence/edit_attendance_screen.dart';
import 'screens/attendence/attendance_list_screen.dart';

// Widgets
import 'widgets/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());

  // Open boxes
  await Hive.openBox<Course>('courses');
  await Hive.openBox<Student>('students');
  await Hive.openBox<AttendanceRecord>('attendance');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()..init()),
        ChangeNotifierProvider(create: (_) => StudentProvider()..init()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()..init()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Attendance System',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          primaryColor: const Color(0xFF6366F1), // Modern indigo
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
        home: const AppInitializer(),
        routes: {
          AddCourseScreen.routeName: (_) => const AddCourseScreen(),
          EditCourseScreen.routeName: (_) => const EditCourseScreen(),
          DuplicateCourseScreen.routeName: (_) => const DuplicateCourseScreen(),
          StudentListScreen.routeName: (_) => const StudentListScreen(),
          AddStudentScreen.routeName: (_) => const AddStudentScreen(),
          EditStudentScreen.routeName: (_) => const EditStudentScreen(),
          MarkAttendanceScreen.routeName: (_) => const MarkAttendanceScreen(),
          EditAttendanceScreen.routeName: (_) => const EditAttendanceScreen(),
          AttendanceListScreen.routeName: (_) => const AttendanceListScreen(),
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    setState(() {
      _showOnboarding = !onboardingCompleted;
      _isLoading = false;
    });
  }

  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return const CourseListScreen();
  }
}
