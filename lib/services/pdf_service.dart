import 'dart:io';
import 'package:simple_pdf_compression/simple_pdf_compression.dart' as spc;
import 'package:pdf_combiner/pdf_combiner.dart';

class PdfService {
  const PdfService();

  Future<File> compress(
    File inputPdf, {
    int? thresholdSize,
    int? quality,
  }) async {
    final output = await spc.compressPdf(
      inputPdf,
      thresholdSize: thresholdSize,
      quality: quality,
    );
    return output;
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