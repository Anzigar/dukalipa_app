import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        // Use settings from SharedPreferences if available, otherwise use defaults
        _isDarkMode = prefs.getBool('darkMode') ?? false;
        _selectedLanguage = prefs.getString('language') ?? 'English';
        _notificationsEnabled = prefs.getBool('notifications') ?? true;
      });
    } catch (e) {
      // If there's an error getting SharedPreferences, simply use defaults
      print('Error loading settings: $e');
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _isDarkMode);
      await prefs.setString('language', _selectedLanguage);
      await prefs.setBool('notifications', _notificationsEnabled);
    } catch (e) {
      print('Error saving settings: $e');
      // Show an error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Settings'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSettingsHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _isDarkMode,
            activeColor: AppTheme.mkbhdRed,
            onChanged: (value) async {
              setState(() {
                _isDarkMode = value;
              });
              await _saveSettings();
              // Note: For this to work, you would need to implement a theme provider system
              // and call the appropriate method here to update the theme
            },
          ),
          const Divider(),
          
          // Language section
          _buildSettingsHeader('Language'),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'English',
            groupValue: _selectedLanguage,
            activeColor: AppTheme.mkbhdRed,
            onChanged: (value) async {
              setState(() {
                _selectedLanguage = value!;
              });
              await _saveSettings();
              // Note: For this to work, you would need to implement a locale provider
              // and call the appropriate method here to update the language
            },
          ),
          RadioListTile<String>(
            title: const Text('Swahili'),
            value: 'Swahili',
            groupValue: _selectedLanguage,
            activeColor: AppTheme.mkbhdRed,
            onChanged: (value) async {
              setState(() {
                _selectedLanguage = value!;
              });
              await _saveSettings();
              // Note: For this to work, you would need to implement a locale provider
              // and call the appropriate method here to update the language
            },
          ),
          const Divider(),
          
          // Notifications section
          _buildSettingsHeader('Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get alerts about stock levels and other activities'),
            value: _notificationsEnabled,
            activeColor: AppTheme.mkbhdRed,
            onChanged: (value) async {
              setState(() {
                _notificationsEnabled = value;
              });
              await _saveSettings();
              // Note: For this to work with actual notifications, you would need to
              // implement platform-specific notification settings
            },
          ),
          const Divider(),
          
          // App information
          _buildSettingsHeader('About'),
          const ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0 (Beta)'),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(LucideIcons.externalLink),
            onTap: () {
              // Open privacy policy
              // You could use url_launcher package to open a web URL
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(LucideIcons.externalLink),
            onTap: () {
              // Open terms of service
              // You could use url_launcher package to open a web URL
            },
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.mkbhdRed,
        ),
      ),
    );
  }
}
