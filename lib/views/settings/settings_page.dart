import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../themes/app_theme.dart';
import '../info/about_developer_page.dart';
import '../info/privacy_policy_page.dart';
import '../info/user_terms_page.dart';
import '../info/license_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Column(
              children: [
                Icon(Icons.description_rounded, size: 80, color: AppTheme.primaryBlue),
                SizedBox(height: 16),
                Text(
                  'tuk-docs',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('Ad-free document viewer', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'APPEARANCE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeThumbColor: AppTheme.primaryBlue,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ABOUT',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  Icons.person_outline,
                  'About Developer',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutDeveloperPage())),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingsTile(
                  context,
                  Icons.security_outlined,
                  'Privacy Policy',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingsTile(
                  context,
                  Icons.gavel_outlined,
                  'User Terms',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserTermsPage())),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingsTile(
                  context,
                  Icons.verified_user_outlined,
                  'Licenses',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LicenseInfoPage())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'SUPPORT',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: _buildSettingsTile(context, Icons.help_outline, 'Help Center', () {}),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Column(
              children: [
                Text('VERSION 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('© 2024 tuk-docs', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
