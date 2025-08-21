import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
    
    // Ensure we don't exceed the total quantity limit
    final maxEntries = widget.totalQuantity;
    if (_deviceEntries.length > maxEntries) {
      // Trim excess entries if somehow they exceed the limit
      _deviceEntries.removeRange(maxEntries, _deviceEntries.length);
    }
    
    // Fill remaining slots with empty entries up to the total quantity
    while (_deviceEntries.length < maxEntries) {
      _deviceEntries.add(DeviceEntryModel(
        color: _selectedColor,
        storage: _selectedStorage,
        condition: _selectedCondition,
      ));
    }
    
    // Load the first device
    _loadCurrentDevice();
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
    
    // Validate that we don't exceed the quantity limit
    if (_deviceEntries.length > widget.totalQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot have more than ${widget.totalQuantity} device entries'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }
    
    // Validate that all devices have at least serial number or IMEI
    bool hasIncompleteEntries = false;
    List<int> incompleteIndices = [];
    
    for (int i = 0; i < _deviceEntries.length; i++) {
      final device = _deviceEntries[i];
      if ((device.serialNumber?.isEmpty ?? true) && (device.imei?.isEmpty ?? true)) {
        hasIncompleteEntries = true;
        incompleteIndices.add(i + 1); // Human-readable index
      }
    }

    if (hasIncompleteEntries) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add serial number or IMEI for all devices. Missing: Device ${incompleteIndices.join(', ')}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // Validate for duplicate IMEI/Serial numbers
    Set<String> seenSerials = {};
    Set<String> seenImeis = {};
    List<String> duplicates = [];
    
    for (int i = 0; i < _deviceEntries.length; i++) {
      final device = _deviceEntries[i];
      
      if (device.serialNumber != null && device.serialNumber!.isNotEmpty) {
        if (seenSerials.contains(device.serialNumber)) {
          duplicates.add('Serial: ${device.serialNumber}');
        } else {
          seenSerials.add(device.serialNumber!);
        }
      }
      
      if (device.imei != null && device.imei!.isNotEmpty) {
        if (seenImeis.contains(device.imei)) {
          duplicates.add('IMEI: ${device.imei}');
        } else {
          seenImeis.add(device.imei!);
        }
      }
    }
    
    if (duplicates.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Duplicate entries found: ${duplicates.join(', ')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully added ${_deviceEntries.length} device entries'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Return the device entries
    context.pop(_deviceEntries);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Add Device Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainer,
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          FilledButton.tonal(
            onPressed: _finishDeviceEntries,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
            child: const Text('Done'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator - Material 3 style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withOpacity(0.3),
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${((_currentDeviceIndex + 1) / widget.totalQuantity * 100).round()}%',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentDeviceIndex + 1) / widget.totalQuantity,
                  backgroundColor: colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  borderRadius: BorderRadius.circular(8),
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

          // Navigation buttons - Material 3 style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withOpacity(0.3),
            ),
            child: Row(
              children: [
                if (_currentDeviceIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousDevice,
                      icon: Icon(LucideIcons.chevronLeft, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: colorScheme.outline),
                        foregroundColor: colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                if (_currentDeviceIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _currentDeviceIndex < widget.totalQuantity - 1 
                        ? _nextDevice 
                        : _finishDeviceEntries,
                    icon: Icon(
                      _currentDeviceIndex < widget.totalQuantity - 1 
                          ? LucideIcons.chevronRight 
                          : LucideIcons.check,
                      size: 18,
                    ),
                    label: Text(_currentDeviceIndex < widget.totalQuantity - 1 
                        ? 'Next' 
                        : 'Finish'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with product info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Device ${_currentDeviceIndex + 1}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // Device Identification Section
          _buildSection(
            title: 'Device Identification',
            icon: LucideIcons.tag,
            child: Column(
              children: [
                // Serial Number Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _serialController,
                        decoration: InputDecoration(
                          labelText: 'Serial Number *',
                          hintText: 'Enter or scan serial number',
                          prefixIcon: Icon(LucideIcons.hash, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      onPressed: _isScanning ? null : _scanSerialNumber,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: _isScanning 
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            )
                          : Icon(LucideIcons.camera, size: 20),
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
                      prefixIcon: Icon(LucideIcons.smartphone, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    keyboardType: TextInputType.number,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Device Specifications Section
          _buildSection(
            title: 'Device Specifications',
            icon: LucideIcons.settings,
            child: Column(
              children: [
                // Color Selection
                DropdownButtonFormField<String>(
                  value: _selectedColor,
                  decoration: InputDecoration(
                    labelText: 'Color',
                    prefixIcon: Icon(LucideIcons.palette, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                              border: Border.all(color: colorScheme.outline),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                    prefixIcon: Icon(LucideIcons.hardDrive, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                    prefixIcon: Icon(LucideIcons.shieldCheck, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Additional Notes Section
          _buildSection(
            title: 'Additional Notes',
            icon: LucideIcons.fileText,
            child: TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional information about this device',
                prefixIcon: Icon(LucideIcons.fileText, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              maxLines: 3,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Helper method to build consistent sections
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
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
