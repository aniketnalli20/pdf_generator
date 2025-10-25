// Platform-specific PdfService exports
// - IO (Android/iOS/Windows/macOS/Linux): pdf_service_io.dart
// - Web: pdf_service_web.dart
// - Fallback: pdf_service_stub.dart

export 'pdf_service_stub.dart'
    if (dart.library.io) 'pdf_service_io.dart'
    if (dart.library.html) 'pdf_service_web.dart';