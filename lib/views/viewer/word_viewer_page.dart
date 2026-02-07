import 'dart:io';
import 'package:flutter/material.dart';
import 'package:docx_viewer/docx_viewer.dart';
import '../../models/document_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class WordViewerPage extends StatefulWidget {
  final DocumentModel doc;
  const WordViewerPage({super.key, required this.doc});

  @override
  State<WordViewerPage> createState() => _WordViewerPageState();
}

class _WordViewerPageState extends State<WordViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doc.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Word Document", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: "Open in External App",
            onPressed: () => OpenFilex.open(widget.doc.path),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Share.shareXFiles([XFile(widget.doc.path)], text: 'Check out this document: ${widget.doc.name}');
            },
          ),
        ],
      ),
      body: DocxView(
        filePath: widget.doc.path,
        fontSize: 16,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
