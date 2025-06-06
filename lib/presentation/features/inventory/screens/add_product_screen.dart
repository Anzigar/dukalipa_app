import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../models/product_model.dart';
import '../repositories/inventory_repository.dart';
import '../models/product_group_model.dart';
import 'create_group_screen.dart';

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
            border: Border.all(color: Colors.grey.shade400),
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

// Simple ApiClient implementation
class ApiClient {
  // Placeholder implementation
}

// Simple InventoryRepositoryImpl
class InventoryRepositoryImpl implements InventoryRepository {
  final ApiClient apiClient;
  
  InventoryRepositoryImpl(this.apiClient);
  
  @override
  Future<ProductModel> createProduct(ProductModel product, {File? imageFile}) async {
    await Future.delayed(const Duration(seconds: 1));
    return product;
  }
  
  @override
  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? supplier,
    int? page,
    int? pageSize,
  }) async {
    return [];
  }
  
  @override
  Future<List<String>> getCategories() async {
    return ['Electronics', 'Clothing', 'Food', 'Beverages', 'Stationery', 'Other'];
  }
  
  @override
  Future<List<String>> getSuppliers() async {
    return ['Local Supplier', 'International Distributor'];
  }
  
  @override
  Future<void> deleteProduct(String productId) async {
    // Simulate deletion
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<int> getLowStockCount() async {
    // Simulate low stock count
    await Future.delayed(const Duration(milliseconds: 200));
    return 0;
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    // Simulate fetching a product by ID
    await Future.delayed(const Duration(milliseconds: 200));
    // Return a dummy ProductModel to satisfy non-nullable contract
    return ProductModel(
      id: productId,
      name: 'Sample Product',
      description: 'Sample Description',
      barcode: '1234567890123',
      sellingPrice: 1000.0,
      costPrice: 800.0,
      quantity: 10,
      lowStockThreshold: 2,
      category: 'Electronics',
      supplier: 'Local Supplier',
      imageUrl: null,
      metadata: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product, {File? imageFile}) async {
    // Simulate update
    await Future.delayed(const Duration(milliseconds: 400));
    return product;
  }
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  
  // Electronics specific controllers
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _warrantyPeriodController = TextEditingController();
  final _technicalSpecsController = TextEditingController();
  
  // Add missing controllers
  final _storageController = TextEditingController();
  
  String _selectedCategory = '';
  String _selectedSupplier = '';
  final List<String> _categories = ['Electronics', 'Clothing', 'Food', 'Beverages', 'Stationery', 'Other'];
  final List<String> _suppliers = ['Local Supplier', 'International Distributor', 'Wholesale Market', 'Direct Factory', 'Online Store'];
  final List<String> _conditions = ['New', 'Refurbished', 'Used', 'Open Box'];
  String _selectedCondition = 'New';
  
  File? _productImage;
  bool _isLoading = false;
  late InventoryRepository _repository;
  
  // For step-based form
  int _currentStep = 0;
  
  // Animation controller for loading animation
  late AnimationController _loadingController;
  
  // New fields for bulk IMEI entry
  bool _isBulkEntry = false;
  int _totalQuantity = 1;
  List<Map<String, String>> _productUnits = [];
  int _currentUnitIndex = 0;
  final _imeiController = TextEditingController();
  final _unitSerialController = TextEditingController();
  final Set<String> _usedImeis = {};
  
  // Add group selection
  ProductGroupModel? _selectedGroup;
  
  @override
  void initState() {
    super.initState();
    // Set default low stock threshold
    _lowStockThresholdController.text = '5';
    
    // Initialize loading animation controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Initialize repository with simple implementation
    _repository = InventoryRepositoryImpl(ApiClient());
  }
  
  void _initRepository() {
    try {
      _repository = Provider.of<InventoryRepository>(context, listen: false);
    } catch (e) {
      // Use simple implementation if provider fails
      _repository = InventoryRepositoryImpl(ApiClient());
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _quantityController.dispose();
    _lowStockThresholdController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _warrantyPeriodController.dispose();
    _technicalSpecsController.dispose();
    _loadingController.dispose();
    _imeiController.dispose();
    _unitSerialController.dispose();
    _storageController.dispose(); // Add this line
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );
    
    if (image != null) {
      setState(() {
        _productImage = File(image.path);
      });
    }
  }
  
  void _removeImage() {
    setState(() {
      _productImage = null;
    });
  }
  
  // Updated barcode scanner method using new service
  Future<void> _scanBarcode() async {
    try {
      final result = await BarcodeScannerService.scanBarcode(context);
      if (result != null && result.isNotEmpty) {
        setState(() {
          _barcodeController.text = result;
        });
      }
    } catch (e) {
      if (mounted) {
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
  
  // Updated IMEI scanner method using new service
  Future<void> _scanImeiForCurrentUnit() async {
    try {
      final result = await BarcodeScannerService.scanBarcode(context);
      if (result != null && result.isNotEmpty) {
        // Validate IMEI uniqueness
        if (_usedImeis.contains(result)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('IMEI already used: $result'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          return;
        }
        
        setState(() {
          _imeiController.text = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan IMEI: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
  
  // Initialize bulk entry based on quantity
  void _initializeBulkEntry() {
    setState(() {
      _isBulkEntry = true;
      _totalQuantity = int.tryParse(_quantityController.text) ?? 1;
      _productUnits = List.generate(_totalQuantity, (index) => {
        'imei': '',
        'serialNumber': '',
        'unit': '${index + 1}',
      });
      _currentUnitIndex = 0;
    });
  }
  
  // Save current unit and move to next
  void _saveCurrentUnit() {
    if (_imeiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter IMEI for this unit'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    // Check IMEI uniqueness
    if (_usedImeis.contains(_imeiController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('IMEI already used: ${_imeiController.text.trim()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    setState(() {
      _productUnits[_currentUnitIndex]['imei'] = _imeiController.text.trim();
      _productUnits[_currentUnitIndex]['serialNumber'] = _unitSerialController.text.trim();
      _usedImeis.add(_imeiController.text.trim());
      
      if (_currentUnitIndex < _totalQuantity - 1) {
        _currentUnitIndex++;
        _imeiController.clear();
        _unitSerialController.clear();
      }
    });
  }
  
  // Go back to previous unit
  void _goToPreviousUnit() {
    if (_currentUnitIndex > 0) {
      // Remove current IMEI from used set if going back
      final currentImei = _productUnits[_currentUnitIndex]['imei'];
      if (currentImei?.isNotEmpty == true) {
        _usedImeis.remove(currentImei);
      }
      
      setState(() {
        _currentUnitIndex--;
        _imeiController.text = _productUnits[_currentUnitIndex]['imei'] ?? '';
        _unitSerialController.text = _productUnits[_currentUnitIndex]['serialNumber'] ?? '';
      });
    }
  }
  
  bool _isElectronicsCategory() {
    return _selectedCategory.toLowerCase() == 'electronics';
  }
  
  bool _requiresImeiTracking() {
    if (!_isElectronicsCategory()) return false;
    
    final productName = _nameController.text.toLowerCase();
    return productName.contains('phone') || 
           productName.contains('smartphone') ||
           productName.contains('tablet') ||
           productName.contains('television') ||
           productName.contains('tv') ||
           productName.contains('laptop') ||
           productName.contains('computer');
  }
  
  // Material 3 expressive loading indicator
  Widget _buildMaterial3LoadingIndicator() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primary loading indicator with pulse animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated outer circle
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primaryContainer.withOpacity(0.2 + 0.1 * _loadingController.value),
                          colorScheme.primaryContainer.withOpacity(0),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  );
                },
              ),
              
              // Main circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.primaryContainer.withOpacity(0.2),
                ),
              ),
              
              // Material 3 expressive central icon
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  final scale = 0.8 + 0.2 * ((_loadingController.value - 0.5).abs() * 2);
                  
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Loading label with fade animation
          AnimatedOpacity(
            opacity: 0.7 + 0.3 * ((_loadingController.value - 0.5).abs() * 2),
            duration: const Duration(milliseconds: 150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, _) {
                    final angle = _loadingController.value * 2 * 3.14159;
                    return Transform.rotate(
                      angle: angle,
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: colorScheme.secondary,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Saving product...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Animated dots using Material 3 expressive design
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final delay = index / 5;
                return AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, _) {
                    final value = (((_loadingController.value + delay) % 1) < 0.5)
                        ? ((_loadingController.value + delay) % 1) * 2
                        : (1 - ((_loadingController.value + delay) % 1)) * 2;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: value > 0.5 
                              ? colorScheme.tertiary
                              : colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          
          if (_productImage != null) ...[
            const SizedBox(height: 24),
            
            // Show image preview during upload (without shadow)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _productImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Text(
              'Uploading product image...',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      // Show Material 3 style snackbar if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields correctly'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating, // Material 3 style
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    
    // Validate bulk entry completion if required
    if (_requiresImeiTracking() && _isBulkEntry) {
      final incompleteUnits = _productUnits.where((unit) => unit['imei']?.isEmpty ?? true).length;
      if (incompleteUnits > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please complete IMEI entry for all $incompleteUnits remaining units'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Build metadata with group and IMEI tracking if applicable
      Map<String, dynamic>? metadata = _isElectronicsCategory() ? {
        'brand': _brandController.text,
        'model': _modelController.text,
        'serialNumber': _serialNumberController.text,
        'warrantyPeriod': _warrantyPeriodController.text,
        'technicalSpecs': _technicalSpecsController.text,
        'condition': _selectedCondition,
      } : null;
      
      // Add group information
      if (_selectedGroup != null) {
        metadata ??= {};
        metadata['groupId'] = _selectedGroup!.id;
        metadata['groupName'] = _selectedGroup!.name;
      }
      
      // Add IMEI tracking for bulk products
      if (_requiresImeiTracking() && _isBulkEntry) {
        metadata!['imeiTracking'] = true;
        metadata['units'] = _productUnits;
        metadata['totalUnits'] = _totalQuantity;
      }
      
      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        barcode: _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
        sellingPrice: double.parse(_sellingPriceController.text),
        costPrice: double.parse(_costPriceController.text),
        quantity: int.parse(_quantityController.text),
        lowStockThreshold: int.parse(_lowStockThresholdController.text),
        category: _selectedCategory,
        supplier: _selectedSupplier,
        imageUrl: null,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _repository.createProduct(product, imageFile: _productImage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBulkEntry 
                ? 'Product with ${_totalQuantity} units added to ${_selectedGroup?.name ?? 'inventory'} successfully'
                : 'Product added to ${_selectedGroup?.name ?? 'inventory'} successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // No shadow
        shadowColor: Colors.transparent, // No shadow
        surfaceTintColor: Colors.transparent, // No surface tint
        title: Text(l10n.addProduct ?? 'Add Product'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
          ? _buildMaterial3LoadingIndicator()
          : SafeArea(
              child: Form(
                key: _formKey,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: colorScheme.copyWith(
                      primary: AppTheme.mkbhdRed,
                    ),
                  ),
                  child: Stepper(
                    physics: const ClampingScrollPhysics(),
                    currentStep: _currentStep,
                    elevation: 0, // No shadow on stepper
                    onStepContinue: () {
                      if (_currentStep == 2) {
                        _saveProduct();
                      } else {
                        setState(() {
                          _currentStep += 1;
                        });
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() {
                          _currentStep -= 1;
                        });
                      }
                    },
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: _currentStep == 2 ? 'Save Product' : 'Continue',
                                isLoading: _isLoading,
                                onPressed: details.onStepContinue!,
                              ),
                            ),
                            if (_currentStep > 0) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: details.onStepCancel,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: AppTheme.mkbhdRed),
                                    elevation: 0, // No shadow
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Back'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    steps: [
                      // Step 1: Basic Information
                      Step(
                        title: const Text('Basic Information'),
                        subtitle: const Text('Enter product name, description and category'),
                        content: _buildBasicInfoForm(),
                        isActive: _currentStep >= 0,
                      ),
                      
                      // Step 2: Pricing and Inventory
                      Step(
                        title: const Text('Pricing & Inventory'),
                        subtitle: const Text('Set prices, quantity and stock thresholds'),
                        content: _buildPricingInventoryForm(),
                        isActive: _currentStep >= 1,
                      ),
                      
                      // Step 3: Additional Details
                      Step(
                        title: const Text('Additional Details'),
                        subtitle: Text(_isElectronicsCategory() 
                            ? 'Electronics specific details' 
                            : 'Upload image and set supplier'),
                        content: _isElectronicsCategory() 
                            ? _buildElectronicsForm() 
                            : _buildAdditionalDetailsForm(),
                        isActive: _currentStep >= 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildBasicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name with increased spacing
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0), // Small space above product name
          child: CustomTextField(
            controller: _nameController,
            labelText: 'Product Name*',
            prefixIcon: LucideIcons.tag,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter product name';
              }
              return null;
            },
          ),
        ),
        
        const SizedBox(height: 18), // Slightly increased spacing
        
        // Description
        CustomTextField(
          controller: _descriptionController,
          labelText: 'Description',
          prefixIcon: LucideIcons.alignLeft,
          maxLines: 3,
        ),
        
        const SizedBox(height: 16),
        
        // Group Selector
        GroupSelectorWidget(
          selectedGroup: _selectedGroup,
          onGroupSelected: (group) {
            setState(() {
              _selectedGroup = group;
              // Auto-select category based on group if available
              if (group != null && group.categories.isNotEmpty) {
                final groupCategory = group.categories.first;
                if (_categories.contains(groupCategory)) {
                  _selectedCategory = groupCategory;
                }
              }
            });
          },
          onCreateGroup: () => _showCreateGroupDialog(),
        ),
        
        const SizedBox(height: 16),
        
        // Enhanced Barcode / SKU with new scanner button
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _barcodeController,
                labelText: 'Barcode / SKU (Optional)',
                prefixIcon: LucideIcons.scan,
                helperText: 'Enter product barcode or stock keeping unit',
              ),
            ),
            const SizedBox(width: 8),
            BarcodeScannerButton(
              onScanned: (barcode) {
                setState(() {
                  _barcodeController.text = barcode;
                });
              },
              tooltip: 'Scan Barcode',
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Category Selector - Fixed Material 3 design
        Row(
          children: [
            Icon(
              Icons.category_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Category*',
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
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _selectedCategory.isNotEmpty 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getAvailableCategories().map((category) {
              final isSelected = category == _selectedCategory;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.mkbhdRed.withOpacity(0.1) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppTheme.mkbhdRed : Theme.of(context).colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 16,
                        color: isSelected ? AppTheme.mkbhdRed : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? AppTheme.mkbhdRed : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  // Get categories filtered by selected group
  List<String> _getAvailableCategories() {
    if (_selectedGroup != null && _selectedGroup!.categories.isNotEmpty) {
      return _selectedGroup!.categories;
    }
    return _categories;
  }
  
  // Show create group dialog
  void _showCreateGroupDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: const CreateGroupScreen(),
      ),
    ).then((newGroup) {
      if (newGroup != null && newGroup is ProductGroupModel) {
        setState(() {
          _selectedGroup = newGroup;
        });
      }
    });
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return LucideIcons.smartphone;
      case 'clothing':
        return LucideIcons.shirt;
      case 'food':
        return LucideIcons.utensils;
      case 'beverages':
        return LucideIcons.coffee;
      case 'stationery':
        return LucideIcons.penTool;
      default:
        return LucideIcons.package;
    }
  }
  
  Widget _buildPricingInventoryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selling Price
        CustomTextField(
          controller: _sellingPriceController,
          labelText: 'Selling Price (TSh)*',
          prefixIcon: LucideIcons.tag,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter selling price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value) <= 0) {
              return 'Price must be greater than zero';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Cost Price
        CustomTextField(
          controller: _costPriceController,
          labelText: 'Cost Price (TSh)*',
          prefixIcon: LucideIcons.receipt,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cost price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value) < 0) {
              return 'Price cannot be negative';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Quantity with IMEI tracking button for electronics
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _quantityController,
                labelText: 'Quantity*',
                prefixIcon: LucideIcons.package,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Reset bulk entry if quantity changes
                  if (_isBulkEntry) {
                    setState(() {
                      _isBulkEntry = false;
                      _productUnits.clear();
                      _usedImeis.clear();
                      _currentUnitIndex = 0;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) < 0) {
                    return 'Quantity cannot be negative';
                  }
                  return null;
                },
              ),
            ),
            
            // IMEI tracking button for electronics with quantity > 1
            if (_requiresImeiTracking() && int.tryParse(_quantityController.text) != null && int.parse(_quantityController.text) > 1) ...[
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: _isBulkEntry 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    if (!_isBulkEntry) {
                      _initializeBulkEntry();
                    } else {
                      setState(() {
                        _isBulkEntry = false;
                        _productUnits.clear();
                        _usedImeis.clear();
                        _currentUnitIndex = 0;
                      });
                    }
                  },
                  icon: Icon(
                    _isBulkEntry ? LucideIcons.x : LucideIcons.smartphone,
                    color: _isBulkEntry 
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: _isBulkEntry ? 'Disable IMEI tracking' : 'Track individual IMEI numbers',
                ),
              ),
            ],
          ],
        ),
        
        // IMEI tracking status indicator
        if (_requiresImeiTracking() && int.tryParse(_quantityController.text) != null && int.parse(_quantityController.text) > 1) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isBulkEntry 
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                  : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isBulkEntry 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                    : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isBulkEntry ? LucideIcons.check : LucideIcons.info,
                  size: 16,
                  color: _isBulkEntry 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isBulkEntry 
                        ? 'IMEI tracking enabled for ${_quantityController.text} units'
                        : 'Enable IMEI tracking to manage individual units',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isBulkEntry 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: _isBulkEntry ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Low Stock Threshold
        CustomTextField(
          controller: _lowStockThresholdController,
          labelText: 'Low Stock Threshold*',
          helperText: 'Notify when stock falls below this level',
          prefixIcon: LucideIcons.alertCircle,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter low stock threshold';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (int.parse(value) < 0) {
              return 'Threshold cannot be negative';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildAdditionalDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        const Text(
          'Product Image (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(16), // Increased from 8 to 16
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(16), // Increased from 8 to 16
            ),
            child: _productImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _productImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(LucideIcons.trash2, color: Colors.white),
                            onPressed: _removeImage,
                            tooltip: 'Remove image',
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.image,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add product image',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Supplier Selector
        const Text(
          'Supplier',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(16), // Increased from 8 to 16
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSupplier.isNotEmpty ? _selectedSupplier : null,
              isExpanded: true,
              hint: const Text('Select Supplier'),
              items: _suppliers.map((supplier) {
                return DropdownMenuItem<String>(
                  value: supplier,
                  child: Text(supplier),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSupplier = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildElectronicsForm() {
    // Show bulk IMEI entry form if in bulk mode
    if (_isBulkEntry) {
      return _buildBulkImeiForm();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        CustomTextField(
          controller: _brandController,
          labelText: 'Brand*',
          prefixIcon: LucideIcons.tag,
          validator: (value) {
            if (_isElectronicsCategory() && (value == null || value.isEmpty)) {
              return 'Please enter the brand name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Model
        CustomTextField(
          controller: _modelController,
          labelText: 'Model*',
          prefixIcon: LucideIcons.smartphone,
          validator: (value) {
            if (_isElectronicsCategory() && (value == null || value.isEmpty)) {
              return 'Please enter the model name/number';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Storage - Use the new controller
        CustomTextField(
          controller: _storageController,
          labelText: 'Storage (Optional)',
          helperText: 'e.g., 64GB, 128GB, 256GB',
          prefixIcon: LucideIcons.hardDrive,
        ),
        
        const SizedBox(height: 16),
        
        // Serial Number (for single unit or general electronics)
        if (!_isBulkEntry)
          CustomTextField(
            controller: _serialNumberController,
            labelText: 'Serial Number (Optional)',
            prefixIcon: LucideIcons.scan,
          ),
        
        if (!_isBulkEntry) const SizedBox(height: 16),
        
        // Warranty Period
        CustomTextField(
          controller: _warrantyPeriodController,
          labelText: 'Warranty Period (Optional)',
          helperText: 'e.g., 12 months, 2 years',
          prefixIcon: LucideIcons.calendar,
        ),
        
        const SizedBox(height: 16),
        
        // Technical Specifications
        CustomTextField(
          controller: _technicalSpecsController,
          labelText: 'Technical Specifications',
          prefixIcon: LucideIcons.info,
          maxLines: 3,
        ),
        
        const SizedBox(height: 16),
        
        // Condition Selector
        const Text(
          'Condition',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _conditions.map((condition) => 
            ChoiceChip(
              label: Text(condition),
              selected: _selectedCondition == condition,
              selectedColor: AppTheme.mkbhdRed,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedCondition == condition ? Colors.white : null,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCondition = condition;
                  });
                }
              },
            )
          ).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Product Image
        const Text(
          'Product Image (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _productImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _productImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(LucideIcons.trash2, color: Colors.white),
                            onPressed: _removeImage,
                            tooltip: 'Remove image',
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.image,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add product image',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Supplier Selector
        const Text(
          'Supplier',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSupplier.isNotEmpty ? _selectedSupplier : null,
              isExpanded: true,
              hint: const Text('Select Supplier'),
              items: _suppliers.map((supplier) {
                return DropdownMenuItem<String>(
                  value: supplier,
                  child: Text(supplier),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSupplier = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBulkImeiForm() {
    final progress = _currentUnitIndex / _totalQuantity;
    final isLastUnit = _currentUnitIndex == _totalQuantity - 1;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator without shadow or gradients
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
            // No boxShadow or gradient - completely removed
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unit ${_currentUnitIndex + 1} of $_totalQuantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 6,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // IMEI input with new scanner button
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _imeiController,
                labelText: 'IMEI Number*',
                prefixIcon: LucideIcons.smartphone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IMEI number';
                  }
                  if (_usedImeis.contains(value.trim())) {
                    return 'IMEI already used';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            BarcodeScannerButton(
              onScanned: (imei) {
                // Validate IMEI uniqueness
                if (_usedImeis.contains(imei)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('IMEI already used: $imei'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  return;
                }
                
                setState(() {
                  _imeiController.text = imei;
                });
              },
              tooltip: 'Scan IMEI',
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Optional serial number for current unit
        CustomTextField(
          controller: _unitSerialController,
          labelText: 'Serial Number (Optional)',
          prefixIcon: LucideIcons.hash,
        ),
        
        const SizedBox(height: 24),
        
        // Navigation buttons
        Row(
          children: [
            if (_currentUnitIndex > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _goToPreviousUnit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppTheme.mkbhdRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Previous Unit'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            Expanded(
              child: CustomButton(
                text: isLastUnit ? 'Complete Entry' : 'Next Unit',
                onPressed: isLastUnit ? () {} : _saveCurrentUnit,
                icon: isLastUnit ? LucideIcons.check : LucideIcons.arrowRight,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Units summary without shadows
        if (_productUnits.where((unit) => unit['imei']?.isNotEmpty ?? false).isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
              // No boxShadow - completely removed
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed Units:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...(_productUnits
                    .asMap()
                    .entries
                    .where((entry) => entry.value['imei']?.isNotEmpty ?? false)
                    .take(3)
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Unit ${entry.key + 1}: ${entry.value['imei']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ))),
                if (_productUnits.where((unit) => unit['imei']?.isNotEmpty ?? false).length > 3)
                  Text(
                    '... and ${_productUnits.where((unit) => unit['imei']?.isNotEmpty ?? false).length - 3} more',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
