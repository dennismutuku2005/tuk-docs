import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class LicenseInfoPage extends StatelessWidget {
  const LicenseInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Licenses', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Icon(Icons.verified_user_outlined, size: 80, color: AppTheme.primaryBlue),
          const SizedBox(height: 24),
          const Text(
            'Open Source Software',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'tuk-docs is built using open source software. We are grateful to the community for their contributions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 40),
          _buildLicenseSection(
            context,
            'Application License',
            'MIT License\n\nCopyright (c) 2024 Dennis Mutuku\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files...',
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            child: ListTile(
              title: const Text('View All Open Source Licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'tuk-docs',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 Dennis Mutuku',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseSection(BuildContext context, String title, String content) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.grey),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
