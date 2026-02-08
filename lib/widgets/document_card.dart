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
      case DocumentType.ppt:
        return Icons.slideshow_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getIconColor() {
    switch (doc.type) {
      case DocumentType.pdf:
        return const Color(0xFFEF4444); // Red 500
      case DocumentType.word:
        return const Color(0xFF3B82F6); // Blue 500
      case DocumentType.ppt:
        return const Color(0xFFF59E0B); // Amber 500
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Theme.of(context).cardTheme.color,
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _getIconColor().withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_getIcon(), color: _getIconColor(), size: 24),
        ),
        title: Text(
          doc.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${doc.sizeFormatted} • ${DateFormat('d MMM, yyyy').format(doc.modifiedDate)}',
            style: TextStyle(
              fontSize: 12, 
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          size: 20,
        ),
      ),
    );
  }
}
