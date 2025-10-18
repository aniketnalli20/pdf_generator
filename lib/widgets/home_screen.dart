import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pdf_provider.dart';
import '../services/pdf_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../gradient_code.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pdf = context.watch<PdfProvider>();
    final hasValidPaths = pdf.files.every((f) => f.path != null);

    Future<void> _proceed() async {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compress/Merge are not supported on web. Please use Windows or Android.'),
          ),
        );
        return;
      }
      if (pdf.files.isEmpty) {
        await context.read<PdfProvider>().pickPdfs();
      }
      if (pdf.files.isEmpty || !hasValidPaths) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select local PDFs with valid file paths.'),
          ),
        );
        return;
      }

      final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (sheetCtx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.compress),
                  title: const Text('Compress selected'),
                  onTap: () => Navigator.pop(sheetCtx, 'compress'),
                ),
                ListTile(
                  leading: const Icon(Icons.merge_type),
                  title: const Text('Merge selected'),
                  onTap: () => Navigator.pop(sheetCtx, 'merge'),
                ),
              ],
            ),
          );
        },
      );

      if (choice == 'compress') {
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
      } else if (choice == 'merge') {
        if (pdf.files.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Select at least two PDFs to merge.'),
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
        final paths = pdf.files.map((f) => f.path).whereType<String>().toList();
        try {
          final mergedPath = await const PdfService().merge(paths, outputPath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Merged to: $mergedPath')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Merge failed: $e')),
          );
        }
      }
    }

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
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Proceed'),
                  onPressed: _proceed,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: pdf.files.isEmpty
                      ? const Center(
                          child: Text('No PDFs selected. Tap "Proceed" to start.'),
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
                              // trailing removed as requested
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                // Action buttons removed in favor of single Proceed flow
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}