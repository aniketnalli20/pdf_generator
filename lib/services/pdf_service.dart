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
    final output = await spc.compressPdf(
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
    if (response.status == PdfCombinerStatus.success) {
      return response.response;
    }
    throw Exception('Merge failed: ${response.message}');
  }
}