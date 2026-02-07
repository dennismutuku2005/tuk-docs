import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/document_model.dart';

class FileService {
  static const List<String> pdfExtensions = ['pdf'];
  static const List<String> wordExtensions = ['doc', 'docx'];

  Future<List<DocumentModel>> getAllDocuments() async {
    List<DocumentModel> docs = [];
    
    // Get common directories
    List<Directory?> directories = [];
    
    if (Platform.isAndroid) {
      directories.add(Directory('/storage/emulated/0/Download'));
      directories.add(Directory('/storage/emulated/0/Documents'));
      directories.add(Directory('/storage/emulated/0/Desktop'));
      directories.add(Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Documents'));
      directories.add(Directory('/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents'));
    } else if (Platform.isIOS) {
      directories.add(await getApplicationDocumentsDirectory());
    }

    for (var dir in directories) {
      if (dir != null && await dir.exists()) {
        try {
          final List<FileSystemEntity> entities = await dir.list(recursive: true, followLinks: false).toList().catchError((e) {
            // Handle errors for the entire list if needed, but we'll try to handle per-item via stream
            return <FileSystemEntity>[];
          });

          for (var entity in entities) {
            if (entity is File) {
              try {
                // Skip restricted system folders
                if (entity.path.contains('/Android/data') || entity.path.contains('/Android/obb')) {
                  continue;
                }

                String ext = p.extension(entity.path).replaceAll('.', '').toLowerCase();
                DocumentType? type;
                
                if (pdfExtensions.contains(ext)) {
                  type = DocumentType.pdf;
                } else if (wordExtensions.contains(ext)) {
                  type = DocumentType.word;
                }
                
                if (type != null) {
                  print('Found supported file: ${entity.path} as $type');
                  FileStat stats = await entity.stat();
                  docs.add(DocumentModel(
                    path: entity.path,
                    name: p.basename(entity.path),
                    type: type,
                    modifiedDate: stats.modified,
                    sizeInBytes: stats.size,
                  ));
                }
              } catch (e) {
                // Skip individual file if error (e.g. permission)
                continue;
              }
            }
          }
        } catch (e) {
          // Skip the entire directory if it fails to list
          continue;
        }
      }
    }
    
    return docs;
  }
}
