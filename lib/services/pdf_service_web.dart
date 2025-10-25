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

  // Convenience alias for API consistency on web
  Future<String?> compress(
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

  Future<String> mergeAuto(List<String> inputPaths) async {
    throw UnsupportedError('Merging PDFs is not supported on web in this build.');
  }

  Future<String> proposeMergeOutputPath(List<String> inputPaths) async {
    throw UnsupportedError('Merging PDFs is not supported on web in this build.');
  }
}