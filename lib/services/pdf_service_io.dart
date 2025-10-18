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
    final output = await compressPdf(
      file,
      thresholdSize: thresholdSize,
      quality: quality,
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
    // Response handling based on pdf_combiner 4.x
    if (response.status.name.toLowerCase() == 'success') {
      // Different versions may expose output file path via 'outputPath' or 'filePath'
      // Try common fields via toString or known getters
      final result = response.toString();
      // Fallback to provided outputPath when library returns only status
      return outputPath;
    }
    throw Exception('Merge failed: ${response.message ?? response.toString()}');
  }
}