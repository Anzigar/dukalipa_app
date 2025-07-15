import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/language_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'sw', 'name': 'Swahili', 'nativeName': 'Kiswahili'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Language'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.mkbhdRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.mkbhdRed.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.mkbhdRed.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.translate,
                          color: AppTheme.mkbhdRed,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Select your preferred language. The app will restart to apply the changes.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mkbhdLightGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Material 3 styled language selection
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.mkbhdLightGrey.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: _languages.map((language) {
                      final isSelected = _selectedLanguage == language['code'];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedLanguage = language['code']!;
                            });
                            // Handle language change logic here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Language changed to ${language['name']}'),
                                backgroundColor: AppTheme.mkbhdRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? AppTheme.mkbhdRed.withOpacity(0.1)
                                        : AppTheme.mkbhdLightGrey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      language['code']!.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? AppTheme.mkbhdRed : AppTheme.mkbhdLightGrey,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language['name']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? AppTheme.mkbhdRed : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        language['nativeName']!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.mkbhdLightGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Material 3 Radio button
                                Radio<String>(
                                  value: language['code']!,
                                  groupValue: _selectedLanguage,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLanguage = value!;
                                    });
                                  },
                                  activeColor: AppTheme.mkbhdRed,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
