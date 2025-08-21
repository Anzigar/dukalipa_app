import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E8);
        textColor = isDark ? Colors.white : const Color(0xFF1B5E20);
        iconColor = isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
        icon = LucideIcons.checkCircle;
        break;
      case SnackBarType.error:
        backgroundColor = isDark ? const Color(0xFF5F2120) : const Color(0xFFFFEBEE);
        textColor = isDark ? Colors.white : const Color(0xFF5F2120);
        iconColor = isDark ? const Color(0xFFF44336) : const Color(0xFFD32F2F);
        icon = LucideIcons.xCircle;
        break;
      case SnackBarType.warning:
        backgroundColor = isDark ? const Color(0xFF663C00) : const Color(0xFFFFF8E1);
        textColor = isDark ? Colors.white : const Color(0xFF663C00);
        iconColor = isDark ? const Color(0xFFFF9800) : const Color(0xFFE65100);
        icon = LucideIcons.alertTriangle;
        break;
      case SnackBarType.info:
        backgroundColor = isDark ? const Color(0xFF0D47A1) : const Color(0xFFE3F2FD);
        textColor = isDark ? Colors.white : const Color(0xFF0D47A1);
        iconColor = isDark ? const Color(0xFF2196F3) : const Color(0xFF1976D2);
        icon = LucideIcons.info;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: iconColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        elevation: 4,
        action: null, // We handle action inside content for better control
      ),
    );
  }

  // Convenience methods for common use cases
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
