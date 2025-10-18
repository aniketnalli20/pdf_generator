import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pdf_provider.dart';
import '../services/pdf_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pdf = context.watch<PdfProvider>();
    final hasValidPaths = pdf.files.every((f) => f.path != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Assistant'),
        actions: [
          IconButton(
            tooltip: 'Clear',
            onPressed: pdf.files.isEmpty ? null : () => pdf.clear(),
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Pick PDFs'),
              onPressed: () => context.read<PdfProvider>().pickPdfs(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: pdf.files.isEmpty
                  ? const Center(
                      child: Text('No PDFs selected. Tap "Pick PDFs".'),
                    )
                  : ReorderableListView.builder(
                      itemCount: pdf.files.length,
                      onReorder: pdf.reorder,
                      itemBuilder: (ctx, index) {
                        final f = pdf.files[index];
                        return ListTile(
                          key: ValueKey('file-$index-${f.name}-${f.path}'),
                          leading: const Icon(Icons.picture_as_pdf),
                          title: Text(f.name ?? f.path ?? 'PDF'),
                          subtitle: Text(
                            (f.path ?? '').isEmpty ? '' : (f.path!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove',
                            onPressed: () => context.read<PdfProvider>().removeAt(index),
                            icon: const Icon(Icons.close),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.merge_type),
                    label: const Text('Merge'),
                    onPressed: () async {
                      if (kIsWeb) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Merge is not supported on web. Please use Windows or Android.'),
                          ),
                        );
                        return;
                      }
                      if (pdf.files.length < 2 || !hasValidPaths) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Select at least two local PDFs with valid file paths.'),
                          ),
                        );
                        return;
                      }
                      final outputPath = await FilePicker.platform.saveFile(
                        dialogTitle: 'Save merged PDF as',
                        fileName: 'merged.pdf',
                        type: FileType.custom,
                        allowedExtensions: const ['pdf'],
                      );
                      if (outputPath == null) return;
                      final paths = pdf.files
                          .map((f) => f.path)
                          .whereType<String>()
                          .toList();
                      try {
                        final mergedPath = await const PdfService()
                            .merge(paths, outputPath);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Merged to: $mergedPath')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Merge failed: $e')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.compress),
                    label: const Text('Compress'),
                    onPressed: () async {
                      if (kIsWeb) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Compress is not supported on web. Please use Windows or Android.'),
                          ),
                        );
                        return;
                      }
                      if (pdf.files.isEmpty || !hasValidPaths) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Select one or more local PDFs with valid file paths.'),
                          ),
                        );
                        return;
                      }
                      try {
                        int count = 0;
                        String? firstOutput;
                        for (final f in pdf.files) {
                          final path = f.path;
                          if (path == null) continue;
                          final outputPath = await const PdfService().compressPath(
                            path,
                            quality: 60,
                          );
                          if (outputPath != null) {
                            firstOutput ??= outputPath;
                            count++;
                          }
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Compressed $count file(s). Sample: ${firstOutput ?? 'n/a'}'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Compress failed: $e')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}