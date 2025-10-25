import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/pdf_provider.dart';
import '../services/pdf_service.dart';
import '../gradient_code.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Upload function - picks PDF files
  Future<void> _uploadFiles(BuildContext context) async {
    await context.read<PdfProvider>().pickPdfs();
  }

  // Merge function - combines multiple PDFs into one
  Future<void> _mergePdfs(BuildContext context) async {
    final pdf = context.read<PdfProvider>();
    
    // Check platform support
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merge not supported on web platform')),
      );
      return;
    }

    // Validate file count
    if (pdf.files.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 PDFs to merge')),
      );
      return;
    }

    try {
      // Extract valid file paths
      final inputPaths = pdf.files
          .where((f) => f.path != null && f.path!.isNotEmpty)
          .map((f) => f.path!)
          .toList();
          
      if (inputPaths.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid file paths found')),
        );
        return;
      }

      // Get proposed output path
      final outputPath = await PdfService().proposeMergeOutputPath(inputPaths);

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Merge PDFs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Files to merge: ${pdf.files.length}'),
              const SizedBox(height: 8),
              Text('Output: ${outputPath.split('\\').last}'),
            ],
          ),
          actions: [
            // Change location button (desktop only)
            if (defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.linux)
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
                    await _performMerge(context, inputPaths, newPath);
                  }
                },
                child: const Text('Change Location'),
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

      // Perform merge if confirmed
      if (confirmed == true) {
        await _performMerge(context, inputPaths, outputPath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merge failed: $e')),
      );
    }
  }

  // Helper function to perform the actual merge
  Future<void> _performMerge(BuildContext context, List<String> inputPaths, String outputPath) async {
    try {
      await PdfService().merge(inputPaths, outputPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully merged to: ${outputPath.split('\\').last}'),
          action: SnackBarAction(
            label: 'Open Folder',
            onPressed: () {
              // Could implement folder opening here
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merge failed: $e')),
      );
    }
  }

  // Compress function - reduces PDF file sizes
  Future<void> _compressPdfs(BuildContext context) async {
    final pdf = context.read<PdfProvider>();
    
    // Check platform support
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compress not supported on web platform')),
      );
      return;
    }

    // Validate files
    if (pdf.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select PDFs to compress')),
      );
      return;
    }

    try {
      int compressedCount = 0;
      int totalFiles = pdf.files.length;
      
      // Show progress
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compressing $totalFiles file(s)...')),
      );

      // Compress each file
      for (final file in pdf.files) {
        if (file.path != null && file.path!.isNotEmpty) {
          final result = await PdfService().compressPath(
            file.path!, 
            quality: 50, // Medium compression
          );
          if (result != null) {
            compressedCount++;
          }
        }
      }
      
      // Show results
      if (compressedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully compressed $compressedCount of $totalFiles file(s)'),
            action: SnackBarAction(
              label: 'Open Folder',
              onPressed: () {
                // Could implement folder opening here
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No files were compressed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compression failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdf = context.watch<PdfProvider>();

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
                  onPressed: () => _uploadFiles(context),
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
                              title: Text(f.name),
                              subtitle: f.path != null && f.path!.isNotEmpty
                                  ? Text(
                                      f.path!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => context.read<PdfProvider>().removeAt(index),
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
                        child: Tooltip(
                          message: kIsWeb ? 'Backend required for merge on web' : 'Merge selected PDFs',
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.merge_type),
                            label: const Text('Merge'),
                            onPressed: (!kIsWeb && pdf.files.length >= 2)
                                ? () => _mergePdfs(context)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.compress),
                          label: const Text('Compress'),
                          onPressed: () async {
                            if (!kIsWeb) {
                              await _compressPdfs(context);
                              return;
                            }
                            // Web: build data URIs and call web service to trigger downloads
                            final pdf = context.read<PdfProvider>();
                            if (pdf.files.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Select PDFs to compress')),
                              );
                              return;
                            }
                            int compressed = 0;
                            for (final f in pdf.files) {
                              if (f.bytes != null && f.bytes!.isNotEmpty) {
                                final dataUri = Uri.dataFromBytes(
                                  f.bytes!,
                                  mimeType: 'application/pdf',
                                  base64: true,
                                ).toString();
                                final result = await PdfService().compressPath(
                                  dataUri,
                                  quality: 50,
                                );
                                if (result != null) compressed++;
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Compressed $compressed file(s)')),
                            );
                          },
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