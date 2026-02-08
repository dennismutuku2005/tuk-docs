import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
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
  bool isExtracting = false;
  String errorMessage = '';
  PDFViewController? _pdfViewController;

  Future<void> _copyPageText() async {
    setState(() => isExtracting = true);
    try {
      final List<String> pagesText = await ReadPdfText.getPDFtextPaginated(widget.doc.path);
      if (currentPage < pagesText.length) {
        final text = pagesText[currentPage].trim();
        if (text.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: text));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Text copied from this page!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          throw 'No text found on this page (might be an image-based PDF).';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not copy: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isExtracting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc.name),
        actions: [
          if (isExtracting)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ))
          else
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: "Copy Page Text",
              onPressed: _copyPageText,
            ),
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
      body: Stack(
        children: [
          PDFView(
            filePath: widget.doc.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.BOTH,
            nightMode: Theme.of(context).brightness == Brightness.dark,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onRender: (pages) {
              setState(() {
                totalPages = pages!;
                isReady = true;
              });
            },
            onError: (error) => setState(() => errorMessage = error.toString()),
            onPageError: (page, error) => setState(() => errorMessage = '$page: $error'),
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() => currentPage = page!);
            },
          ),
          if (errorMessage.isNotEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ))
          else if (!isReady)
            const Center(child: CircularProgressIndicator()),
        ],
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
                  onPressed: currentPage > 0 ? () => _pdfViewController?.setPage(currentPage - 1) : null,
                ),
                const SizedBox(width: 12),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: currentPage < totalPages - 1 ? () => _pdfViewController?.setPage(currentPage + 1) : null,
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
