import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  const PdfService();

  // Web implementation: accept data URI (data:application/pdf;base64,...) and trigger browser download
  Future<String?> compressPath(
    String inputPath, {
    int? thresholdSize,
    int? quality,
  }) async {
    try {
      final uri = Uri.parse(inputPath);
      if (uri.data == null) return null;
      final bytes = uri.data!.contentAsBytes();

      // Optional threshold check
      if (thresholdSize != null && bytes.length < thresholdSize) {
        return inputPath; // No compression needed
      }

      final document = PdfDocument(inputBytes: bytes);
      document.fileStructure.incrementalUpdate = false;
      document.compressionLevel = PdfCompressionLevel.best;
      final outBytes = await document.save();
      document.dispose();

      final blob = html.Blob([outBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      // Suggest a filename using timestamp
      final filename = 'compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final anchor = html.AnchorElement(href: url)
        ..download = filename
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
      return filename;
    } catch (e) {
      throw Exception('Web compress failed: $e');
    }
  }

  // Convenience alias for API consistency on web
  Future<String?> compress(
    String inputPath, {
    int? thresholdSize,
    int? quality,
  }) async {
    return compressPath(inputPath, thresholdSize: thresholdSize, quality: quality);
  }

  // For web, merging multiple PDFs requires a backend or a more advanced client-side parser.
  // This method prepares for backend-based merge: send data URIs to your API and trigger download of the merged file.
  Future<String> merge(
    List<String> inputPaths,
    String outputPath,
  ) async {
    throw UnsupportedError('Merging PDFs is not supported on web in this build. Consider backend-based merge.');
  }

  Future<String> mergeAuto(List<String> inputPaths) async {
    throw UnsupportedError('Merging PDFs is not supported on web in this build. Consider backend-based merge.');
  }

  Future<String> proposeMergeOutputPath(List<String> inputPaths) async {
    // Suggest a generic name for web
    return 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }
}