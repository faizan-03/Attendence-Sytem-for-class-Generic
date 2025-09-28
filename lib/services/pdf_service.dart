import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../models/course.dart';
import '../models/student.dart';
import '../models/attendance.dart';

// Conditional imports
import 'pdf_service_web.dart'
    if (dart.library.io) 'pdf_service_mobile.dart'
    as platform_service;

class PdfService {
  static Future<void> generateAttendanceReport(
    Course course,
    List<Student> students,
    List<AttendanceRecord> attendanceRecords,
  ) async {
    try {
      final pdf = pw.Document();

      // For each attendance record, create a separate report
      for (final record in attendanceRecords) {
        // Calculate totals for this session
        final presentStudents = <Student>[];
        final absentStudents = <Student>[];

        // Map student IDs to attendance status
        for (final student in students) {
          // Get the student's Hive key from the student provider
          final studentKey = course.studentIds[students.indexOf(student)];
          final isPresent = record.studentStatus[studentKey] ?? false;

          if (isPresent) {
            presentStudents.add(student);
          } else {
            absentStudents.add(student);
          }
        }

        final totalPresent = presentStudents.length;
        final totalAbsent = absentStudents.length;
        final totalStudents = students.length;

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context context) {
              return [
                // Centered Header
                pw.Center(
                  child: pw.Text(
                    'Attendance Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),

                // Course Information
                pw.Text(
                  'Course: ${course.code} - ${course.name}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Department: ${course.department}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Semester: ${course.semester} | Section: ${course.section}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Instructor: ${course.instructor}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(record.date))}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Class Type: ${record.effectiveClassType}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 30),

                // Student Attendance Table
                pw.Table.fromTextArray(
                  context: context,
                  data: [
                    // Table headers
                    ['S.No', 'Roll Number', 'Student Name', 'Status'],
                    // Student data
                    ...students.asMap().entries.map((entry) {
                      final index = entry.key;
                      final student = entry.value;
                      final studentKey = course.studentIds[index];
                      final isPresent =
                          record.studentStatus[studentKey] ?? false;

                      return [
                        '${index + 1}',
                        student.roll,
                        student.name,
                        isPresent ? 'Present' : 'Absent',
                      ];
                    }).toList(),
                  ],
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 11),
                  cellHeight: 35,
                  cellAlignments: {
                    0: pw.Alignment.center,
                    1: pw.Alignment.center,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.center,
                  },
                ),

                pw.SizedBox(height: 30),

                // Summary Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(5),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Summary',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total Students:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('$totalStudents'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Present:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green800,
                            ),
                          ),
                          pw.Text(
                            '$totalPresent',
                            style: const pw.TextStyle(
                              color: PdfColors.green800,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Absent:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.Text(
                            '$totalAbsent',
                            style: const pw.TextStyle(color: PdfColors.red800),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Attendance Percentage:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            '${totalStudents > 0 ? (totalPresent / totalStudents * 100).toStringAsFixed(1) : 0}%',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Spacer to push generated date to bottom
                pw.SizedBox(height: 50),
              ];
            },
            footer: (pw.Context context) {
              return pw.Container(
                alignment: pw.Alignment.bottomRight,
                margin: const pw.EdgeInsets.only(top: 20),
                child: pw.Text(
                  'Generated on: ${DateFormat('MMMM d, yyyy \'at\' h:mm a').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              );
            },
          ),
        );
      }

      // Generate PDF bytes
      final Uint8List pdfBytes = await pdf.save();

      // Use platform-specific service to save/download PDF
      final fileName =
          '${course.code}_attendance_${DateFormat('yyyy_MM_dd').format(DateTime.now())}';
      await platform_service.PlatformPdfService.savePdf(pdfBytes, fileName);
    } catch (e) {
      // If there's an error, rethrow it so the UI can handle it
      throw Exception('Error generating PDF: $e');
    }
  }
}
