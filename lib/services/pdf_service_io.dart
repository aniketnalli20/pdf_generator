import 'dart:io';
import 'package:simple_pdf_compression/simple_pdf_compression.dart' as spc;
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
    final output = await spc.compressPdf(
      file,
      thresholdSize: thresholdSize,
      quality: quality ?? 60,
    );
    return output.path;
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
}