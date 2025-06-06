import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BarcodeScannerService {
  static Future<String?> scanBarcode(BuildContext context) async {
    try {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => const _BarcodeScannerScreen(),
        ),
      );
      return result;
    } catch (e) {
      debugPrint('Barcode scanning error: $e');
      return null;
    }
  }
}

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Barcode'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(LucideIcons.flashlight, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(LucideIcons.flashlight, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                return const Icon(LucideIcons.rotateCcw);
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isScanning) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first;
                if (barcode.rawValue != null) {
                  setState(() => _isScanning = false);
                  
                  // Haptic feedback
                  HapticFeedback.mediumImpact();
                  
                  // Return the scanned value
                  Navigator.of(context).pop(barcode.rawValue);
                }
              }
            },
          ),
          
          // Overlay with scanning frame
          _buildScanningOverlay(colorScheme),
          
          // Bottom instruction panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.scan,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Position the barcode within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The camera will automatically detect and scan the barcode',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay(ColorScheme colorScheme) {
    return Container(
      decoration: ShapeDecoration(
        shape: _ScannerOverlayShape(),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
        ),
        child: Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner indicators
                ..._buildCornerIndicators(colorScheme.primary),
                
                // Scanning animation line
                if (_isScanning)
                  _buildScanningLine(colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerIndicators(Color color) {
    const double cornerSize = 20;
    const double cornerWidth = 3;
    
    return [
      // Top-left corner
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: cornerWidth),
              left: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Top-right corner
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: cornerWidth),
              right: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Bottom-left corner
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: cornerWidth),
              left: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Bottom-right corner
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: cornerWidth),
              right: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildScanningLine(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          top: value * 230 + 10,
          left: 10,
          right: 10,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
      onEnd: () {
        if (_isScanning && mounted) {
          setState(() {}); // Restart animation
        }
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    const double scanAreaSize = 250;
    final double left = (rect.width - scanAreaSize) / 2;
    final double top = (rect.height - scanAreaSize) / 2;
    
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
          const Radius.circular(12),
        ),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // No painting needed
  }

  @override
  ShapeBorder scale(double t) => this;
}
