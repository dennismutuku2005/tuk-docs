import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';
import '../../themes/app_theme.dart';
import '../settings/settings_page.dart';
import 'package:open_filex/open_filex.dart';
import '../viewer/pdf_viewer_page.dart';
import '../tools/search_page.dart';
import 'recent_files_page.dart';
import '../viewer/word_viewer_page.dart';
import '../tools/tools_page.dart';
import '../../models/document_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().fetchDocuments();
    });
  }

  final List<Widget> _pages = [
    const FilesListScreen(),
    const RecentFilesScreen(),
    const ToolsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder_copy_rounded), label: 'Files'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Recent'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_mosaic_rounded), label: 'Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

class FilesListScreen extends StatelessWidget {
  const FilesListScreen({super.key});

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
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: ${result.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('tuk-docs'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => showSearch(context: context, delegate: DocumentSearchDelegate()),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            indicatorColor: AppTheme.primaryBlue,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: Colors.grey[500],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Library'),
              Tab(text: 'PDF'),
              Tab(text: 'Word'),
            ],
          ),
        ),
        body: Consumer<DocumentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.allDocs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildFileList(context, provider.allDocs),
                _buildFileList(context, provider.pdfDocs),
                _buildFileList(context, provider.wordDocs),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFileList(BuildContext context, List<DocumentModel> docs) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No documents found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<DocumentProvider>().fetchDocuments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          return DocumentCard(
            doc: docs[index],
            onTap: () => _openFile(context, docs[index]),
          );
        },
      ),
    );
  }
}
