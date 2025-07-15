import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/device_entry_model.dart';
import '../models/product_model.dart';

class DeviceEntriesScreen extends StatefulWidget {
  final ProductModel product;
  final int totalQuantity;
  final List<DeviceEntryModel> existingEntries;

  const DeviceEntriesScreen({
    Key? key,
    required this.product,
    required this.totalQuantity,
    this.existingEntries = const [],
  }) : super(key: key);

  @override
  State<DeviceEntriesScreen> createState() => _DeviceEntriesScreenState();
}

class _DeviceEntriesScreenState extends State<DeviceEntriesScreen> {
  final List<DeviceEntryModel> _deviceEntries = [];
  final PageController _pageController = PageController();
  int _currentDeviceIndex = 0;
  bool _isScanning = false;

  // Form controllers
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Dropdown values
  String _selectedColor = 'Black';
  String _selectedStorage = '128GB';
  String _selectedCondition = 'New';

  // Available options
  final List<String> _colors = [
    'Black', 'White', 'Blue', 'Red', 'Gold', 'Silver', 'Gray', 'Green', 'Purple', 'Pink'
  ];
  
  final List<String> _storageOptions = [
    '32GB', '64GB', '128GB', '256GB', '512GB', '1TB', '2TB'
  ];
  
  final List<String> _conditions = [
    'New', 'Used - Excellent', 'Used - Good', 'Used - Fair', 'Refurbished'
  ];

  @override
  void initState() {
    super.initState();
    _deviceEntries.addAll(widget.existingEntries);
    
    // Fill remaining slots with empty entries
    while (_deviceEntries.length < widget.totalQuantity) {
      _deviceEntries.add(DeviceEntryModel(
        color: _selectedColor,
        storage: _selectedStorage,
        condition: _selectedCondition,
      ));
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    _imeiController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadCurrentDevice() {
    if (_currentDeviceIndex < _deviceEntries.length) {
      final device = _deviceEntries[_currentDeviceIndex];
      _serialController.text = device.serialNumber ?? '';
      _imeiController.text = device.imei ?? '';
      _notesController.text = device.notes ?? '';
      _selectedColor = device.color;
      _selectedStorage = device.storage;
      _selectedCondition = device.condition;
    }
  }

  void _saveCurrentDevice() {
    if (_currentDeviceIndex < _deviceEntries.length) {
      setState(() {
        _deviceEntries[_currentDeviceIndex] = DeviceEntryModel(
          serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
          imei: _imeiController.text.trim().isEmpty ? null : _imeiController.text.trim(),
          color: _selectedColor,
          storage: _selectedStorage,
          condition: _selectedCondition,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      });
    }
  }

  void _nextDevice() {
    _saveCurrentDevice();
    if (_currentDeviceIndex < widget.totalQuantity - 1) {
      setState(() {
        _currentDeviceIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _loadCurrentDevice();
    }
  }

  void _previousDevice() {
    _saveCurrentDevice();
    if (_currentDeviceIndex > 0) {
      setState(() {
        _currentDeviceIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _loadCurrentDevice();
    }
  }

  void _scanSerialNumber() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => const SerialNumberScannerDialog(),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          _serialController.text = result;
        });
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _finishDeviceEntries() {
    _saveCurrentDevice();
    
    // Validate that all devices have at least serial number or IMEI
    bool hasIncompleteEntries = false;
    for (int i = 0; i < _deviceEntries.length; i++) {
      final device = _deviceEntries[i];
      if ((device.serialNumber?.isEmpty ?? true) && (device.imei?.isEmpty ?? true)) {
        hasIncompleteEntries = true;
        break;
      }
    }

    if (hasIncompleteEntries) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add serial number or IMEI for all devices'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // Return the device entries
    context.pop(_deviceEntries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Device Details - ${widget.product.name}'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _finishDeviceEntries,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Device ${_currentDeviceIndex + 1} of ${widget.totalQuantity}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${((_currentDeviceIndex + 1) / widget.totalQuantity * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mkbhdRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentDeviceIndex + 1) / widget.totalQuantity,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.mkbhdRed),
                ),
              ],
            ),
          ),

          // Device entry form
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentDeviceIndex = index;
                });
                _loadCurrentDevice();
              },
              itemCount: widget.totalQuantity,
              itemBuilder: (context, index) => _buildDeviceForm(),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentDeviceIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousDevice,
                      icon: const Icon(LucideIcons.chevronLeft),
                      label: const Text('Previous'),
                    ),
                  ),
                if (_currentDeviceIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _currentDeviceIndex < widget.totalQuantity - 1 
                        ? _nextDevice 
                        : _finishDeviceEntries,
                    icon: Icon(_currentDeviceIndex < widget.totalQuantity - 1 
                        ? LucideIcons.chevronRight 
                        : LucideIcons.check),
                    label: Text(_currentDeviceIndex < widget.totalQuantity - 1 
                        ? 'Next' 
                        : 'Finish'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Serial Number Section
          Text(
            'Device Identification',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Serial Number Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _serialController,
                  decoration: InputDecoration(
                    labelText: 'Serial Number *',
                    hintText: 'Enter or scan serial number',
                    prefixIcon: const Icon(LucideIcons.hash),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _isScanning ? null : _scanSerialNumber,
                icon: _isScanning 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.camera),
                tooltip: 'Scan Serial Number',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                  foregroundColor: AppTheme.mkbhdRed,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // IMEI Input (for phones)
          if (widget.product.category?.toLowerCase().contains('phone') ?? false)
            TextField(
              controller: _imeiController,
              decoration: InputDecoration(
                labelText: 'IMEI',
                hintText: 'Enter IMEI number',
                prefixIcon: const Icon(LucideIcons.smartphone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),

          const SizedBox(height: 24),

          // Device Specifications
          Text(
            'Device Specifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Color Selection
          DropdownButtonFormField<String>(
            value: _selectedColor,
            decoration: InputDecoration(
              labelText: 'Color',
              prefixIcon: const Icon(LucideIcons.palette),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _colors.map((color) {
              return DropdownMenuItem(
                value: color,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getColorFromName(color),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(color),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedColor = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Storage Selection
          DropdownButtonFormField<String>(
            value: _selectedStorage,
            decoration: InputDecoration(
              labelText: 'Storage',
              prefixIcon: const Icon(LucideIcons.hardDrive),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _storageOptions.map((storage) {
              return DropdownMenuItem(
                value: storage,
                child: Text(storage),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStorage = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Condition Selection
          DropdownButtonFormField<String>(
            value: _selectedCondition,
            decoration: InputDecoration(
              labelText: 'Condition',
              prefixIcon: const Icon(LucideIcons.star),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _conditions.map((condition) {
              return DropdownMenuItem(
                value: condition,
                child: Text(condition),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCondition = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'Any additional notes about this device',
              prefixIcon: const Icon(LucideIcons.fileText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey.shade400;
      case 'gray':
        return Colors.grey;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

class SerialNumberScannerDialog extends StatefulWidget {
  const SerialNumberScannerDialog({Key? key}) : super(key: key);

  @override
  State<SerialNumberScannerDialog> createState() => _SerialNumberScannerDialogState();
}

class _SerialNumberScannerDialogState extends State<SerialNumberScannerDialog> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _foundBarcode(BarcodeCapture capture) {
    if (!_screenOpened) {
      final String code = capture.barcodes.first.rawValue ?? '';
      _screenOpened = true;
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Container(
        height: 400,
        child: Column(
          children: [
            AppBar(
              title: const Text('Scan Serial Number'),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: MobileScanner(
                controller: cameraController,
                onDetect: _foundBarcode,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Point camera at serial number or barcode',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
