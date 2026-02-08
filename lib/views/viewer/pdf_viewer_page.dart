import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../models/document_model.dart';
import '../../themes/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerPage extends StatefulWidget {
  final DocumentModel doc;
  const PdfViewerPage({super.key, required this.doc});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  int totalPages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final PdfViewerController _pdfController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: "Share",
            onPressed: () {
              Share.shareXFiles([XFile(widget.doc.path)], text: 'Document: ${widget.doc.name}');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SfPdfViewerFix(
        child: PdfViewer.file(
          widget.doc.path,
          controller: _pdfController,
          params: PdfViewerParams(
            onViewerReady: (document, controller) {
              setState(() {
                totalPages = document.pages.length;
                isReady = true;
              });
            },
            onPageChanged: (pageNumber) {
              if (pageNumber != null) {
                setState(() => currentPage = pageNumber - 1);
              }
            },
            onError: (error) => setState(() => errorMessage = error.toString()),
            // pdfrx supports selection by default
          ),
        ),
      ),
      bottomNavigationBar: isReady ? Container(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 8 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progress', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(
                  'Page ${currentPage + 1} / $totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: currentPage > 0 ? () => _pdfController.goToPage(pageNumber: currentPage) : null,
                ),
                const SizedBox(width: 12),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: currentPage < totalPages - 1 ? () => _pdfController.goToPage(pageNumber: currentPage + 2) : null,
                ),
              ],
            )
          ],
        ),
      ) : null,
    );
  }

  Widget _buildNavButton({required IconData icon, VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: onPressed == null ? Colors.grey[300] : AppTheme.primaryBlue),
        ),
      ),
    );
  }
}

// Wrapper for error handling or additional features
class SfPdfViewerFix extends StatelessWidget {
  final Widget child;
  const SfPdfViewerFix({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return child;
  }
}
