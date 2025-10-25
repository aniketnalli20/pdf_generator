import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf_combiner/pdf_combiner.dart';

class PdfService {
  const PdfService();

  Future<String?> compressPath(
    String inputPath, {
    int? thresholdSize,
    int? quality,
  }) async {
    final file = File(inputPath);
    if (!await file.exists()) {
      return null;
    }
    if (thresholdSize != null) {
      final size = await file.length();
      if (size < thresholdSize) {
        return inputPath;
      }
    }

    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    // Reduce size by disabling incremental updates and using strong compression
    document.fileStructure.incrementalUpdate = false;
    document.compressionLevel = PdfCompressionLevel.best;

    final outBytes = await document.save();
    document.dispose();

    final dir = file.parent;
    final name = file.uri.pathSegments.last;
    final base = name.endsWith('.pdf') ? name.substring(0, name.length - 4) : name;
    final outPath = dir.path + Platform.pathSeparator + '${base}_compressed.pdf';
    final outFile = File(outPath);
    await outFile.writeAsBytes(outBytes, flush: true);

    return outFile.path;
  }

  // Convenience alias for API consistency
  Future<String?> compress(
    String inputPath, {
    int? thresholdSize,
    int? quality,
  }) {
    return compressPath(
      inputPath,
      thresholdSize: thresholdSize,
      quality: quality,
    );
  }

  Future<String> merge(
    List<String> inputPaths,
    String outputPath,
  ) async {
    final response = await PdfCombiner.mergeMultiplePDFs(
      inputPaths: inputPaths,
      outputPath: outputPath,
    );

    // Handle both enum and string-based status representations
    final status = (response as dynamic).status;
    final isSuccess = status == 'success' || (status?.toString()?.endsWith('success') == true);
    if (isSuccess) {
      final r = response as dynamic;
      final merged = r.response ?? r.outputPath;
      if (merged is String && merged.isNotEmpty) {
        return merged;
      }
      return outputPath;
    }

    final message = (response as dynamic).message;
    throw Exception(message ?? 'Merge failed');
  }

  // New convenience method: auto-pick output path next to the first input
  Future<String> mergeAuto(List<String> inputPaths) async {
    if (inputPaths.isEmpty) {
      throw ArgumentError('No input PDFs provided');
    }
    final first = File(inputPaths.first);
    if (!await first.exists()) {
      throw ArgumentError('First input PDF does not exist: ${inputPaths.first}');
    }
    final dir = first.parent;
    var candidate = dir.path + Platform.pathSeparator + 'merged.pdf';
    var i = 1;
    while (await File(candidate).exists()) {
      candidate = dir.path + Platform.pathSeparator + 'merged_$i.pdf';
      i++;
      if (i > 999) break; // avoid endless loop
    }
    return merge(inputPaths, candidate);
  }

  Future<String> proposeMergeOutputPath(List<String> inputPaths) async {
    if (inputPaths.isEmpty) {
      throw ArgumentError('No input PDFs provided');
    }
    final first = File(inputPaths.first);
    if (!await first.exists()) {
      throw ArgumentError('First input PDF does not exist: ${inputPaths.first}');
    }
    final dir = first.parent;
    var candidate = dir.path + Platform.pathSeparator + 'merged.pdf';
    var i = 1;
    while (await File(candidate).exists()) {
      candidate = dir.path + Platform.pathSeparator + 'merged_$i.pdf';
      i++;
      if (i > 999) break;
    }
    return candidate;
  }
}