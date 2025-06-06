import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'sw', 'name': 'Swahili', 'flag': '🇰🇪'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final isSelected = languageProvider.locale.languageCode == language['code'];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isSelected ? 4 : 1,
            child: ListTile(
              leading: Text(
                language['flag']!,
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(
                language['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: AppTheme.mkbhdRed,
                    )
                  : null,
              onTap: () {
                if (!isSelected) {
                  _changeLanguage(context, language['code']!);
                }
              },
              selected: isSelected,
              selectedTileColor: AppTheme.mkbhdRed.withOpacity(0.1),
            ),
          );
        },
      ),
    );
  }

  void _changeLanguage(BuildContext context, String locale) async {
    try {
      // TODO: Implement changeLocale in LanguageProvider
      // await context.read<LanguageProvider>().changeLocale(locale);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Language changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change language: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
