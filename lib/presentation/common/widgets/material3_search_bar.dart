import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class Material3SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  final bool enabled;
  final Widget? leading;
  final List<Widget>? trailing;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final Color? focusedBackgroundColor;
  final BorderSide? side;
  final BorderSide? focusedSide;
  final OutlinedBorder? shape;

  const Material3SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
    this.enabled = true,
    this.leading,
    this.trailing,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.focusedBackgroundColor,
    this.side,
    this.focusedSide,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SearchBar(
      controller: controller,
      onChanged: onChanged,
      hintText: hintText,
      enabled: enabled,
      leading: leading ?? const Icon(Icons.search_rounded),
      trailing: trailing ?? (controller.text.isNotEmpty
          ? [
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
            ]
          : null),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return focusedBackgroundColor ?? AppTheme.mkbhdRed.withOpacity(0.02);
        }
        return backgroundColor ?? colorScheme.surfaceContainerHigh;
      }),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return elevation ?? 0;
        }
        return 0.0;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return focusedSide ?? const BorderSide(
            color: AppTheme.mkbhdRed,
            width: 2.0,
          );
        }
        return side ?? BorderSide(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1.0,
        );
      }),
      shape: WidgetStateProperty.all(
        shape ?? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      padding: WidgetStateProperty.all(
        padding ?? const EdgeInsets.symmetric(horizontal: 16),
      ),
      textStyle: WidgetStateProperty.all(
        TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
      hintStyle: WidgetStateProperty.all(
        TextStyle(
          fontSize: 16,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
