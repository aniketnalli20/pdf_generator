class PdfService {
  const PdfService();

  Future<String?> compressPath(
    String inputPath, {
    int? thresholdSize,
    int? quality,
  }) async {
    return null;
  }

  // Convenience alias for API consistency on unsupported platforms
  Future<String?> compress(
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

  Future<String> mergeAuto(List<String> inputPaths) async {
    throw UnsupportedError('PdfService is not implemented for this platform.');
  }

  Future<String> proposeMergeOutputPath(List<String> inputPaths) async {
    throw UnsupportedError('PdfService is not implemented for this platform.');
  }
}