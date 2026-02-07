import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../providers/document_provider.dart';
import '../../themes/app_theme.dart';
import 'home_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Future<void> _handleGetStarted(BuildContext context) async {
    PermissionStatus status;
    
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 30) {
        // For Android 11+, we request MANAGE_EXTERNAL_STORAGE for document access
        status = await Permission.manageExternalStorage.request();
      } else {
        // For older versions, standard storage permission
        status = await Permission.storage.request();
      }
    } else {
      // iOS handling
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      if (context.mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_first_run', false);
        
        context.read<DocumentProvider>().fetchDocuments();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to view documents'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Tuk Docs needs access to your documents to display them. Please enable "All Files Access" or Storage permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.description_rounded,
                size: 100,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'tuk-docs',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Simple. Without Ads.\nLearning Made Easy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'The minimalist document viewer for PDFs and Word files.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleGetStarted(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Available for Android and iOS\nNO SUBSCRIPTIONS REQUIRED',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
