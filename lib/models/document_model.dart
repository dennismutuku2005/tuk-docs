import 'dart:io';
import 'package:path/path.dart' as p;

enum DocumentType { pdf, word, ppt, other }

class DocumentModel {
  final String path;
  final String name;
  final DocumentType type;
  final DateTime modifiedDate;
  final int sizeInBytes;

  DocumentModel({
    required this.path,
    required this.name,
    required this.type,
    required this.modifiedDate,
    required this.sizeInBytes,
  });

  factory DocumentModel.fromPath(String path) {
    final file = File(path);
    final name = p.basename(path);
    final ext = p.extension(path).replaceAll('.', '').toLowerCase();
    final stats = file.statSync();
    
    DocumentType type = DocumentType.other;
    if (['pdf'].contains(ext)) {
      type = DocumentType.pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      type = DocumentType.word;
    } else if (['ppt', 'pptx'].contains(ext)) {
      type = DocumentType.ppt;
    }

    return DocumentModel(
      path: path,
      name: name,
      type: type,
      modifiedDate: stats.modified,
      sizeInBytes: stats.size,
    );
  }

  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'type': type.index,
    'modifiedDate': modifiedDate.toIso8601String(),
    'sizeInBytes': sizeInBytes,
  };

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    path: json['path'],
    name: json['name'],
    type: DocumentType.values[json['type']],
    modifiedDate: DateTime.parse(json['modifiedDate']),
    sizeInBytes: json['sizeInBytes'],
  );

  String get sizeFormatted {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get extension => name.split('.').last.toLowerCase();
}
