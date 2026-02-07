import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:path/path.dart' as p;

class ConversionService {
  final ImagePicker _picker = ImagePicker();

  /// Converts multiple images into a single PDF file
  Future<File?> convertImagesToPdf() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return null;

    final pdf = pw.Document();

    for (var image in images) {
      final imageFile = File(image.path);
      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    return await _savePdfDocument(pdf, 'ImagesToPdf');
  }

  /// Converts a Word (.docx) file to a PDF file by extracting its text
  Future<File?> convertWordToPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result == null || result.files.single.path == null) return null;

    final docxFile = File(result.files.single.path!);
    final docxBytes = await docxFile.readAsBytes();
    
    // Extract text from DOCX
    final text = docxToText(docxBytes);
    
    final pdf = pw.Document();
    
    // Split text into paragraphs to avoid "widget won't fit" error
    // MultiPage works best with a list of widgets (paragraphs)
    final paragraphs = text.split('\n');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return paragraphs.map((p) => pw.Paragraph(
            text: p,
            style: const pw.TextStyle(fontSize: 12),
          )).toList();
        },
      ),
    );

    return await _savePdfDocument(pdf, p.basenameWithoutExtension(docxFile.path));
  }

  /// Converts XFiles (from camera or gallery) into a single PDF file
  Future<File?> convertXFilesToPdf(List<XFile> images, String fileName) async {
    if (images.isEmpty) return null;

    final pdf = pw.Document();

    for (var image in images) {
      final imageFile = File(image.path);
      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    return await _savePdfDocument(pdf, fileName);
  }

  /// Helper to save PDF document to a file
  Future<File> _savePdfDocument(pw.Document pdf, String namePrefix) async {
    final output = await getApplicationDocumentsDirectory();
    final fileName = '${namePrefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
