import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import '../models/student.dart';

class ImportResult {
  final List<Student> students;
  final List<String> errors;
  final int totalRows;
  final int successCount;

  ImportResult({
    required this.students,
    required this.errors,
    required this.totalRows,
    required this.successCount,
  });
}

class ImportService {
  /// Pick and import students from CSV or Excel file
  static Future<ImportResult?> importStudents() async {
    try {
      // Web-compatible file picker configuration
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
        withData: true, // Essential for web
        withReadStream: false, // Disable for web compatibility
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.bytes == null) {
          return ImportResult(
            students: [],
            errors: ['Unable to read file. Please try again.'],
            totalRows: 0,
            successCount: 0,
          );
        }

        // Check file extension
        String? extension = file.extension?.toLowerCase();
        String fileName = file.name.toLowerCase();

        // Determine file type and import
        if (extension == 'csv' || fileName.endsWith('.csv')) {
          return await _importFromCSV(file);
        } else if (extension == 'xlsx' ||
            extension == 'xls' ||
            fileName.endsWith('.xlsx') ||
            fileName.endsWith('.xls')) {
          return await _importFromExcel(file);
        } else {
          return ImportResult(
            students: [],
            errors: ['Unsupported file format. Please use CSV or Excel files.'],
            totalRows: 0,
            successCount: 0,
          );
        }
      }
      return null; // User cancelled
    } catch (e) {
      return ImportResult(
        students: [],
        errors: ['Error reading file: ${e.toString()}'],
        totalRows: 0,
        successCount: 0,
      );
    }
  }

  /// Import students from CSV file
  static Future<ImportResult> _importFromCSV(PlatformFile file) async {
    List<Student> students = [];
    List<String> errors = [];
    int totalRows = 0;

    try {
      String content;

      // Try to read the file content - prioritize file.bytes for cross-platform compatibility
      try {
        if (file.bytes != null) {
          content = String.fromCharCodes(file.bytes!);
        } else {
          throw Exception(
            'File bytes not available. Please try a different file.',
          );
        }
      } catch (e) {
        throw Exception('Failed to read file: ${e.toString()}');
      }

      if (content.trim().isEmpty) {
        return ImportResult(
          students: [],
          errors: ['File is empty or unreadable'],
          totalRows: 0,
          successCount: 0,
        );
      }

      // Parse CSV content
      List<List<dynamic>> csvData;
      try {
        csvData = const CsvToListConverter().convert(content);
      } catch (e) {
        throw Exception('Invalid CSV format: ${e.toString()}');
      }

      if (csvData.isEmpty) {
        return ImportResult(
          students: [],
          errors: ['No data found in CSV file'],
          totalRows: 0,
          successCount: 0,
        );
      }

      // Skip header row if it exists
      int startIndex = 0;
      if (csvData.isNotEmpty && _isHeaderRow(csvData.first)) {
        startIndex = 1;
      }

      // Process each data row
      for (int i = startIndex; i < csvData.length; i++) {
        totalRows++;
        List<dynamic> row = csvData[i];

        // Skip empty rows
        if (row.isEmpty ||
            row.every(
              (cell) => cell == null || cell.toString().trim().isEmpty,
            )) {
          continue;
        }

        try {
          Student? student = _parseStudentFromRow(row, i + 1);
          if (student != null) {
            students.add(student);
          }
        } catch (e) {
          errors.add('Row ${i + 1}: ${e.toString()}');
        }
      }
    } catch (e) {
      errors.add('Error parsing CSV: ${e.toString()}');
    }

    return ImportResult(
      students: students,
      errors: errors,
      totalRows: totalRows,
      successCount: students.length,
    );
  }

  /// Import students from Excel file
  static Future<ImportResult> _importFromExcel(PlatformFile file) async {
    List<Student> students = [];
    List<String> errors = [];
    int totalRows = 0;

    try {
      Uint8List bytes;

      // Try to read the file bytes
      try {
        if (file.bytes != null) {
          bytes = file.bytes!;
        } else {
          throw Exception(
            'Excel file bytes not available. Please try a different file.',
          );
        }
      } catch (e) {
        throw Exception('Failed to read Excel file: ${e.toString()}');
      }

      // Parse Excel file
      Excel excel;
      try {
        excel = Excel.decodeBytes(bytes);
      } catch (e) {
        throw Exception('Invalid Excel format: ${e.toString()}');
      }

      if (excel.tables.isEmpty) {
        return ImportResult(
          students: [],
          errors: ['Excel file has no sheets'],
          totalRows: 0,
          successCount: 0,
        );
      }

      // Use first sheet
      String sheetName = excel.tables.keys.first;
      Sheet? sheet = excel.tables[sheetName];

      if (sheet == null) {
        return ImportResult(
          students: [],
          errors: ['Unable to read Excel sheet'],
          totalRows: 0,
          successCount: 0,
        );
      }

      List<List<Data?>> rows = sheet.rows;
      if (rows.isEmpty) {
        return ImportResult(
          students: [],
          errors: ['Excel sheet is empty'],
          totalRows: 0,
          successCount: 0,
        );
      }

      // Skip header row if it exists
      int startIndex = 0;
      if (rows.isNotEmpty && _isExcelHeaderRow(rows.first)) {
        startIndex = 1;
      }

      // Process each data row
      for (int i = startIndex; i < rows.length; i++) {
        totalRows++;
        List<Data?> row = rows[i];

        // Skip empty rows
        if (row.isEmpty ||
            row.every(
              (cell) =>
                  cell?.value == null || cell!.value.toString().trim().isEmpty,
            )) {
          continue;
        }

        try {
          Student? student = _parseStudentFromExcelRow(row, i + 1);
          if (student != null) {
            students.add(student);
          }
        } catch (e) {
          errors.add('Row ${i + 1}: ${e.toString()}');
        }
      }
    } catch (e) {
      errors.add('Error parsing Excel: ${e.toString()}');
    }

    return ImportResult(
      students: students,
      errors: errors,
      totalRows: totalRows,
      successCount: students.length,
    );
  }

  /// Parse student from CSV row
  static Student? _parseStudentFromRow(List<dynamic> row, int rowNumber) {
    if (row.length < 2) {
      throw Exception('Insufficient data (need Name and Roll Number)');
    }

    String name = row[0]?.toString().trim() ?? '';
    String rollNumber = row[1]?.toString().trim() ?? '';

    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    if (rollNumber.isEmpty) {
      throw Exception('Roll Number cannot be empty');
    }

    // Optional fields
    String email = row.length > 2 ? (row[2]?.toString().trim() ?? '') : '';
    String phone = row.length > 3 ? (row[3]?.toString().trim() ?? '') : '';

    return Student(
      name: name,
      rollNumber: rollNumber,
      email: email.isEmpty ? null : email,
      phone: phone.isEmpty ? null : phone,
    );
  }

  /// Parse student from Excel row
  static Student? _parseStudentFromExcelRow(List<Data?> row, int rowNumber) {
    if (row.length < 2) {
      throw Exception('Insufficient data (need Name and Roll Number)');
    }

    String name = row[0]?.value?.toString().trim() ?? '';
    String rollNumber = row[1]?.value?.toString().trim() ?? '';

    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    if (rollNumber.isEmpty) {
      throw Exception('Roll Number cannot be empty');
    }

    // Optional fields
    String email =
        row.length > 2 ? (row[2]?.value?.toString().trim() ?? '') : '';
    String phone =
        row.length > 3 ? (row[3]?.value?.toString().trim() ?? '') : '';

    return Student(
      name: name,
      rollNumber: rollNumber,
      email: email.isEmpty ? null : email,
      phone: phone.isEmpty ? null : phone,
    );
  }

  /// Check if CSV row is a header row
  static bool _isHeaderRow(List<dynamic> row) {
    if (row.isEmpty) return false;
    String firstCell = row[0]?.toString().toLowerCase().trim() ?? '';
    return firstCell == 'name' ||
        firstCell == 'student name' ||
        firstCell == 'student' ||
        firstCell.contains('name');
  }

  /// Check if Excel row is a header row
  static bool _isExcelHeaderRow(List<Data?> row) {
    if (row.isEmpty) return false;
    String firstCell = row[0]?.value?.toString().toLowerCase().trim() ?? '';
    return firstCell == 'name' ||
        firstCell == 'student name' ||
        firstCell == 'student' ||
        firstCell.contains('name');
  }

  /// Generate sample CSV content for template
  static String generateSampleCSV() {
    return '''Name,Roll Number
John Doe,CS-001
Jane Smith,CS-002
Bob Johnson,CS-003''';
  }

  /// Get file format instructions
  static String getFormatInstructions() {
    return '''File Format Requirements:

CSV Format:
- First column: Student Name (required)
- Second column: Roll Number (required)
- Additional columns: Email, Phone (optional)

Excel Format:
- Same as CSV but in Excel file (.xlsx or .xls)
- Use the first sheet

Example:
Name,Roll Number
John Doe,CS-001
Jane Smith,CS-002

Notes:
- Header row is optional but recommended
- Empty rows will be skipped
- Each student must have both Name and Roll Number
- Roll numbers should be unique
- Invalid rows will be reported but won't stop the import''';
  }
}
