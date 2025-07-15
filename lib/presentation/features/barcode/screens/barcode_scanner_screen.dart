import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dukalipa_app/core/theme/dukalipa_colors.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> 
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;
  bool _flashOn = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    cameraController.switchCamera();
  }

  void _foundBarcode(BarcodeCapture capture) {
    if (!_screenOpened) {
      final String code = capture.barcodes.first.rawValue ?? '---';
      _screenOpened = true;
      
      // Show result bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _BarcodeResultSheet(
          barcode: code,
          onScanAgain: () {
            _screenOpened = false;
            Navigator.pop(context);
          },
        ),
      ).then((_) {
        _screenOpened = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _foundBarcode,
          ),
          
          // Overlay with scanning area
          _buildScannerOverlay(),
          
          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      
                      // Title
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Scan Barcode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      // Flash toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _flashOn ? LucideIcons.zap : LucideIcons.zapOff,
                            color: _flashOn ? Colors.yellow : Colors.white,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Instructions
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.scan,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Align barcode within frame',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Manual entry
                          _buildActionButton(
                            icon: LucideIcons.keyboard,
                            label: 'Manual Entry',
                            onTap: () => _showManualEntryDialog(),
                          ),
                          
                          // Switch camera
                          _buildActionButton(
                            icon: LucideIcons.switchCamera,
                            label: 'Switch Camera',
                            onTap: _switchCamera,
                          ),
                          
                          // History
                          _buildActionButton(
                            icon: LucideIcons.history,
                            label: 'History',
                            onTap: () => context.push('/barcode/history'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScannerOverlay() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScannerOverlayPainter(
            scanLinePosition: _animation.value,
          ),
          child: Container(),
        );
      },
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showManualEntryDialog() {
    final TextEditingController barcodeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Barcode'),
        content: TextField(
          controller: barcodeController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter barcode number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (barcodeController.text.isNotEmpty) {
                Navigator.pop(context);
                _foundBarcode(
                  BarcodeCapture(
                    barcodes: [
                      Barcode(
                        rawValue: barcodeController.text,
                        format: BarcodeFormat.unknown,
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AirbnbColors.primary,
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanLinePosition;
  
  _ScannerOverlayPainter({required this.scanLinePosition});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );
    
    // Draw overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            scanArea,
            const Radius.circular(20),
          )),
      ),
      paint,
    );
    
    // Draw corners
    final cornerPaint = Paint()
      ..color = AirbnbColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    const cornerLength = 30.0;
    final corners = [
      // Top left
      Path()
        ..moveTo(scanArea.left, scanArea.top + cornerLength)
        ..lineTo(scanArea.left, scanArea.top + 20)
        ..quadraticBezierTo(
          scanArea.left,
          scanArea.top,
          scanArea.left + 20,
          scanArea.top,
        )
        ..lineTo(scanArea.left + cornerLength, scanArea.top),
      // Top right
      Path()
        ..moveTo(scanArea.right - cornerLength, scanArea.top)
        ..lineTo(scanArea.right - 20, scanArea.top)
        ..quadraticBezierTo(
          scanArea.right,
          scanArea.top,
          scanArea.right,
          scanArea.top + 20,
        )
        ..lineTo(scanArea.right, scanArea.top + cornerLength),
      // Bottom left
      Path()
        ..moveTo(scanArea.left, scanArea.bottom - cornerLength)
        ..lineTo(scanArea.left, scanArea.bottom - 20)
        ..quadraticBezierTo(
          scanArea.left,
          scanArea.bottom,
          scanArea.left + 20,
          scanArea.bottom,
        )
        ..lineTo(scanArea.left + cornerLength, scanArea.bottom),
      // Bottom right
      Path()
        ..moveTo(scanArea.right - cornerLength, scanArea.bottom)
        ..lineTo(scanArea.right - 20, scanArea.bottom)
        ..quadraticBezierTo(
          scanArea.right,
          scanArea.bottom,
          scanArea.right,
          scanArea.bottom - 20,
        )
        ..lineTo(scanArea.right, scanArea.bottom - cornerLength),
    ];
    
    for (final corner in corners) {
      canvas.drawPath(corner, cornerPaint);
    }
    
    // Draw scan line
    final scanLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AirbnbColors.primary.withOpacity(0.5),
          AirbnbColors.primary,
          AirbnbColors.primary.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(scanArea.left, 0, scanArea.width, 10));
    
    final scanLineY = scanArea.top + (scanArea.height * scanLinePosition);
    canvas.drawRect(
      Rect.fromLTWH(
        scanArea.left + 10,
        scanLineY - 2,
        scanArea.width - 20,
        4,
      ),
      scanLinePaint,
    );
  }
  
  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanLinePosition != scanLinePosition;
  }
}

class _BarcodeResultSheet extends StatelessWidget {
  final String barcode;
  final VoidCallback onScanAgain;
  
  const _BarcodeResultSheet({
    required this.barcode,
    required this.onScanAgain,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Success icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.checkCircle,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Barcode Scanned',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Barcode display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.scanLine, size: 20),
                const SizedBox(width: 8),
                Text(
                  barcode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Search product button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AirbnbColors.primary.withOpacity(0.9),
                        AirbnbColors.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/inventory/search?barcode=$barcode');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Search Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Add to sale button
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/sales/new?barcode=$barcode');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: BorderSide(color: AirbnbColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Add to Sale'),
                ),
                const SizedBox(height: 12),
                
                // Scan again button
                TextButton(
                  onPressed: onScanAgain,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('Scan Again'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SafeArea(child: Container()),
        ],
      ),
    );
  }
}
