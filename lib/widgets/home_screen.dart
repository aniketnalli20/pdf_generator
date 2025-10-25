import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pdf_provider.dart';
import '../gradient_code.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pdf = context.watch<PdfProvider>();

    Future<void> _upload() async {
      await context.read<PdfProvider>().pickPdfs();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Assistant'),
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
                  onPressed: _upload,
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
                              // trailing removed as requested
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                // Only 'Upload Files' remains; other actions removed
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}