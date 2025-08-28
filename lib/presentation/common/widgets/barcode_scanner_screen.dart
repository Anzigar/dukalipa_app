import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.displayValue ?? '';
      if (code.isNotEmpty) {
        setState(() {
          isScanning = false;
        });
        Navigator.of(context).pop(code);
      }
    }
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
    });
    cameraController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Scan Barcode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Scan area overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 16,
                borderLength: 30,
                borderWidth: 4,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      'Point camera at barcode to scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderHeightSize = height / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + (width - cutOutWidth) / 2 + borderWidth,
      rect.top + (height - cutOutHeight) / 2 + borderWidth,
      cutOutWidth - 2 * borderWidth,
      cutOutHeight - 2 * borderWidth,
    );

    // Draw overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))),
      ),
      backgroundPaint,
    );

    // Draw border corners
    final cornerRadius = borderRadius > 0 ? borderRadius : 0.0;
    
    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left - borderWidth, cutOutRect.top + cornerRadius)
        ..lineTo(cutOutRect.left - borderWidth, cutOutRect.top - borderWidth + cornerRadius)
        ..quadraticBezierTo(
          cutOutRect.left - borderWidth,
          cutOutRect.top - borderWidth,
          cutOutRect.left - borderWidth + cornerRadius,
          cutOutRect.top - borderWidth,
        )
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.top - borderWidth),
      borderPaint,
    );
    
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left + cornerRadius, cutOutRect.top - borderWidth)
        ..lineTo(cutOutRect.left - borderWidth + cornerRadius, cutOutRect.top - borderWidth)
        ..quadraticBezierTo(
          cutOutRect.left - borderWidth,
          cutOutRect.top - borderWidth,
          cutOutRect.left - borderWidth,
          cutOutRect.top - borderWidth + cornerRadius,
        )
        ..lineTo(cutOutRect.left - borderWidth, cutOutRect.top + borderLength),
      borderPaint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right + borderWidth - cornerRadius, cutOutRect.top - borderWidth)
        ..lineTo(cutOutRect.right + borderWidth - cornerRadius, cutOutRect.top - borderWidth)
        ..quadraticBezierTo(
          cutOutRect.right + borderWidth,
          cutOutRect.top - borderWidth,
          cutOutRect.right + borderWidth,
          cutOutRect.top - borderWidth + cornerRadius,
        )
        ..lineTo(cutOutRect.right + borderWidth, cutOutRect.top + borderLength),
      borderPaint,
    );
    
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.top - borderWidth)
        ..lineTo(cutOutRect.right + borderWidth - cornerRadius, cutOutRect.top - borderWidth)
        ..quadraticBezierTo(
          cutOutRect.right + borderWidth,
          cutOutRect.top - borderWidth,
          cutOutRect.right + borderWidth,
          cutOutRect.top - borderWidth + cornerRadius,
        )
        ..lineTo(cutOutRect.right + borderWidth, cutOutRect.top + borderLength),
      borderPaint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left - borderWidth, cutOutRect.bottom - borderLength)
        ..lineTo(cutOutRect.left - borderWidth, cutOutRect.bottom + borderWidth - cornerRadius)
        ..quadraticBezierTo(
          cutOutRect.left - borderWidth,
          cutOutRect.bottom + borderWidth,
          cutOutRect.left - borderWidth + cornerRadius,
          cutOutRect.bottom + borderWidth,
        )
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.bottom + borderWidth),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.bottom + borderWidth)
        ..lineTo(cutOutRect.right + borderWidth - cornerRadius, cutOutRect.bottom + borderWidth)
        ..quadraticBezierTo(
          cutOutRect.right + borderWidth,
          cutOutRect.bottom + borderWidth,
          cutOutRect.right + borderWidth,
          cutOutRect.bottom + borderWidth - cornerRadius,
        )
        ..lineTo(cutOutRect.right + borderWidth, cutOutRect.bottom - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}