class PdfService {
  const PdfService();

  Future<String?> compressPath(
    String inputPath, {
    int? thresholdSize,
    int? quality,
  }) async {
    return null;
  }

  Future<String> merge(
    List<String> inputPaths,
    String outputPath,
  ) async {
    throw UnsupportedError('PdfService is not implemented for this platform.');
  }
}