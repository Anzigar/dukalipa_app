import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/language_provider.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String? _selectedLocale;

  @override
  void initState() {
    super.initState();
    // Get current locale
    _selectedLocale = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;
  }

  void _changeLanguage(String locale) async {
    setState(() {
      _selectedLocale = locale;
    });
    
    try {
      await Provider.of<LanguageProvider>(context, listen: false).setLocale(Locale(locale));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Language changed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change language: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Language selection header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select Language',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Language options
          _LanguageOption(
            title: 'English',
            subtitle: 'English',
            locale: 'en',
            isSelected: _selectedLocale == 'en',
            onTap: () => _changeLanguage('en'),
            flagAsset: 'assets/flags/uk.png',
          ),
          
          _LanguageOption(
            title: 'Kiswahili',
            subtitle: 'Swahili',
            locale: 'sw',
            isSelected: _selectedLocale == 'sw',
            onTap: () => _changeLanguage('sw'),
            flagAsset: 'assets/flags/tz.png',
          ),
          
          _LanguageOption(
            title: 'Français',
            subtitle: 'French',
            locale: 'fr',
            isSelected: _selectedLocale == 'fr',
            onTap: () => _changeLanguage('fr'),
            flagAsset: 'assets/flags/fr.png',
          ),

          _LanguageOption(
            title: 'العربية',
            subtitle: 'Arabic',
            locale: 'ar',
            isSelected: _selectedLocale == 'ar',
            onTap: () => _changeLanguage('ar'),
            flagAsset: 'assets/flags/sa.png',
          ),
          
          const SizedBox(height: 24),
          
          // Language info section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.mkbhdRed.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.mkbhdRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Language Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.mkbhdRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Changing the language will apply to the entire app. '
                  'Some content may still appear in the original language if translations are not available.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.mkbhdLightGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String locale;
  final bool isSelected;
  final VoidCallback onTap;
  final String flagAsset;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.isSelected,
    required this.onTap,
    required this.flagAsset,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 32,
          height: 24,
          child: Image.asset(
            flagAsset,
            errorBuilder: (context, error, stackTrace) {
              // Fallback icon if image fails to load
              return Container(
                color: AppTheme.mkbhdLightGrey.withOpacity(0.2),
                child: const Icon(Icons.flag, size: 16),
              );
            },
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.mkbhdLightGrey,
          fontSize: 12,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppTheme.mkbhdRed,
            )
          : null,
      onTap: onTap,
    );
  }
}
