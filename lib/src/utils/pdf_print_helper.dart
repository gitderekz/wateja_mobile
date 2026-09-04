// PDF and Print utility helper for Flutter mobile app
// Currently supports downloading PDFs from backend
// Future: integrate printing package for native print dialogs

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PdfPrintHelper {
  /// Download file from bytes and save to device storage
  static Future<String?> saveFile(String filename, Uint8List bytes) async {
    try {
      final dir = Directory.systemTemp.createTempSync('wateja_downloads_');
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Show snackbar notification
  static void showNotification(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// Future: Add printing support
  /// Requires: import 'package:printing/printing.dart';
  /// 
  /// static Future<void> printPdf(
  ///   BuildContext context,
  ///   String title,
  ///   Uint8List pdfBytes,
  /// ) async {
  ///   try {
  ///     await Printing.layoutPdf(
  ///       onLayout: (format) async => pdfBytes,
  ///       name: title,
  ///     );
  ///   } catch (e) {
  ///     showNotification(context, 'Print failed: $e', isError: true);
  ///   }
  /// }
}
