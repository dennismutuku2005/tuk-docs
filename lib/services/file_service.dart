import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/document_model.dart';

class FileService {
  static const List<String> pdfExtensions = ['pdf'];
  static const List<String> wordExtensions = ['doc', 'docx'];
  static const List<String> pptExtensions = ['ppt', 'pptx'];

  Future<List<DocumentModel>> getAllDocuments() async {
    List<DocumentModel> docs = [];
    Set<String> uniquePaths = {}; // To avoid duplicates if paths overlap
    
    // Get common directories
    List<Directory?> directories = [];
    
    if (Platform.isAndroid) {
      final List<String> commonPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/Download/Pdfs',
        '/storage/emulated/0/Documents/Pdfs',
        '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents',
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Documents',
        '/storage/emulated/0/Telegram/Telegram Documents',
      ];

      for (var path in commonPaths) {
        directories.add(Directory(path));
      }
    } else if (Platform.isIOS) {
      directories.add(await getApplicationDocumentsDirectory());
    }

    for (var dir in directories) {
      if (dir != null && await dir.exists()) {
        try {
          // Non-recursive listing is faster for top-level folders
          // But we want to find files in subfolders like "WhatsApp Documents"
          final List<FileSystemEntity> entities = await dir.list(recursive: false).toList().catchError((e) => <FileSystemEntity>[]);

          for (var entity in entities) {
            if (entity is File) {
              _processFile(entity, docs, uniquePaths);
            } else if (entity is Directory) {
              // Deep scan only for specific folders if needed, or just one level down
              // For simplicity and speed, we check one level of subdirectories
              try {
                final subEntities = await entity.list(recursive: false).toList().catchError((e) => <FileSystemEntity>[]);
                for (var sub in subEntities) {
                  if (sub is File) {
                    _processFile(sub, docs, uniquePaths);
                  }
                }
              } catch (_) {}
            }
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    return docs;
  }

  void _processFile(File file, List<DocumentModel> docs, Set<String> uniquePaths) async {
    if (uniquePaths.contains(file.path)) return;
    
    // Skip system/hidden files
    final name = p.basename(file.path);
    if (name.startsWith('.') || file.path.contains('/Android/data') || file.path.contains('/Android/obb')) {
      return;
    }

    String ext = p.extension(file.path).replaceAll('.', '').toLowerCase();
    DocumentType? type;
    
    if (pdfExtensions.contains(ext)) {
      type = DocumentType.pdf;
    } else if (wordExtensions.contains(ext)) {
      type = DocumentType.word;
    } else if (pptExtensions.contains(ext)) {
      type = DocumentType.ppt;
    }
    
    if (type != null) {
      FileStat stats = await file.stat();
      docs.add(DocumentModel(
        path: file.path,
        name: name,
        type: type,
        modifiedDate: stats.modified,
        sizeInBytes: stats.size,
      ));
      uniquePaths.add(file.path);
    }
  }
}
