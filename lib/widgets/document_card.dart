import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document_model.dart';
import '../themes/app_theme.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onTap;

  const DocumentCard({
    super.key,
    required this.doc,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (doc.type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_rounded;
      case DocumentType.word:
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getIconColor() {
    switch (doc.type) {
      case DocumentType.pdf:
        return Colors.red[400]!;
      case DocumentType.word:
        return Colors.blue[600]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getIconColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIcon(), color: _getIconColor(), size: 30),
        ),
        title: Text(
          doc.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Modified: ${DateFormat('MMM dd, yyyy').format(doc.modifiedDate)} • ${doc.sizeFormatted}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: AppTheme.primaryBlue,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Open', style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
        onTap: onTap,
      ),
    );
  }
}
