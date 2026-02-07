import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: February 2024',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Data Collection',
              'tuk-docs is designed with privacy in mind. We do not collect, store, or transmit any of your personal data or the contents of the documents you view. All document processing happens locally on your device.',
            ),
            _buildSection(
              '2. Permissions',
              'The app requires access to your device\'s storage to locate and open document files (PDF, DOC, PPT). We only access the files you specifically choose to open.',
            ),
            _buildSection(
              '3. Third-Party Services',
              'We do not share your data with any third-party services. The app operates offline for document viewing.',
            ),
            _buildSection(
              '4. Security',
              'Since all data remains on your device, the security of your documents depends on your device\'s security settings.',
            ),
            _buildSection(
              '5. Changes to This Policy',
              'We may update our Privacy Policy from time to time. You are advised to review this page periodically for any changes.',
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '© 2024 tuk-docs',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
