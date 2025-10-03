import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class PlatformPdfService {
  static Future<void> savePdf(Uint8List pdfBytes, String fileName) async {
    try {
      // Create a blob from the PDF bytes
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create a download link and trigger the download
      html.document.createElement('a')
        ..setAttribute('href', url)
        ..setAttribute('download', '$fileName.pdf')
        ..click();

      // Clean up the URL
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      // Log error in debug mode only
      assert(() {
        debugPrint('Error saving PDF: $e');
        return true;
      }());
      rethrow;
    }
  }
}
