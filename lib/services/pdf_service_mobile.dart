import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PlatformPdfService {
  static Future<void> savePdf(Uint8List pdfBytes, String fileName) async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');

      // Write the PDF bytes to the file
      await file.writeAsBytes(pdfBytes);

      // Share the file using share_plus
      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/pdf'),
      ], text: 'Attendance Report');
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }
}
