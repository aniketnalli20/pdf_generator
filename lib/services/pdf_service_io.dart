import 'dart:io';
import 'package:simple_pdf_compression/simple_pdf_compression.dart';
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
    // Skip compression if a threshold is provided and the file is already small.
    if (thresholdSize != null) {
      final size = await file.length();
      if (size < thresholdSize) {
        return inputPath;
      }
    }
    final output = await compressPdf(
      file,
      thresholdSize: thresholdSize,
      quality: quality ?? 60,
    );
    return output.path;
  }

  Future<String> merge(
    List<String> inputPaths,
    String outputPath,
  ) async {
    final response = await PdfCombiner.mergeMultiplePDFs(
      inputPaths: inputPaths,
      outputPath: outputPath,
    );

    if (response.status == PdfCombinerStatus.success) {
      // pdf_combiner returns the merged file path under `response.response` for mergeMultiplePDFs.
      // Fall back to `outputPath` if the library only returns status.
      final merged = response.response;
      if (merged is String && merged.isNotEmpty) {
        return merged;
      }
      return outputPath;
    }

    // Bubble up a meaningful error.
    throw Exception(response.message ?? 'Merge failed');
  }
}