import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/pdf_provider.dart';
import '../services/pdf_service.dart';
import '../gradient_code.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pdf = context.watch<PdfProvider>();

    Future<void> upload() async {
      await context.read<PdfProvider>().pickPdfs();
    }

    Future<void> merge() async {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merge not supported on web')),
        );
        return;
      }

      if (pdf.files.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least 2 PDFs to merge')),
        );
        return;
      }

      try {
        final outputPath = await PdfService().proposeMergeOutputPath(pdf.files);
        if (outputPath == null) return;

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Merge PDFs'),
            content: Text('Merge to: $outputPath'),
            actions: [
              if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.macOS ||
                  defaultTargetPlatform == TargetPlatform.linux))
                TextButton(
                  onPressed: () async {
                    final newPath = await FilePicker.platform.saveFile(
                      dialogTitle: 'Choose merge location',
                      fileName: outputPath.split('\\').last,
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (newPath != null) {
                      Navigator.of(ctx).pop(true);
                      await PdfService().merge(pdf.files, newPath);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Merged to: $newPath')),
                      );
                    }
                  },
                  child: const Text('Change location'),
                ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Merge'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await PdfService().merge(pdf.files, outputPath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Merged to: $outputPath')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Merge failed: $e')),
        );
      }
    }

    Future<void> compress() async {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compress not supported on web')),
        );
        return;
      }

      if (pdf.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select PDFs to compress')),
        );
        return;
      }

      try {
        for (final file in pdf.files) {
          if (file.path != null) {
            final result = await PdfService().compressPath(file.path!, quality: 50);
            if (result != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Compressed: ${file.name}')),
              );
            }
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compress failed: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: pdf.files.isEmpty ? null : () => context.read<PdfProvider>().clear(),
            tooltip: 'Clear all',
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
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Files'),
                  onPressed: upload,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: pdf.files.isEmpty
                      ? const Center(
                          child: Text('No PDFs selected. Tap "Upload Files" to start.'),
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
                                icon: const Icon(Icons.close),
                                onPressed: () => context.read<PdfProvider>().remove(index),
                                tooltip: 'Remove',
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                // Action buttons for merge and compress
                if (pdf.files.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.merge_type),
                          label: const Text('Merge'),
                          onPressed: pdf.files.length >= 2 ? merge : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.compress),
                          label: const Text('Compress'),
                          onPressed: compress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}