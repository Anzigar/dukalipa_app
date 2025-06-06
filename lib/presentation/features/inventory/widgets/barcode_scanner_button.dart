import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/barcode_scanner_service.dart';

class BarcodeScannerButton extends StatelessWidget {
  final Function(String) onScanned;
  final String tooltip;
  final Color? color;
  final Color? backgroundColor;

  const BarcodeScannerButton({
    Key? key,
    required this.onScanned,
    this.tooltip = 'Scan Barcode',
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: color ?? colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor ?? colorScheme.primary.withOpacity(0.1),
      ),
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          icon: Icon(
            LucideIcons.scan,
            color: color ?? colorScheme.primary,
          ),
          onPressed: () => _scanBarcode(context),
          tooltip: tooltip,
        ),
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context) async {
    try {
      final result = await BarcodeScannerService.scanBarcode(context);
      if (result != null && result.isNotEmpty) {
        onScanned(result);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan barcode: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}
