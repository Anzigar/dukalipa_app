import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

/// A toggle widget for switching between light and dark themes
class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final EdgeInsets? padding;
  final MainAxisAlignment? mainAxisAlignment;

  const ThemeToggleWidget({
    Key? key,
    this.showLabel = true,
    this.padding,
    this.mainAxisAlignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
        final isSystemMode = themeProvider.themeMode == ThemeMode.system;
        
        if (showLabel) {
          return Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildThemeSelector(context, themeProvider, isDarkMode, isSystemMode),
              ],
            ),
          );
        }
        
        return _buildThemeSelector(context, themeProvider, isDarkMode, isSystemMode);
      },
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider, bool isDarkMode, bool isSystemMode) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context,
            themeProvider,
            ThemeMode.light,
            LucideIcons.sun,
            'Light',
          ),
          _buildThemeOption(
            context,
            themeProvider,
            ThemeMode.system,
            LucideIcons.monitor,
            'Auto',
          ),
          _buildThemeOption(
            context,
            themeProvider,
            ThemeMode.dark,
            LucideIcons.moon,
            'Dark',
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
    String tooltip,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => themeProvider.setThemeMode(mode),
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLarge),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// A simple theme toggle button (compact version)
class ThemeToggleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ThemeToggleButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
        
        return IconButton(
          icon: Icon(
            isDarkMode ? LucideIcons.sun : LucideIcons.moon,
          ),
          onPressed: onPressed ?? () {
            // Cycle through light -> dark -> system
            switch (themeProvider.themeMode) {
              case ThemeMode.light:
                themeProvider.setThemeMode(ThemeMode.dark);
                break;
              case ThemeMode.dark:
                themeProvider.setThemeMode(ThemeMode.system);
                break;
              case ThemeMode.system:
                themeProvider.setThemeMode(ThemeMode.light);
                break;
            }
          },
          tooltip: 'Toggle theme',
        );
      },
    );
  }
}

/// A theme mode dropdown widget
class ThemeModeDropdown extends StatelessWidget {
  const ThemeModeDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DropdownButton<ThemeMode>(
          value: themeProvider.themeMode,
          underline: Container(),
          items: const [
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.sun, size: 16),
                  SizedBox(width: 8),
                  Text('Light'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.moon, size: 16),
                  SizedBox(width: 8),
                  Text('Dark'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.monitor, size: 16),
                  SizedBox(width: 8),
                  Text('System'),
                ],
              ),
            ),
          ],
          onChanged: (ThemeMode? newMode) {
            if (newMode != null) {
              themeProvider.setThemeMode(newMode);
            }
          },
        );
      },
    );
  }
}
