class PdfService {
  const PdfService();

  Future<String?> compressPath(
    String inputPath, {
    int? thresholdSize,
    int? quality,
  }) async {
    // Not supported on web in current implementation.
    return null;
  }

  Future<String> merge(
    List<String> inputPaths,
    String outputPath,
  ) async {
    throw UnsupportedError('Merging PDFs is not supported on web in this build.');
  }
}