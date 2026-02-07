import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';
import 'package:open_filex/open_filex.dart';
import '../viewer/pdf_viewer_page.dart';
import '../viewer/word_viewer_page.dart';
import '../../models/document_model.dart';

class DocumentSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final provider = context.read<DocumentProvider>();
    final results = provider.allDocs.where((doc) => 
      doc.name.toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No documents match your search', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return DocumentCard(
          doc: results[index],
          onTap: () {
            close(context, null);
            _openFile(context, results[index]);
          },
        );
      },
    );
  }

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
}
