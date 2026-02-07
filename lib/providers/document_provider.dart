import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';
import '../services/file_service.dart';

class DocumentProvider with ChangeNotifier {
  final FileService _fileService = FileService();
  static const String _recentFilesKey = 'recent_files';
  
  List<DocumentModel> _allDocs = [];
  List<DocumentModel> _recentDocs = [];
  bool _isLoading = false;

  DocumentProvider() {
    _loadRecentDocs();
  }

  List<DocumentModel> get allDocs => _allDocs;
  List<DocumentModel> get recentDocs => _recentDocs;
  bool get isLoading => _isLoading;

  List<DocumentModel> get pdfDocs => _allDocs.where((doc) => doc.type == DocumentType.pdf).toList();
  List<DocumentModel> get wordDocs => _allDocs.where((doc) => doc.type == DocumentType.word).toList();

  Future<void> fetchDocuments() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _allDocs = await _fileService.getAllDocuments();
      _allDocs.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
    } catch (e) {
      debugPrint('Error fetching documents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToRecent(DocumentModel doc) {
    // Remove if already exists (to move to front)
    _recentDocs.removeWhere((d) => d.path == doc.path);
    _recentDocs.insert(0, doc);
    
    // Keep only last 20
    if (_recentDocs.length > 20) {
      _recentDocs = _recentDocs.sublist(0, 20);
    }
    
    _saveRecentDocs();
    notifyListeners();
  }

  Future<void> _loadRecentDocs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recentJson = prefs.getString(_recentFilesKey);
      if (recentJson != null) {
        final List<dynamic> decoded = jsonDecode(recentJson);
        _recentDocs = decoded.map((item) => DocumentModel.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading recent docs: $e');
    }
  }

  Future<void> _saveRecentDocs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_recentDocs.map((doc) => doc.toJson()).toList());
      await prefs.setString(_recentFilesKey, encoded);
    } catch (e) {
      debugPrint('Error saving recent docs: $e');
    }
  }

  void setSearchQuery(String query) {
    // _searchQuery = query;
    notifyListeners();
  }
}
