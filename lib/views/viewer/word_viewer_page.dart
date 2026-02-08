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
        title: Text(widget.doc.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: "Share Document",
            onPressed: () {
              Share.shareXFiles([XFile(widget.doc.path)], text: 'Check out this document: ${widget.doc.name}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: "External App",
            onPressed: () => OpenFilex.open(widget.doc.path),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).cardTheme.color,
        child: DocxView(
          filePath: widget.doc.path,
          fontSize: 15,
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not load: $error'), backgroundColor: Colors.red),
            );
          },
        ),
      ),
    );
  }
}
