import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SalesEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SalesEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.mkbhdRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.mkbhdDarkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.mkbhdGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(
                  actionLabel == 'Clear Search' ? Icons.clear : Icons.add,
                  size: 20,
                ),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mkbhdRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
