import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class UserTermsPage extends StatelessWidget {
  const UserTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Terms & Conditions',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Effective Date: February 2024',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing or using tuk-docs, you agree to be bound by these Terms of Use. If you do not agree with any part of these terms, you may not use the application.',
            ),
            _buildSection(
              '2. Use of Application',
              'tuk-docs provides document viewing services for PDF, Word, and PowerPoint files. You agree to use this application only for lawful purposes and in a way that does not infringe the rights of others.',
            ),
            _buildSection(
              '3. Intellectual Property',
              'The application and its original content, features, and functionality are owned by Dennis Mutuku and are protected by international copyright and other intellectual property laws.',
            ),
            _buildSection(
              '4. Limitation of Liability',
              'tuk-docs is provided "as is" without warranty of any kind. In no event shall the developer be liable for any damages arising out of the use or inability to use the application.',
            ),
            _buildSection(
              '5. Governing Law',
              'These terms shall be governed by and construed in accordance with the laws of Kenya, without regard to its conflict of law provisions.',
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('I Understand'),
              ),
            ),
            const SizedBox(height: 32),
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
