import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../models/product_model.dart';
import '../models/device_entry_model.dart';
import '../providers/inventory_provider.dart';
import '../models/product_group_model.dart';
import 'create_group_screen.dart';
import 'device_entries_screen.dart';

// Simple implementations to avoid import errors
class BarcodeScannerService {
  static Future<String?> scanBarcode(BuildContext context) async {
    // Simulate barcode scanning
    await Future.delayed(const Duration(seconds: 1));
    return '1234567890123';
  }
}

class BarcodeScannerButton extends StatelessWidget {
  final Function(String) onScanned;
  final String tooltip;

  const BarcodeScannerButton({
    Key? key,
    required this.onScanned,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: () async {
          final result = await BarcodeScannerService.scanBarcode(context);
          if (result != null) {
            onScanned(result);
          }
        },
        icon: Icon(
          LucideIcons.scan,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        tooltip: tooltip,
      ),
    );
  }
}

class GroupSelectorWidget extends StatelessWidget {
  final ProductGroupModel? selectedGroup;
  final Function(ProductGroupModel?) onGroupSelected;
  final VoidCallback onCreateGroup;

  const GroupSelectorWidget({
    Key? key,
    required this.selectedGroup,
    required this.onGroupSelected,
    required this.onCreateGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.folder_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Group (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGroup?.name,
                    isExpanded: true,
                    hint: const Text('Select Group'),
                    items: const [], // Empty for now
                    onChanged: (value) {
                      // Handle selection
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: onCreateGroup,
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Create New Group',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // IMEI/Serial Required Categories (High-value electronics with unique identifiers)
  static const List<String> _imeiRequiredCategories = [
    'smartphone', 'phone', 'mobile', 'iphone', 'android',
    'tablet', 'ipad',
    'laptop', 'notebook', 'macbook',
    'desktop', 'computer', 'pc', 'mac',
    'smartwatch', 'apple watch', 'watch',
    'gaming console', 'playstation', 'xbox', 'nintendo',
    'camera', 'dslr', 'mirrorless',
    'drone', 'quadcopter',
    'smart tv', 'television',
    'router', 'modem', 'networking',
    'printer', 'scanner',
    'projector',
    'speaker system', 'soundbar',
    'graphics card', 'gpu',
    'motherboard', 'processor', 'cpu'
  ];

  // Accessory Categories (No IMEI required, simple products)
  static const List<String> _accessoryCategories = [
    'charger', 'charging cable', 'power adapter',
    'cable', 'usb cable', 'hdmi cable', 'audio cable',
    'headphones', 'earphones', 'earbuds', 'headset',
    'case', 'cover', 'screen protector', 'protector',
    'stand', 'holder', 'mount', 'bracket',
    'keyboard', 'mouse', 'mousepad',
    'adapter', 'converter', 'dongle',
    'memory card', 'sd card', 'flash drive', 'usb drive',
    'battery', 'power bank', 'portable charger',
    'stylus', 'pen', 'apple pencil',
    'cleaning kit', 'cloth', 'wipes',
    'bag', 'sleeve', 'pouch',
    'ring light', 'tripod', 'selfie stick',
    'car mount', 'car charger',
    'wireless charger', 'charging pad',
    'splitter', 'hub', 'extension'
  ];

  // Variant Supported Categories (Products with color, size, storage options)
  static const List<String> _variantSupportedCategories = [
    'smartphone', 'phone', 'mobile', 'iphone', 'android',
    'tablet', 'ipad',
    'laptop', 'notebook', 'macbook',
    'smartwatch', 'apple watch', 'watch',
    'headphones', 'earphones', 'earbuds',
    'case', 'cover',
    'clothing', 'shirt', 'pants', 'dress', 'jacket',
    'shoes', 'sneakers', 'boots', 'sandals',
    'bag', 'backpack', 'handbag', 'wallet'
  ];

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _imeiController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockController = TextEditingController();
  final _customCategoryController = TextEditingController();
  
  // Form state
  String? _selectedCategory;
  String? _selectedSupplier;
  ProductGroupModel? _selectedGroup;
  File? _imageFile;
  bool _isLoading = false;
  List<DeviceEntryModel> _deviceEntries = [];
  List<String> _imeiList = [];
  String? _selectedColor;
  String? _selectedSize;
  String? _selectedStorage;
  bool _showCustomCategoryInput = false;
  bool _isClassificationExpanded = false;

  // Simplified category structure with clear groupings
  final Map<String, List<Map<String, dynamic>>> _categoryGroups = {
    'Electronics & Devices': [
      {'name': 'Smartphone', 'icon': LucideIcons.smartphone, 'requiresIMEI': true},
      {'name': 'iPhone', 'icon': LucideIcons.smartphone, 'requiresIMEI': true},
      {'name': 'Tablet', 'icon': LucideIcons.tablet, 'requiresIMEI': true},
      {'name': 'Laptop', 'icon': LucideIcons.laptop, 'requiresIMEI': true},
      {'name': 'Smart Watch', 'icon': LucideIcons.watch, 'requiresIMEI': true},
      {'name': 'Gaming Console', 'icon': LucideIcons.gamepad2, 'requiresIMEI': true},
    ],
    'Accessories': [
      {'name': 'Phone Case', 'icon': LucideIcons.shield, 'requiresIMEI': false},
      {'name': 'Charger', 'icon': LucideIcons.plug, 'requiresIMEI': false},
      {'name': 'Headphones', 'icon': LucideIcons.headphones, 'requiresIMEI': false},
      {'name': 'Cable', 'icon': LucideIcons.plug, 'requiresIMEI': false},
      {'name': 'Power Bank', 'icon': LucideIcons.battery, 'requiresIMEI': false},
      {'name': 'Screen Protector', 'icon': LucideIcons.shield, 'requiresIMEI': false},
    ],
    'Other Products': [
      {'name': 'Clothing', 'icon': LucideIcons.shirt, 'requiresIMEI': false},
      {'name': 'Food & Drinks', 'icon': LucideIcons.coffee, 'requiresIMEI': false},
      {'name': 'Books', 'icon': LucideIcons.book, 'requiresIMEI': false},
      {'name': 'Sports', 'icon': LucideIcons.dumbbell, 'requiresIMEI': false},
      {'name': 'Beauty', 'icon': LucideIcons.sparkles, 'requiresIMEI': false},
      {'name': 'Other', 'icon': LucideIcons.package, 'requiresIMEI': false},
      {'name': 'Custom', 'icon': LucideIcons.edit, 'requiresIMEI': false},
    ],
  };

  final List<String> _colors = [
    'Black', 'White', 'Blue', 'Red', 'Gold', 'Silver', 'Gray', 
    'Green', 'Purple', 'Pink', 'Rose Gold', 'Space Gray', 'Midnight'
  ];

  final List<String> _sizes = [
    'XS', 'S', 'M', 'L', 'XL', 'XXL', '32', '34', '36', '38', '40', '42', '44'
  ];

  final List<String> _storageOptions = [
    '32GB', '64GB', '128GB', '256GB', '512GB', '1TB', '2TB'
  ];
  
  final List<String> _suppliers = [
    'Local Supplier',
    'International Distributor',
    'Direct Import',
    'Wholesale Partner'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateFormWithProduct(widget.product!);
    }
  }

  void _populateFormWithProduct(ProductModel product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _barcodeController.text = product.barcode ?? '';
    _sellingPriceController.text = product.sellingPrice.toString();
    _costPriceController.text = product.costPrice.toString();
    _quantityController.text = product.quantity.toString();
    _lowStockController.text = product.lowStockThreshold.toString();
    _selectedCategory = product.category;
    _selectedSupplier = product.supplier;
    _deviceEntries = product.deviceEntries ?? [];
    
    // Extract IMEI list from device entries if available
    if (product.deviceEntries != null && product.deviceEntries!.isNotEmpty) {
      _imeiList = product.deviceEntries!
          .where((entry) => entry.serialNumber != null && entry.serialNumber!.isNotEmpty)
          .map((entry) => entry.serialNumber!)
          .toList();
      
      // Set variant selections from first device entry
      final firstEntry = product.deviceEntries!.first;
      _selectedColor = firstEntry.color;
      _selectedStorage = firstEntry.storage;
    }
  }

  bool get _requiresIMEI {
    if (_selectedCategory == null) return false;
    
    // Check from category groups first
    for (final group in _categoryGroups.values) {
      for (final category in group) {
        if (category['name'] == _selectedCategory) {
          return category['requiresIMEI'] as bool;
        }
      }
    }
    
    // Fallback to name-based detection
    final categoryLower = _selectedCategory!.toLowerCase();
    final productNameLower = _nameController.text.toLowerCase();
    
    // Check if it's explicitly an accessory
    final isAccessory = _accessoryCategories.any((accessory) =>
        categoryLower.contains(accessory) || 
        productNameLower.contains(accessory));
    
    if (isAccessory) return false;
    
    // Check if it requires IMEI based on category or product name
    final requiresIMEI = _imeiRequiredCategories.any((category) =>
        categoryLower.contains(category) || 
        productNameLower.contains(category));
    
    return requiresIMEI;
  }

  bool get _isAccessoryProduct {
    if (_selectedCategory == null) return false;
    
    // Check from category groups first
    for (final group in _categoryGroups.values) {
      for (final category in group) {
        if (category['name'] == _selectedCategory) {
          return !(category['requiresIMEI'] as bool);
        }
      }
    }
    
    // Fallback to name-based detection
    final categoryLower = _selectedCategory!.toLowerCase();
    final productNameLower = _nameController.text.toLowerCase();
    
    return _accessoryCategories.any((accessory) =>
        categoryLower.contains(accessory) || 
        productNameLower.contains(accessory));
  }

  bool get _supportsVariants {
    if (_selectedCategory == null) return false;
    
    final categoryLower = _selectedCategory!.toLowerCase();
    final productNameLower = _nameController.text.toLowerCase();
    
    return _variantSupportedCategories.any((category) =>
        categoryLower.contains(category) || 
        productNameLower.contains(category));
  }

  bool get _shouldShowDeviceEntries {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    return _requiresIMEI && quantity > 1;
  }

  bool get _shouldShowColorVariants {
    return _supportsVariants && !_isAccessoryProduct;
  }

  bool get _shouldShowSizeVariants {
    if (_selectedCategory == null) return false;
    
    final categoryLower = _selectedCategory!.toLowerCase();
    final productNameLower = _nameController.text.toLowerCase();
    
    return (categoryLower.contains('clothing') || categoryLower.contains('shoes') ||
            productNameLower.contains('shirt') || productNameLower.contains('pants') ||
            productNameLower.contains('dress') || productNameLower.contains('shoes') ||
            productNameLower.contains('jacket') || productNameLower.contains('boot'));
  }

  bool get _shouldShowStorageVariants {
    if (_selectedCategory == null) return false;
    
    final categoryLower = _selectedCategory!.toLowerCase();
    final productNameLower = _nameController.text.toLowerCase();
    
    return (categoryLower.contains('phone') || categoryLower.contains('tablet') ||
            categoryLower.contains('laptop') || categoryLower.contains('computer') ||
            productNameLower.contains('iphone') || productNameLower.contains('ipad') ||
            productNameLower.contains('samsung') || productNameLower.contains('macbook'));
  }

  Future<void> _navigateToDeviceEntries() async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid quantity first'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Create a temporary product model for the device entries screen
    final tempProduct = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.isEmpty ? 'New Product' : _nameController.text,
      description: _descriptionController.text,
      barcode: _barcodeController.text,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
      costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
      quantity: quantity,
      lowStockThreshold: int.tryParse(_lowStockController.text) ?? 0,
      category: _selectedCategory ?? 'Other',
      supplier: _selectedSupplier ?? 'Local Supplier',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await Navigator.of(context).push<List<DeviceEntryModel>>(
      MaterialPageRoute(
        builder: (context) => DeviceEntriesScreen(
          product: tempProduct,
          totalQuantity: quantity,
          existingEntries: _deviceEntries,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _deviceEntries = result;
      });
    }
  }

  Future<void> _scanIMEI() async {
    // Check if quantity limit would be exceeded
    final currentQuantity = int.tryParse(_quantityController.text) ?? 0;
    if (_imeiList.length >= currentQuantity && currentQuantity > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add more IMEI/Serial numbers. Maximum quantity is $currentQuantity'),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    try {
      final result = await BarcodeScannerService.scanBarcode(context);
      if (result != null && result.isNotEmpty) {
        setState(() {
          if (!_imeiList.contains(result)) {
            _imeiList.add(result);
            _imeiController.text = result;
          } else {
            // Show message if IMEI already exists
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('This IMEI/Serial number already exists'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning IMEI: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _addIMEIManually() {
    // Check if quantity limit would be exceeded
    final currentQuantity = int.tryParse(_quantityController.text) ?? 0;
    if (_imeiList.length >= currentQuantity && currentQuantity > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add more IMEI/Serial numbers. Maximum quantity is $currentQuantity'),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    final imei = _imeiController.text.trim();
    if (imei.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an IMEI/Serial number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_imeiList.contains(imei)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This IMEI/Serial number already exists'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _imeiList.add(imei);
      _imeiController.clear();
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added IMEI/Serial: $imei (${_imeiList.length}/$currentQuantity)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeIMEI(String imei) {
    setState(() {
      _imeiList.remove(imei);
    });
  }

  // Auto-detect category based on product name
  void _autoDetectCategory(String productName) {
    if (productName.isEmpty) {
      setState(() {
        _selectedCategory = null;
      });
      return;
    }

    final detectedCategory = _getAutoDetectedCategory();
    if (detectedCategory != null && _selectedCategory != detectedCategory) {
      setState(() {
        _selectedCategory = detectedCategory;
      });
    }
  }

  // Get auto-detected category from product name
  String? _getAutoDetectedCategory() {
    final productNameLower = _nameController.text.toLowerCase();
    
    if (productNameLower.isEmpty) return null;

    // Check each category group for matches
    for (final group in _categoryGroups.values) {
      for (final category in group) {
        final categoryName = category['name'] as String;
        final categoryLower = categoryName.toLowerCase();
        
        // Direct matches
        if (productNameLower.contains(categoryLower)) {
          return categoryName;
        }
        
        // Smart keyword detection
        if (categoryName == 'iPhone' && 
            (productNameLower.contains('iphone') || productNameLower.contains('ios'))) {
          return 'iPhone';
        }
        
        if (categoryName == 'Smartphone' && 
            (productNameLower.contains('samsung') || productNameLower.contains('galaxy') || 
             productNameLower.contains('pixel') || productNameLower.contains('android') ||
             productNameLower.contains('huawei') || productNameLower.contains('xiaomi') ||
             productNameLower.contains('oppo') || productNameLower.contains('vivo'))) {
          return 'Smartphone';
        }
        
        if (categoryName == 'Laptop' && 
            (productNameLower.contains('macbook') || productNameLower.contains('thinkpad') ||
             productNameLower.contains('dell') || productNameLower.contains('hp') ||
             productNameLower.contains('asus') || productNameLower.contains('lenovo'))) {
          return 'Laptop';
        }
        
        if (categoryName == 'Tablet' && 
            (productNameLower.contains('ipad') || productNameLower.contains('tab '))) {
          return 'Tablet';
        }
        
        if (categoryName == 'Smart Watch' && 
            (productNameLower.contains('apple watch') || productNameLower.contains('galaxy watch') ||
             productNameLower.contains('fitbit') || productNameLower.contains('garmin'))) {
          return 'Smart Watch';
        }
        
        if (categoryName == 'Charger' && 
            (productNameLower.contains('charger') || productNameLower.contains('adapter'))) {
          return 'Charger';
        }
        
        if (categoryName == 'Phone Case' && 
            (productNameLower.contains('case') || productNameLower.contains('cover'))) {
          return 'Phone Case';
        }
        
        if (categoryName == 'Headphones' && 
            (productNameLower.contains('airpods') || productNameLower.contains('headphone') ||
             productNameLower.contains('earphone') || productNameLower.contains('earbud'))) {
          return 'Headphones';
        }
      }
    }
    
    return null;
  }

  // Category Suggestion Widget
  Widget _buildCategorySuggestion() {
    final suggestedCategory = _getAutoDetectedCategory();
    if (suggestedCategory == null) return const SizedBox.shrink();

    final isAlreadySelected = _selectedCategory == suggestedCategory;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.lightbulb,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAlreadySelected ? 'Category Auto-Selected' : 'Suggested Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  suggestedCategory,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (!isAlreadySelected) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = suggestedCategory;
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Use',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ] else ...[
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _imeiController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _quantityController.dispose();
    _lowStockController.dispose();
    _customCategoryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate IMEI requirements for electronic products
    if (_requiresIMEI) {
      final quantity = int.parse(_quantityController.text);
      if (_imeiList.length != quantity && _deviceEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add IMEI/Serial numbers for all ${quantity} devices'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      
      List<DeviceEntryModel>? finalDeviceEntries;
      
      // Create device entries if we have IMEI list but no existing device entries
      if (_imeiList.isNotEmpty && _deviceEntries.isEmpty) {
        finalDeviceEntries = _imeiList.map((imei) => DeviceEntryModel(
          serialNumber: imei,
          imei: imei.length == 15 ? imei : null, // Only set IMEI if 15 digits
          color: _selectedColor ?? 'Black',
          storage: _selectedStorage ?? '128GB',
          condition: 'New',
          notes: '',
        )).toList();
      } else if (_deviceEntries.isNotEmpty) {
        finalDeviceEntries = _deviceEntries;
      }
      
      final finalCategory = _showCustomCategoryInput 
        ? _customCategoryController.text.trim()
        : _selectedCategory ?? 'Other';
      
      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        barcode: _barcodeController.text.trim(),
        sellingPrice: double.parse(_sellingPriceController.text),
        costPrice: double.parse(_costPriceController.text),
        quantity: int.parse(_quantityController.text),
        lowStockThreshold: int.parse(_lowStockController.text),
        category: finalCategory,
        supplier: _selectedSupplier ?? 'Local Supplier',
        imageUrl: widget.product?.imageUrl,
        metadata: widget.product?.metadata,
        deviceEntries: finalDeviceEntries,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product != null) {
        // Update existing product
        await inventoryProvider.updateProduct(product, imageFile: _imageFile);
      } else {
        // Create new product
        await inventoryProvider.createProduct(product, imageFile: _imageFile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product != null 
                ? 'Product updated successfully!' 
                : 'Product created successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Product Type Indicator Widget
  Widget _buildProductTypeIndicator() {
    final category = _selectedCategory ?? _getAutoDetectedCategory();
    if (category == null) return const SizedBox.shrink();

    final requiresIMEI = _requiresIMEI;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: requiresIMEI 
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              requiresIMEI ? Icons.smartphone : Icons.inventory_2,
              color: requiresIMEI 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSecondaryContainer,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Type: $category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  requiresIMEI 
                    ? 'IMEI/Serial tracking enabled'
                    : 'Simple inventory tracking',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (requiresIMEI) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Trackable',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.product != null ? 'Edit Product' : 'Add Product',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Section
                    _buildImageSection(),
                    const SizedBox(height: 20),
                    
                    // Basic Information (Product name, auto-detection, quantity, etc.)
                    _buildBasicInfoSection(),
                    const SizedBox(height: 20),
                    
                    // Pricing Section
                    _buildPricingSection(),
                    const SizedBox(height: 20),
                    
                    // Inventory Section
                    _buildInventorySection(),
                    const SizedBox(height: 20),
                    
                    // Device Entries Section (for electronics with quantity > 1)
                    if (_shouldShowDeviceEntries) ...[
                      _buildDeviceEntriesSection(),
                      const SizedBox(height: 20),
                    ],
                    
                    // Group Section
                    GroupSelectorWidget(
                      selectedGroup: _selectedGroup,
                      onGroupSelected: (group) {
                        setState(() {
                          _selectedGroup = group;
                        });
                      },
                      onCreateGroup: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateGroupScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Optional Classification Section (moved to end for better flow)
                    _buildOptionalClassificationSection(),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveProduct,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        label: Text(
          widget.product != null ? 'Update' : 'Save',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : widget.product?.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add image',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        // Product Name (First - drives everything else)
        CustomTextField(
          controller: _nameController,
          labelText: 'Product Name',
          hintText: 'e.g., iPhone 15 Pro, Samsung Galaxy, MacBook...',
          prefixIcon: Icons.inventory_2_outlined,
          onChanged: (value) {
            // Auto-detect category and update UI based on product name
            _autoDetectCategory(value);
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Product name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Auto-detected Category Suggestion
        if (_getAutoDetectedCategory() != null) ...[
          _buildCategorySuggestion(),
          const SizedBox(height: 16),
        ],
        
        // Quantity (Second - determines IMEI requirements)
        CustomTextField(
          controller: _quantityController,
          labelText: 'Quantity',
          hintText: 'How many items?',
          prefixIcon: Icons.inventory_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Quantity is required';
            }
            final quantity = int.tryParse(value);
            if (quantity == null || quantity <= 0) {
              return 'Enter a valid quantity';
            }
            return null;
          },
          onChanged: (value) {
            // Validate IMEI list when quantity changes
            final newQuantity = int.tryParse(value) ?? 0;
            if (newQuantity > 0 && _imeiList.length > newQuantity) {
              // Remove excess IMEI entries
              setState(() {
                _imeiList.removeRange(newQuantity, _imeiList.length);
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${_imeiList.length - newQuantity} excess IMEI entries to match quantity'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            
            // Clear device entries if quantity is reduced
            if (newQuantity > 0 && _deviceEntries.length > newQuantity) {
              setState(() {
                _deviceEntries.removeRange(newQuantity, _deviceEntries.length);
              });
            }
            
            setState(() {});
          },
        ),
        const SizedBox(height: 16),

        // Product Type Indicator (shows what was detected)
        if (_selectedCategory != null || _nameController.text.isNotEmpty) ...[
          _buildProductTypeIndicator(),
          const SizedBox(height: 16),
        ],
        
        // Description (Optional)
        CustomTextField(
          controller: _descriptionController,
          labelText: 'Description (Optional)',
          hintText: 'Additional details about the product',
          prefixIcon: Icons.description_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        
        // Barcode (Third - for identification)
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _barcodeController,
                labelText: 'Barcode (Optional)',
                hintText: 'Scan or enter barcode',
                prefixIcon: Icons.qr_code_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            BarcodeScannerButton(
              onScanned: (barcode) {
                _barcodeController.text = barcode;
              },
              tooltip: 'Scan Barcode',
            ),
          ],
        ),
        
        // IMEI/Serial Number Section (only for detected electronic products)
        if (_requiresIMEI) ...[
          const SizedBox(height: 16),
          _buildIMEISection(),
        ],
        
        // Variant Options (colors, sizes, storage) - only when relevant
        if (_shouldShowColorVariants) ...[
          const SizedBox(height: 16),
          _buildColorVariantsSection(),
        ],
        
        if (_shouldShowSizeVariants) ...[
          const SizedBox(height: 16),
          _buildSizeVariantsSection(),
        ],
        
        if (_shouldShowStorageVariants) ...[
          const SizedBox(height: 16),
          _buildStorageVariantsSection(),
        ],
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _costPriceController,
                labelText: 'Cost Price',
                hintText: '0.00',
                prefixIcon: Icons.attach_money_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cost price is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _sellingPriceController,
                labelText: 'Selling Price',
                hintText: '0.00',
                prefixIcon: Icons.sell_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Selling price is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lowStockController,
          labelText: 'Low Stock Alert Threshold',
          hintText: 'Enter minimum stock level',
          prefixIcon: Icons.warning_amber_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Low stock threshold is required';
            }
            if (int.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionalClassificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collapsible header
        InkWell(
          onTap: () {
            setState(() {
              _isClassificationExpanded = !_isClassificationExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Settings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isClassificationExpanded 
                          ? 'Tap to hide category and supplier options'
                          : 'Tap to set custom category and supplier',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isClassificationExpanded 
                    ? Icons.expand_less 
                    : Icons.expand_more,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        
        // Expandable content
        if (_isClassificationExpanded) ...[
          const SizedBox(height: 16),
          
          // Category Override Section
          Text(
            'Category Override',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The category is auto-detected. Override only if needed.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          
          // Category Grid Selection
          _buildCategoryGrid(),
          
          // Custom Category Input
          if (_showCustomCategoryInput) ...[
            const SizedBox(height: 8),
            CustomTextField(
              controller: _customCategoryController,
              labelText: 'Custom Category',
              hintText: 'Enter your custom category',
              prefixIcon: LucideIcons.edit,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value.isNotEmpty ? value : null;
                });
              },
              validator: _showCustomCategoryInput ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a custom category';
                }
                return null;
              } : null,
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Supplier Selection
          Text(
            'Supplier (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedSupplier,
            items: _suppliers,
            hint: 'Select Supplier',
            onChanged: (value) {
              setState(() {
                _selectedSupplier = value;
              });
            },
            icon: Icons.business_outlined,
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  hint,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // IMEI/Serial Number Section
  Widget _buildIMEISection() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.smartphone,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'IMEI/Serial Numbers',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // IMEI Input Row
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _imeiController,
                labelText: 'IMEI/Serial Number',
                hintText: _imeiList.length >= quantity && quantity > 0 
                    ? 'Limit reached ($quantity/$quantity)' 
                    : 'Enter or scan IMEI/Serial',
                prefixIcon: LucideIcons.hash,
                enabled: _imeiList.length < quantity || quantity <= 0,
                onChanged: (value) {
                  // Auto-add when enter is pressed or field is complete
                  if (value.length >= 10 && (_imeiList.length < quantity || quantity <= 0)) {
                    _addIMEIManually();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: (_imeiList.length >= quantity && quantity > 0)
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: (_imeiList.length >= quantity && quantity > 0) ? null : _scanIMEI,
                icon: Icon(
                  LucideIcons.scan,
                  color: (_imeiList.length >= quantity && quantity > 0)
                      ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)
                      : Theme.of(context).colorScheme.primary,
                ),
                tooltip: (_imeiList.length >= quantity && quantity > 0) 
                    ? 'Limit reached' 
                    : 'Scan IMEI',
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: (_imeiList.length >= quantity && quantity > 0)
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: (_imeiList.length >= quantity && quantity > 0) ? null : _addIMEIManually,
                icon: Icon(
                  Icons.add,
                  color: (_imeiList.length >= quantity && quantity > 0)
                      ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)
                      : Theme.of(context).colorScheme.secondary,
                ),
                tooltip: (_imeiList.length >= quantity && quantity > 0) 
                    ? 'Limit reached' 
                    : 'Add IMEI',
              ),
            ),
          ],
        ),
        
        // IMEI List
        if (_imeiList.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMEI/Serial Numbers (${_imeiList.length}/$quantity)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ...(_imeiList.map((imei) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          imei,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeIMEI(imei),
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ))),
              ],
            ),
          ),
        ],
        
        // Status indicator and warnings for IMEI count vs quantity
        if (quantity > 0) ...[
          const SizedBox(height: 8),
          if (_imeiList.length == quantity) ...[
            // Success state - IMEI count matches quantity
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All ${quantity} IMEI/Serial numbers added',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_imeiList.length < quantity) ...[
            // Warning state - need more IMEI entries
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add ${quantity - _imeiList.length} more IMEI/Serial numbers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_imeiList.length > quantity) ...[
            // Error state - too many IMEI entries (shouldn't happen with validation)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Too many IMEI entries! Remove ${_imeiList.length - quantity} entries',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  // Color Variants Section
  Widget _buildColorVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.palette,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Color Options',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _selectedColor,
          items: _colors,
          hint: 'Select Color',
          onChanged: (value) {
            setState(() {
              _selectedColor = value;
            });
          },
          icon: LucideIcons.palette,
        ),
      ],
    );
  }

  // Size Variants Section
  Widget _buildSizeVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.ruler,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Size Options',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _selectedSize,
          items: _sizes,
          hint: 'Select Size',
          onChanged: (value) {
            setState(() {
              _selectedSize = value;
            });
          },
          icon: LucideIcons.ruler,
        ),
      ],
    );
  }

  // Storage Variants Section
  Widget _buildStorageVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.hardDrive,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Storage Options',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _selectedStorage,
          items: _storageOptions,
          hint: 'Select Storage',
          onChanged: (value) {
            setState(() {
              _selectedStorage = value;
            });
          },
          icon: LucideIcons.hardDrive,
        ),
      ],
    );
  }

  // Device Entries Section
  Widget _buildDeviceEntriesSection() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.smartphone,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Device Management',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Individual Devices',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add serial numbers, colors, and storage for each device',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_deviceEntries.length}/$quantity devices',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _navigateToDeviceEntries,
                    icon: Icon(LucideIcons.plus, size: 16),
                    label: Text('Manage Devices'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Category Grid Builder
  Widget _buildCategoryGrid() {
    return Column(
      children: _categoryGroups.entries.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Title
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                group.key,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            
            // Category Items Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: group.value.length,
              itemBuilder: (context, index) {
                final category = group.value[index];
                final isSelected = _selectedCategory == category['name'];
                final requiresIMEI = category['requiresIMEI'] as bool;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (category['name'] == 'Custom') {
                        _showCustomCategoryInput = true;
                        _selectedCategory = null;
                      } else {
                        _selectedCategory = category['name'];
                        _showCustomCategoryInput = false;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 16,
                          color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (requiresIMEI) ...[
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.shield,
                            size: 10,
                            color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
