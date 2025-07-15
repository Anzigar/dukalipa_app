import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

class SaleDetailsScreen extends StatelessWidget {
  final String saleId;

  const SaleDetailsScreen({
    Key? key,
    required this.saleId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: Text(
          'Sale Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sale info container - flat design
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.mkbhdRed.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.receipt,
                        color: AppTheme.mkbhdRed,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sale #$saleId',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sale details would be displayed here',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

