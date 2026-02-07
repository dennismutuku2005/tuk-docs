import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';
import 'package:open_filex/open_filex.dart';
import '../viewer/pdf_viewer_page.dart';
import '../viewer/word_viewer_page.dart';
import '../../models/document_model.dart';

class RecentFilesScreen extends StatelessWidget {
  const RecentFilesScreen({super.key});

  Future<void> _openFile(BuildContext context, DocumentModel doc) async {
    context.read<DocumentProvider>().addToRecent(doc);
    if (doc.type == DocumentType.pdf) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PdfViewerPage(doc: doc)),
      );
    } else if (doc.type == DocumentType.word) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => WordViewerPage(doc: doc)),
      );
    } else {
      final result = await OpenFilex.open(doc.path);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: ${result.message}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Files', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, provider, child) {
          final docs = provider.recentDocs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No recent files', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return DocumentCard(
                doc: docs[index],
                onTap: () => _openFile(context, docs[index]),
              );
            },
          );
        },
      ),
    );
  }
}
