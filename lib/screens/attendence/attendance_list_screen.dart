import 'package:flutter/material.dart';
import '../../widgets/attendance_tab_content.dart';

class AttendanceListScreen extends StatelessWidget {
  static const String routeName = '/attendance-list';

  const AttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Attendance Management'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: const AttendanceTabContent(),
    );
  }
}
