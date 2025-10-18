import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class PdfProvider extends ChangeNotifier {
  final List<PlatformFile> _files = [];

  List<PlatformFile> get files => List.unmodifiable(_files);

  Future<void> pickPdfs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
      withData: false,
    );
    if (result != null) {
      _files
        ..clear()
        ..addAll(result.files.where((f) => (f.extension ?? '').toLowerCase() == 'pdf'));
      notifyListeners();
    }
  }

  void removeAt(int index) {
    if (index >= 0 && index < _files.length) {
      _files.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _files.clear();
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _files.removeAt(oldIndex);
    _files.insert(newIndex, item);
    notifyListeners();
  }
}