import 'dart:ui' show Offset;
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

  // Web merge: accepts a list of data URIs, combines pages via template approach, and triggers download
  Future<String> merge(
    List<String> inputPaths,
    String outputPath,
  ) async {
    if (inputPaths.length < 2) {
      throw ArgumentError('Need at least 2 PDFs to merge');
    }
    try {
      final PdfDocument newDocument = PdfDocument();
      PdfSection? section;

      for (final path in inputPaths) {
        final uri = Uri.parse(path);
        if (uri.data == null) {
          throw ArgumentError('Invalid data URI in inputPaths');
        }
        final Uint8List bytes = uri.data!.contentAsBytes();
        final PdfDocument loaded = PdfDocument(inputBytes: bytes);

        for (int i = 0; i < loaded.pages.count; i++) {
          final template = loaded.pages[i].createTemplate();
          // Create a new section if page settings differ
          if (section == null || section.pageSettings.size != template.size) {
            section = newDocument.sections!.add();
            section.pageSettings.size = template.size;
            section.pageSettings.margins.all = 0;
          }
          section.pages.add().graphics.drawPdfTemplate(template, const Offset(0, 0));
        }
        loaded.dispose();
      }

      final outBytes = await newDocument.save();
      newDocument.dispose();

      final blob = html.Blob([outBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final filename = outputPath.isNotEmpty
          ? outputPath
          : 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final anchor = html.AnchorElement(href: url)
        ..download = filename
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
      return filename;
    } catch (e) {
      throw Exception('Web merge failed: $e');
    }
  }

  Future<String> mergeAuto(List<String> inputPaths) async {
    final suggested = 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
    return merge(inputPaths, suggested);
  }

  Future<String> proposeMergeOutputPath(List<String> inputPaths) async {
    return 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }
}