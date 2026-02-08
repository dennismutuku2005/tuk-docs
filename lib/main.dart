import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'providers/theme_provider.dart';
import 'providers/document_provider.dart';
import 'themes/app_theme.dart';
import 'views/home/landing_page.dart';
import 'views/viewer/pdf_viewer_page.dart';
import 'models/document_model.dart';
import 'views/home/home_page.dart';
import 'views/viewer/word_viewer_page.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('is_first_run') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
      ],
      child: TukDocsApp(isFirstRun: isFirstRun),
    ),
  );
}

class TukDocsApp extends StatefulWidget {
  final bool isFirstRun;
  const TukDocsApp({super.key, required this.isFirstRun});

  @override
  State<TukDocsApp> createState() => _TukDocsAppState();
}

class _TukDocsAppState extends State<TukDocsApp> {
  late StreamSubscription _intentDataStreamSubscription;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // For sharing or opening files while the app is in memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty) {
        _handleSharedFile(value.first.path);
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // For sharing or opening files while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        _handleSharedFile(value.first.path);
      }
    });
  }

  void _handleSharedFile(String path) {
    final doc = DocumentModel.fromPath(path);
    context.read<DocumentProvider>().addToRecent(doc);
    
    if (doc.type == DocumentType.pdf) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => PdfViewerPage(doc: doc)),
      );
    } else if (doc.type == DocumentType.word) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => WordViewerPage(doc: doc)),
      );
    } else {
      OpenFilex.open(path);
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'tuk-docs',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: widget.isFirstRun ? const LandingPage() : const HomePage(),
        );
      },
    );
  }
}
