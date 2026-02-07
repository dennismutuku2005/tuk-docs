import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../models/document_model.dart';
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
  PDFViewController? _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Share.shareXFiles([XFile(widget.doc.path)], text: 'Check out this document: ${widget.doc.name}');
            },
          ),
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
            onRender: (pages) {
              setState(() {
                totalPages = pages!;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page!;
              });
            },
          ),
          if (errorMessage.isNotEmpty)
            Center(child: Text(errorMessage))
          else if (!isReady)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: isReady ? SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${currentPage + 1} of $totalPages',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up_rounded),
                    onPressed: currentPage > 0 ? () {
                      _pdfViewController?.setPage(currentPage - 1);
                    } : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    onPressed: currentPage < totalPages - 1 ? () {
                      _pdfViewController?.setPage(currentPage + 1);
                    } : null,
                  ),
                ],
              )
            ],
          ),
        ),
      ) : null,
    );
  }
}
