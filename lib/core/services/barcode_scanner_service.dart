import 'package:flutter/material.dart';
import '../../presentation/common/widgets/barcode_scanner_screen.dart';

class BarcodeScannerService {
  static Future<String?> scanBarcode(BuildContext context) async {
    try {
      // Check camera permission
      final hasPermission = await _checkCameraPermission();
      
      if (!hasPermission && context.mounted) {
        _showPermissionDialog(context);
        return null;
      }

      // Navigate to scanner screen
      if (context.mounted) {
        final result = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (context) => const BarcodeScannerScreen(),
          ),
        );
        return result;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning barcode: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      
      return null;
    }
  }

  static Future<bool> _checkCameraPermission() async {
    try {
      // The mobile_scanner package handles permissions internally
      // We can return true here as the package will handle permission requests
      return true;
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      return false;
    }
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'Camera access is required to scan barcodes. Please enable camera permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // You can add code here to open app settings
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }
}