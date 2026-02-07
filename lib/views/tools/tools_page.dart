import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/document_provider.dart';
import '../../models/document_model.dart';
import '../../themes/app_theme.dart';
import '../../services/conversion_service.dart';
import '../viewer/pdf_viewer_page.dart';
import 'package:open_filex/open_filex.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final ConversionService _conversionService = ConversionService();
  bool _isConverting = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Tools', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Document Converters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildToolCard(
                      context,
                      Icons.image_outlined, 
                      'Image to PDF', 
                      'Convert photos', 
                      Colors.blue[100]!, 
                      Colors.blue[700]!,
                      () => _handleImageToPdf(context),
                    ),
                    _buildToolCard(
                      context,
                      Icons.description_outlined, 
                      'Word to PDF', 
                      'Export Docx', 
                      Colors.indigo[100]!, 
                      Colors.indigo[700]!,
                      () => _handleWordToPdf(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Recent Files',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Consumer<DocumentProvider>(
                  builder: (context, provider, child) {
                    final recent = provider.recentDocs;
                    if (recent.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No recent actions yet.', style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    }
                    return Column(
                      children: recent.take(5).map((doc) => _buildRecentAction(context, doc)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (_isConverting)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Converting...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleImageToPdf(BuildContext context) async {
    final List<XFile> selectedImages = [];
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Image to PDF', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (selectedImages.isNotEmpty) ...[
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(selectedImages[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedImages.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    context, 
                    Icons.camera_alt_outlined, 
                    'Camera', 
                    () async {
                      final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
                      if (photo != null) setModalState(() => selectedImages.add(photo));
                    }
                  ),
                  _buildOption(
                    context, 
                    Icons.photo_library_outlined, 
                    'Gallery', 
                    () async {
                      final List<XFile> picked = await ImagePicker().pickMultiImage();
                      setModalState(() => selectedImages.addAll(picked));
                    }
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: selectedImages.isEmpty ? null : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Create PDF (${selectedImages.length} images)'),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedImages.isEmpty) return;

    try {
      setState(() => _isConverting = true);
      final pdfFile = await _conversionService.convertXFilesToPdf(selectedImages, 'ImagesToPdf');
      
      if (pdfFile != null) {
        if (context.mounted) {
          final doc = DocumentModel.fromPath(pdfFile.path);
          context.read<DocumentProvider>().addToRecent(doc);
          
          _showSaveOrViewDialog(context, pdfFile);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error converting images: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  void _showSaveOrViewDialog(BuildContext context, File pdfFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Created'),
        content: const Text('Your PDF is ready. Would you like to view it or save it to your storage?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveToStorage(pdfFile);
            }, 
            child: const Text('Save to Storage'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PdfViewerPage(doc: DocumentModel.fromPath(pdfFile.path))),
              );
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToStorage(File file) async {
    try {
      final fileName = p.basename(file.path);
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: await file.readAsBytes(),
      );

      if (outputFile != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
  }

  Widget _buildOption(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            child: Icon(icon, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _handleWordToPdf(BuildContext context) async {
    try {
      setState(() => _isConverting = true);
      final pdfFile = await _conversionService.convertWordToPdf();
      
      if (pdfFile != null) {
        if (context.mounted) {
          final doc = DocumentModel.fromPath(pdfFile.path);
          context.read<DocumentProvider>().addToRecent(doc);
          _showSaveOrViewDialog(context, pdfFile);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error converting word doc: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  void _openFile(BuildContext context, DocumentModel doc) {
    context.read<DocumentProvider>().addToRecent(doc);
    if (doc.type == DocumentType.pdf) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PdfViewerPage(doc: doc)),
      );
    } else {
      OpenFilex.open(doc.path);
    }
  }

  Widget _buildToolCard(
    BuildContext context, 
    IconData icon, 
    String title, 
    String subtitle, 
    Color bgColor, 
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      color: bgColor.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAction(BuildContext context, DocumentModel doc) {
    final Color iconColor = doc.type == DocumentType.pdf 
        ? Colors.red 
        : (doc.type == DocumentType.word ? Colors.blue : Colors.orange);
    
    final IconData icon = doc.type == DocumentType.pdf 
        ? Icons.picture_as_pdf 
        : (doc.type == DocumentType.word ? Icons.description : Icons.slideshow);

    final timeStr = DateFormat('MMM d, HH:mm').format(doc.modifiedDate);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('Opened on $timeStr', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openFile(context, doc),
      ),
    );
  }
}
