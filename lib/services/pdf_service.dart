export 'pdf_service_stub.dart'
    if (dart.library.io) 'pdf_service_io.dart'
    if (dart.library.html) 'pdf_service_web.dart';