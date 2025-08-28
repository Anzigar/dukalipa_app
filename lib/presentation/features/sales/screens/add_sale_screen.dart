import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/semantic_tree_protection.dart';
import '../models/sale_model.dart';
import '../../inventory/models/product_model.dart';

class AddSaleScreen extends StatefulWidget {
  final ProductModel? preSelectedProduct;
  final Map<String, dynamic>? extraData;

  const AddSaleScreen({
    Key? key,
    this.preSelectedProduct,
    this.extraData,
  }) : super(key: key);

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Customer Information Controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _deliveryContactController = TextEditingController();
  final _deliveryPhoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _paidAmountController = TextEditingController();
  
  // State Variables
  final List<SaleItemModel> _items = [];
  bool _isSearching = false;
  bool _hasSearched = false; // Track if search has been performed
  bool _isLoading = false;
  List<ProductModel> _searchResults = [];
  int _currentStep = 0;
  
  // 1. Customer Type Management
  String _customerType = 'Walk-in Customer'; // 'Walk-in Customer' or 'Delivery Customer'
  String _salesType = 'Direct Sale'; // 'Direct Sale' or 'Field Sales Agent'
  
  // 2. Product & Pricing
  Map<String, double> _productPriceAdjustments = {}; // Store price adjustments per product
  Map<String, TextEditingController> _priceControllers = {}; // Store controllers for price fields
  
  // 3. VAT Handling
  bool _applyVAT = false;
  double _vatPercentage = 18.0;
  
  // 4. Payment Processing
  double _paidAmount = 0.0;
  String? _selectedPaymentMethod;
  String? _selectedCurrency;
  double _exchangeRate = 1.0;
  
  final List<String> _paymentMethods = [
    'Cash',
    'M-Pesa',
    'Tigo Pesa', 
    'Airtel Money',
    'Halopesa',
    'T-Pesa',
    'NMB Bank',
    'CRDB Bank',
    'NBC Bank',
    'Stanbic Bank',
    'Equity Bank',
    'DTB Bank',
    'Bank Transfer - Other',
    'Lipa Number',
    'Mixed Payment'
  ];
  
  final Map<String, double> _exchangeRates = {
    'TZS': 1.0,
    'USD': 2300.0,
    'EUR': 2500.0,
    'GBP': 2800.0,
    'KES': 17.0,
  };
  
  // 5. Offers and Delivery
  bool _hasFreeAccessory = false;
  String _selectedAccessory = 'None';
  double _customAccessoryPrice = 0.0;
  bool _hasFreeDelivery = false;
  String _selectedRegion = 'Near Shop';
  double _deliveryCharge = 0.0;
  
  final List<String> _availableAccessories = [
    'None', 'Phone Case', 'Screen Protector', 'Earphones',
    'Phone Charger', 'Memory Card', 'Power Bank', 'Custom'
  ];
  
  final Map<String, double> _regionalDeliveryCharges = {
    'Near Shop': 0.0,      // Free delivery
    'City Area': 3000.0,   // TZS 3,000
    'Outskirts': 5000.0,   // TZS 5,000
    'Outside City': 8000.0, // TZS 8,000
  };
  
  // 6. Field Sales Integration - for future implementation
  
  @override
  void initState() {
    super.initState();
    
    // Initialize dropdown values
    _selectedPaymentMethod = _paymentMethods.first;
    _selectedCurrency = _exchangeRates.keys.first;
    _exchangeRate = _exchangeRates[_selectedCurrency] ?? 1.0;
    
    // Add pre-selected product if provided
    if (widget.preSelectedProduct != null) {
      _addProductToCart(widget.preSelectedProduct!, 1);
    }
  }
  
  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _deliveryAddressController.dispose();
    _deliveryContactController.dispose();
    _deliveryPhoneController.dispose();
    _noteController.dispose();
    _paidAmountController.dispose();
    _pageController.dispose();
    
    // Dispose all price controllers
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    _priceControllers.clear();
    
    super.dispose();
  }
  
  // Currency symbol helper
  String get _currencySymbol {
    switch (_selectedCurrency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'KES': return 'KSh';
      default: return 'TZS';
    }
  }
  
  // Calculation methods
  double get _subtotal {
    double total = 0.0;
    for (var item in _items) {
      final adjustedPrice = _productPriceAdjustments[item.productId] ?? item.price;
      total += adjustedPrice * item.quantity;
    }
    return total;
  }
  
  double get _vatAmount => _applyVAT ? (_subtotal * _vatPercentage / 100) : 0.0;
  
  double get _accessoryPrice {
    if (!_hasFreeAccessory && _selectedAccessory != 'None') {
      if (_selectedAccessory == 'Custom') {
        return _customAccessoryPrice;
      }
      
      final prices = {
        'Phone Case': 15000.0,
        'Screen Protector': 8000.0,
        'Earphones': 25000.0,
        'Phone Charger': 20000.0,
        'Memory Card': 35000.0,
        'Power Bank': 45000.0,
      };
      return prices[_selectedAccessory] ?? 0.0;
    }
    return 0.0;
  }
  
  double get _actualDeliveryCharge {
    if (_customerType == 'Delivery Customer' && !_hasFreeDelivery) {
      return _regionalDeliveryCharges[_selectedRegion] ?? 0.0;
    }
    return 0.0;
  }
  
  double get _totalInTZS => _subtotal + _vatAmount + _accessoryPrice + _actualDeliveryCharge;
  
  double get _totalInSelectedCurrency => _totalInTZS / _exchangeRate;
  
  double get _changeAmount => _paidAmount - _totalInSelectedCurrency;
  
  bool get _isPaymentComplete => _paidAmount >= _totalInSelectedCurrency;
  
  // Product search
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false; // Reset when search is cleared
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _hasSearched = true; // Mark that search has been performed
    });
    
    try {
      // Mock search - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockProducts = [
        ProductModel(
          id: '1',
          name: 'Samsung Galaxy S24',
          description: 'Latest smartphone with AI features',
          barcode: '1234567890',
          sellingPrice: 1200000,
          costPrice: 1000000,
          quantity: 10,
          lowStockThreshold: 2,
          category: 'Electronics',
          supplier: 'Samsung',
          imageUrl: null,
          metadata: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ProductModel(
          id: '2',
          name: 'iPhone 15 Pro',
          description: 'Apple flagship smartphone',
          barcode: '0987654321',
          sellingPrice: 2500000,
          costPrice: 2200000,
          quantity: 5,
          lowStockThreshold: 1,
          category: 'Electronics',
          supplier: 'Apple',
          imageUrl: null,
          metadata: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ProductModel(
          id: '3',
          name: 'Wireless Earbuds Pro',
          description: 'Premium wireless earbuds',
          barcode: '1122334455',
          sellingPrice: 150000,
          costPrice: 120000,
          quantity: 20,
          lowStockThreshold: 5,
          category: 'Electronics',
          supplier: 'Audio Tech',
          imageUrl: null,
          metadata: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      if (mounted) {
        setState(() {
          _searchResults = mockProducts.where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase())
          ).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        
        _showErrorSnackBar('Error searching products: ${e.toString()}');
      }
    }
  }
  
  // Product management
  void _addProductToCart(ProductModel product, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    setState(() {
      if (existingIndex != -1) {
        final existingItem = _items[existingIndex];
        _items[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
          total: (existingItem.quantity + quantity) * existingItem.price,
        );
      } else {
        _items.add(SaleItemModel(
          productId: product.id,
          productName: product.name,
          price: product.sellingPrice,
          quantity: quantity,
          total: product.sellingPrice * quantity,
        ));
        
        // Create price controller for new item
        _priceControllers[product.id] = TextEditingController(
          text: product.sellingPrice.toStringAsFixed(0)
        );
      }
      _searchResults.clear();
    });
  }
  
  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
      return;
    }
    
    setState(() {
      final item = _items[index];
      final adjustedPrice = _productPriceAdjustments[item.productId] ?? item.price;
      _items[index] = item.copyWith(
        quantity: newQuantity,
        total: adjustedPrice * newQuantity,
      );
    });
  }
  
  void _removeItem(int index) {
    setState(() {
      final item = _items[index];
      _productPriceAdjustments.remove(item.productId);
      
      // Dispose of the price controller
      _priceControllers[item.productId]?.dispose();
      _priceControllers.remove(item.productId);
      
      _items.removeAt(index);
    });
  }
  
  void _adjustProductPrice(String productId, double newPrice, double basePrice) {
    if (newPrice >= basePrice) {
      setState(() {
        _productPriceAdjustments[productId] = newPrice;
        // Update the total for this item with quantity consideration
        final itemIndex = _items.indexWhere((item) => item.productId == productId);
        if (itemIndex != -1) {
          final item = _items[itemIndex];
          final adjustedTotal = newPrice * item.quantity;
          _items[itemIndex] = item.copyWith(
            total: adjustedTotal,  // Update total with quantity multiplier
          );
          
          // Update the controller text to reflect the new price
          _priceControllers[productId]?.text = newPrice.toStringAsFixed(0);
        }
      });
      _showSuccessSnackBar('Price updated: TZS ${newPrice.toStringAsFixed(0)} per unit');
    } else {
      _showErrorSnackBar('Price cannot be below base selling price: TZS ${basePrice.toStringAsFixed(0)}');
    }
  }
  
  // Navigation helpers with enhanced safety
  void _nextStep() {
    // Validate current step before proceeding
    if (_currentStep == 0) {
      // Step 1: Customer validation
      if (_customerType == 'Delivery Customer') {
        if (_deliveryAddressController.text.trim().isEmpty) {
          _showErrorSnackBar('Please enter delivery address');
          return;
        }
        if (_deliveryContactController.text.trim().isEmpty) {
          _showErrorSnackBar('Please enter delivery contact person');
          return;
        }
      }
    } else if (_currentStep == 1) {
      // Step 2: Products validation
      if (_items.isEmpty) {
        _showErrorSnackBar('Please add at least one product to the sale');
        return;
      }
    }
    
    if (_currentStep < 2) {
      // Use a more robust navigation approach
      _navigateToStep(_currentStep + 1);
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      _navigateToStep(_currentStep - 1);
    }
  }
  
  /// Safe navigation method that prevents semantic tree conflicts
  void _navigateToStep(int targetStep) {
    if (!mounted || targetStep == _currentStep) return;
    
    try {
      // First update the internal state
      _currentStep = targetStep;
      
      // Then schedule the page transition with multiple safety layers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        try {
          // Force a rebuild to sync the UI with the new step
          setState(() {
            // State is already updated, this just triggers rebuild
          });
          
          // Schedule the page animation for the next frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_pageController.hasClients) return;
            
            try {
              _pageController.animateToPage(
                targetStep,
                duration: const Duration(milliseconds: 250), // Shorter duration
                curve: Curves.easeOut, // Simpler curve
              ).catchError((error) {
                debugPrint('PageView animation error: $error');
                // If animation fails, try direct jump
                if (mounted && _pageController.hasClients) {
                  _pageController.jumpToPage(targetStep);
                }
              });
            } catch (e) {
              debugPrint('PageView navigation error: $e');
              // Fallback to direct page jump
              if (mounted && _pageController.hasClients) {
                try {
                  _pageController.jumpToPage(targetStep);
                } catch (e2) {
                  debugPrint('PageView jumpToPage error: $e2');
                }
              }
            }
          });
        } catch (e) {
          debugPrint('Navigation state update error: $e');
        }
      });
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }
  
  // Sale completion
  Future<void> _completeSale() async {
    // Validate the form first
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fix all errors before completing the sale');
      return;
    }

    // Sync payment amount from controller
    _paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;

    // 1. Validate items exist
    if (_items.isEmpty) {
      _showErrorSnackBar('Please add items to the sale');
      return;
    }
    
    // 2. Validate payment method is selected
    if (_selectedPaymentMethod == null || _selectedPaymentMethod!.isEmpty) {
      _showErrorSnackBar('Please select a payment method (Cash, M-Pesa, Bank Transfer, etc.)');
      return;
    }
    
    // 3. Validate currency is selected
    if (_selectedCurrency == null || _selectedCurrency!.isEmpty) {
      _showErrorSnackBar('Please select a currency');
      return;
    }
    
    // 4. Validate payment amount
    if (_paidAmount <= 0) {
      _showErrorSnackBar('Please enter the amount paid by the customer');
      return;
    }
    
    // 5. For direct sales, ensure payment is complete
    if (_salesType == 'Direct Sale' && !_isPaymentComplete) {
      _showErrorSnackBar('Payment is incomplete. Please enter full payment amount or switch to Field Sales Agent');
      return;
    }
    
    // 6. Validate minimum payment amount
    if (_paidAmount < _totalInSelectedCurrency && _salesType == 'Direct Sale') {
      _showErrorSnackBar('Payment amount cannot be less than the total amount (${_currencySymbol} ${_totalInSelectedCurrency.toStringAsFixed(0)})');
      return;
    }
    
    // 7. Show confirmation dialog with VAT and payment method details
    final confirmed = await _showSaleConfirmationDialog();
    if (!confirmed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Determine if sale should be marked as credit
      final isCredit = _salesType == 'Field Sales Agent' && !_isPaymentComplete;
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        String message;
        if (isCredit) {
          message = 'Sale recorded on credit! Payment due by 8:00 PM today. Remaining: ${_currencySymbol} ${(_totalInSelectedCurrency - _paidAmount).toStringAsFixed(0)}';
        } else {
          message = 'Sale completed successfully! Total: ${_currencySymbol} ${_totalInSelectedCurrency.toStringAsFixed(0)}';
        }
        
        _showSuccessSnackBar(message);
        
        // Show print receipt dialog
        _showPrintReceiptDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to complete sale: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Sale confirmation dialog
  Future<bool> _showSaleConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.alertCircle, color: AppTheme.mkbhdRed),
            const SizedBox(width: 8),
            Text('Confirm Sale Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please confirm all sale details:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // Customer Type
              _buildConfirmationRow('Customer Type:', _customerType),
              _buildConfirmationRow('Sales Type:', _salesType),
              
              const Divider(),
              
              // Payment Details
              Text(
                'Payment Information:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.mkbhdRed),
              ),
              const SizedBox(height: 8),
              
              _buildConfirmationRow('Payment Method:', _selectedPaymentMethod ?? 'Not Selected'),
              _buildConfirmationRow('Currency:', _selectedCurrency ?? 'Not Selected'),
              _buildConfirmationRow('Amount Paid:', '${_currencySymbol} ${_paidAmount.toStringAsFixed(0)}'),
              
              if (_isPaymentComplete) ...[
                _buildConfirmationRow('Change:', '${_currencySymbol} ${_changeAmount.toStringAsFixed(0)}', 
                  valueColor: Colors.green),
              ] else ...[
                _buildConfirmationRow('Remaining:', '${_currencySymbol} ${(_totalInSelectedCurrency - _paidAmount).toStringAsFixed(0)}', 
                  valueColor: Colors.orange),
              ],
              
              const Divider(),
              
              // VAT Information
              Text(
                'VAT & Charges:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.mkbhdRed),
              ),
              const SizedBox(height: 8),
              
              _buildConfirmationRow('VAT Applied:', _applyVAT ? 'Yes (${_vatPercentage.toStringAsFixed(0)}%)' : 'No'),
              if (_applyVAT)
                _buildConfirmationRow('VAT Amount:', 'TZS ${_vatAmount.toStringAsFixed(0)}'),
              
              if (_selectedAccessory != 'None')
                _buildConfirmationRow('Accessory:', '$_selectedAccessory (${_hasFreeAccessory ? "FREE" : "TZS ${_accessoryPrice.toStringAsFixed(0)}"})'),
              
              if (_customerType == 'Delivery Customer')
                _buildConfirmationRow('Delivery:', '$_selectedRegion (${_hasFreeDelivery || _deliveryCharge == 0 ? "FREE" : "TZS ${_actualDeliveryCharge.toStringAsFixed(0)}"})'),
              
              const Divider(),
              
              _buildConfirmationRow('Total Amount:', '${_currencySymbol} ${_totalInSelectedCurrency.toStringAsFixed(0)}', 
                isTotal: true),
              
              if (_selectedCurrency != 'TZS')
                _buildConfirmationRow('Total (TZS):', 'TZS ${_totalInTZS.toStringAsFixed(0)}', 
                  isSubtotal: true),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _applyVAT ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _applyVAT ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _applyVAT ? LucideIcons.info : LucideIcons.alertTriangle, 
                      color: _applyVAT ? Colors.blue : Colors.orange, 
                      size: 16
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _applyVAT 
                          ? 'VAT will be included in this sale'
                          : 'No VAT applied to this sale',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _applyVAT ? Colors.blue.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Confirm Sale'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Helper method for confirmation dialog rows
  Widget _buildConfirmationRow(String label, String value, {Color? valueColor, bool isTotal = false, bool isSubtotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isSubtotal ? Colors.grey : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? (isTotal ? AppTheme.mkbhdRed : (isSubtotal ? Colors.grey : null)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // UI helpers
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Print receipt dialog
  void _showPrintReceiptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.printer, color: AppTheme.mkbhdRed),
            const SizedBox(width: 8),
            Text('Print Receipt'),
          ],
        ),
        content: Text('Would you like to print the receipt for this sale?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back after delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  context.pop();
                }
              });
            },
            child: Text('Skip', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _printReceipt();
              // Navigate back after delay
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  context.pop();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Print Receipt'),
          ),
        ],
      ),
    );
  }

  // Receipt printing method
  void _printReceipt() {
    final receiptContent = _generateReceiptContent();
    
    // Copy to clipboard as a basic implementation
    Clipboard.setData(ClipboardData(text: receiptContent)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.copy, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Receipt copied to clipboard! You can now paste it into a printing app or share it.'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Preview',
            textColor: Colors.white,
            onPressed: () {
              _showReceiptPreview(receiptContent);
            },
          ),
        ),
      );
    });
  }

  // Receipt preview dialog
  void _showReceiptPreview(String receiptContent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.receipt, color: AppTheme.mkbhdRed),
            const SizedBox(width: 8),
            Text('Receipt Preview'),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              receiptContent,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Clipboard.setData(ClipboardData(text: receiptContent));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Receipt copied to clipboard again!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Copy Again'),
          ),
        ],
      ),
    );
  }

  String _generateReceiptContent() {
    final now = DateTime.now();
    final dateTime = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    
    String receipt = '''
===========================================
           DUKALIPA ELECTRONICS
===========================================
Date: $dateTime
Receipt #: DUK${now.millisecondsSinceEpoch.toString().substring(8)}

${_customerType == 'Delivery Customer' ? 'DELIVERY SALE' : 'WALK-IN SALE'}
Customer: ${_customerNameController.text.isNotEmpty ? _customerNameController.text : 'Walk-in Customer'}
${_customerPhoneController.text.isNotEmpty ? 'Phone: ${_customerPhoneController.text}' : ''}
${_customerType == 'Delivery Customer' && _deliveryAddressController.text.isNotEmpty ? 'Address: ${_deliveryAddressController.text}' : ''}

-------------------------------------------
ITEMS:
-------------------------------------------''';

    for (var item in _items) {
      final adjustedPrice = _productPriceAdjustments[item.productId] ?? item.price;
      final itemTotal = adjustedPrice * item.quantity;
      receipt += '''
${item.productName}
Qty: ${item.quantity} x TZS ${adjustedPrice.toStringAsFixed(0)} = TZS ${itemTotal.toStringAsFixed(0)}''';
    }

    receipt += '''

-------------------------------------------
SUMMARY:
-------------------------------------------
Subtotal: TZS ${_subtotal.toStringAsFixed(0)}''';

    if (_applyVAT) {
      receipt += '''
VAT (18%): TZS ${_vatAmount.toStringAsFixed(0)}''';
    }

    if (_hasFreeAccessory && _selectedAccessory != 'None') {
      receipt += '''
Free Accessory: $_selectedAccessory''';
    } else if (!_hasFreeAccessory && _selectedAccessory != 'None') {
      receipt += '''
Accessory: $_selectedAccessory - TZS ${_accessoryPrice.toStringAsFixed(0)}''';
    }

    if (_customerType == 'Delivery Customer') {
      if (_hasFreeDelivery) {
        receipt += '''
Delivery: FREE ($_selectedRegion)''';
      } else if (_actualDeliveryCharge > 0) {
        receipt += '''
Delivery: TZS ${_actualDeliveryCharge.toStringAsFixed(0)} ($_selectedRegion)''';
      }
    }

    receipt += '''

TOTAL: TZS ${_totalInTZS.toStringAsFixed(0)}''';

    if (_selectedCurrency != 'TZS') {
      receipt += '''
Currency: $_selectedCurrency
Amount: $_currencySymbol${_totalInSelectedCurrency.toStringAsFixed(0)}
Exchange Rate: 1 $_selectedCurrency = ${_exchangeRate.toStringAsFixed(0)} TZS''';
    }

    receipt += '''
Payment Method: ${_selectedPaymentMethod ?? 'Cash'}''';

    if (_paidAmount > 0) {
      receipt += '''
Amount Paid: $_currencySymbol${_paidAmount.toStringAsFixed(0)}''';
      
      if (_changeAmount > 0) {
        receipt += '''
Change: $_currencySymbol${_changeAmount.toStringAsFixed(0)}''';
      } else if (_changeAmount < 0) {
        receipt += '''
Balance Due: $_currencySymbol${(-_changeAmount).toStringAsFixed(0)}''';
      }
    }

    receipt += '''
Sales Type: $_salesType''';

    if (_salesType == 'Field Sales Agent' && !_isPaymentComplete) {
      receipt += '''
*** CREDIT SALE ***
Payment Due: 8:00 PM Today
Remaining: $_currencySymbol${(_totalInSelectedCurrency - _paidAmount).toStringAsFixed(0)}''';
    }

    receipt += '''

${_noteController.text.isNotEmpty ? 'Note: ${_noteController.text}' : ''}

===========================================
        Thank you for your business!
         Visit us again at Dukalipa
===========================================
    ''';

    return receipt;
  }
  
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Customer Details';
      case 1:
        return 'Select Products';
      case 2:
        return 'Payment & Checkout';
      default:
        return 'New Sale';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.mkbhdRed),
              const SizedBox(height: 24),
              Text(
                'Processing Sale...',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _salesType == 'Field Sales Agent' && !_isPaymentComplete
                    ? 'Adding to Madeni tracking'
                    : 'Finalizing transaction details',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SemanticTreeProtection.buildSafely(
      builder: () => Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Modern Header with contextual information
              _buildModernHeader(context, colorScheme),
              
              // Main content with safe PageView
              Expanded(
                child: Form(
                  key: _formKey,
                  child: _buildSafePageView(),
                ),
              ),
              
              // Bottom navigation with modern design
              _buildBottomNavigation(context, colorScheme),
            ],
          ),
        ),
      ),
      fallback: () => Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading sale screen. Please try again.'),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a safer PageView that prevents semantic tree conflicts
  Widget _buildSafePageView() {
    return RepaintBoundary(
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable manual scrolling to prevent conflicts
        onPageChanged: null, // Remove onPageChanged to prevent cascading updates
        children: [
          RepaintBoundary(key: const ValueKey('customer_step'), child: _buildCustomerStep()),
          RepaintBoundary(key: const ValueKey('products_step'), child: _buildProductsStep()),
          RepaintBoundary(key: const ValueKey('payment_step'), child: _buildPaymentStep()),
        ],
      ),
    );
  }
  
  Widget _buildModernHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row with back button and progress
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getStepTitle(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStepDescription(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.mkbhdRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentStep + 1} of 3',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mkbhdRed,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Modern progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: _currentStep + 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.mkbhdRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3 - (_currentStep + 1),
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Set up customer details and delivery preferences';
      case 1:
        return 'Choose products and adjust quantities';
      case 2:
        return 'Complete payment and finalize sale';
      default:
        return 'Complete your sale transaction';
    }
  }
  
  Widget _buildBottomNavigation(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            
            // Next/Complete button
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: FilledButton(
                onPressed: _currentStep == 2 ? _completeSale : _nextStep,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == 2 ? 'Complete Sale' : 'Continue',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentStep == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Step 1: Customer Management - Google Material Design 3
  Widget _buildCustomerStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Type Selection with modern cards
          _buildSectionHeader('Order Type', 'Choose how the customer will receive their order'),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildModernSelectionCard(
                  title: 'Walk-in',
                  subtitle: 'In-store pickup',
                  icon: Icons.store_rounded,
                  isSelected: _customerType == 'Walk-in Customer',
                  onTap: () => setState(() => _customerType = 'Walk-in Customer'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernSelectionCard(
                  title: 'Delivery',
                  subtitle: 'Door-to-door',
                  icon: Icons.local_shipping_rounded,
                  isSelected: _customerType == 'Delivery Customer',
                  onTap: () => setState(() => _customerType = 'Delivery Customer'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Sales & Payment Type Combined Selection
          _buildSectionHeader('Sales & Payment Method', 'Choose both payment timing and method'),
          const SizedBox(height: 20),
          
          // Direct Sale Payment Options
          _buildPaymentMethodSection(
            title: 'Direct Sale - Pay Now',
            subtitle: 'Customer pays immediately',
            isSelected: _salesType == 'Direct Sale',
            paymentMethods: ['Cash', 'M-Pesa', 'Tigo Pesa', 'Airtel Money', 'Bank Transfer', 'Card Payment'],
          ),
          
          const SizedBox(height: 20),
          
          // Field Sales Agent Payment Options  
          _buildPaymentMethodSection(
            title: 'Field Sales Agent - Pay Later',
            subtitle: 'Customer pays by 8 PM today',
            isSelected: _salesType == 'Field Sales Agent',
            paymentMethods: ['Cash (Later)', 'Mobile Money (Later)', 'Bank Transfer (Later)', 'Customer Credit'],
          ),
          
          // Field Sale Warning with modern styling
          if (_salesType == 'Field Sales Agent') ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16), // Reduced from 20 to 16
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.1), // Using app theme color
                borderRadius: BorderRadius.circular(16), // Reduced from 20 to 16
                border: Border.all(color: AppTheme.mkbhdRed.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6), // Reduced from 8 to 6
                    decoration: BoxDecoration(
                      color: AppTheme.mkbhdRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.schedule_rounded, color: AppTheme.mkbhdRed, size: 18), // Reduced size
                  ),
                  const SizedBox(width: 12), // Reduced from 16 to 12
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Reminder',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13, // Reduced from 14 to 13
                            color: AppTheme.mkbhdRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Field sales must be paid by 8:00 PM today. Unpaid sales will be tracked in Madeni.',
                          style: GoogleFonts.poppins(
                            fontSize: 12, // Reduced from 13 to 12
                            color: AppTheme.mkbhdRed.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Customer Information Section
          _buildSectionHeader('Customer Information', 'Enter customer details for the transaction'),
          const SizedBox(height: 20),
          
          // Modern input fields
          _buildModernTextField(
            controller: _customerNameController,
            label: 'Customer Name',
            hint: 'Enter full name',
            icon: Icons.person_rounded,
          ),
          
          const SizedBox(height: 16),
          
          _buildModernTextField(
            controller: _customerPhoneController,
            label: 'Phone Number',
            hint: '+255 XXX XXX XXX',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          
          // Delivery specific fields with modern design
          if (_customerType == 'Delivery Customer') ...[
            const SizedBox(height: 32),
            _buildSectionHeader('Delivery Information', 'Specify delivery address and contact details'),
            const SizedBox(height: 20),
            
            _buildModernTextField(
              controller: _deliveryAddressController,
              label: 'Delivery Address',
              hint: 'Street, District, City',
              icon: Icons.location_on_rounded,
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            _buildModernTextField(
              controller: _deliveryContactController,
              label: 'Contact Person',
              hint: 'Person receiving the order',
              icon: Icons.contact_phone_rounded,
            ),
            
            const SizedBox(height: 16),
            
            _buildModernTextField(
              controller: _deliveryPhoneController,
              label: 'Contact Phone',
              hint: '+255 XXX XXX XXX',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 32),
            
            // Delivery Region Selection with modern chips
            _buildSectionHeader('Delivery Region', 'Select delivery area - costs vary by distance and transport method'),
            const SizedBox(height: 20),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _regionalDeliveryCharges.keys.map((region) {
                final isSelected = _selectedRegion == region;
                final charge = _regionalDeliveryCharges[region]!;
                
                return _buildRegionChip(region, charge, isSelected);
              }).toList(),
            ),
            
            if (_selectedRegion != 'Near Shop') ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16), // Reduced from 20 to 16
                decoration: BoxDecoration(
                  color: AppTheme.mkbhdRed.withOpacity(0.1), // Using app theme color
                  borderRadius: BorderRadius.circular(12), // Reduced from 16 to 12
                  border: Border.all(color: AppTheme.mkbhdRed.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6), // Reduced from 8 to 6
                      decoration: BoxDecoration(
                        color: AppTheme.mkbhdRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6), // Reduced from 8 to 6
                      ),
                      child: Icon(Icons.local_shipping_rounded, color: AppTheme.mkbhdRed, size: 16), // Reduced size
                    ),
                    const SizedBox(width: 12), // Reduced from 16 to 12
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Information',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13, // Reduced from 14 to 13
                              color: AppTheme.mkbhdRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Delivery cost for $_selectedRegion varies based on distance, transport method, and product quantity.',
                            style: GoogleFonts.poppins(
                              fontSize: 11, // Reduced from 13 to 11
                              color: AppTheme.mkbhdRed.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
  
  Widget _buildModernSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16), // Reduced from 20 to 16
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.mkbhdRed : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.mkbhdRed : colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          // Removed shadow completely
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12), // Reduced from 14 to 12
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : AppTheme.mkbhdRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.mkbhdRed,
                size: 24, // Reduced from 28 to 24
              ),
            ),
            const SizedBox(height: 10), // Reduced from 12 to 10
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15, // Reduced from 16 to 15
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? Colors.white.withOpacity(0.8) : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.mkbhdRed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Increased from 12 to 16
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Increased from 12 to 16
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Increased from 12 to 16
          borderSide: BorderSide(color: AppTheme.mkbhdRed, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        labelStyle: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant),
        hintStyle: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
      ),
    );
  }
  
  Widget _buildRegionChip(String region, double charge, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        // Debounce rapid taps to prevent semantic tree conflicts
        if (_selectedRegion != region) {
          setState(() => _selectedRegion = region);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Reduced padding
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.mkbhdRed : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.mkbhdRed : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          // Removed shadow completely
        ),
        child: Column(
          children: [
            Text(
              region,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13, // Reduced from 14 to 13
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              charge == 0 ? 'FREE' : 'Varies',
              style: GoogleFonts.poppins(
                fontSize: 11, // Reduced from 12 to 11
                color: isSelected ? Colors.white.withOpacity(0.8) : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodSection({
    required String title,
    required String subtitle,
    required bool isSelected,
    required List<String> paymentMethods,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.mkbhdRed.withOpacity(0.05) : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.mkbhdRed : colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header section
          GestureDetector(
            onTap: () {
              setState(() {
                if (title.contains('Direct Sale')) {
                  _salesType = 'Direct Sale';
                } else {
                  _salesType = 'Field Sales Agent';
                }
                // Reset payment method when switching sales type
                _selectedPaymentMethod = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.mkbhdRed.withOpacity(0.1) : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.mkbhdRed : AppTheme.mkbhdRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      title.contains('Direct Sale') ? Icons.payment_rounded : Icons.schedule_rounded,
                      color: isSelected ? Colors.white : AppTheme.mkbhdRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.mkbhdRed : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isSelected ? AppTheme.mkbhdRed.withOpacity(0.8) : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppTheme.mkbhdRed : colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
          
          // Payment methods section (only shown when selected)
          if (isSelected) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Select Payment Method:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: paymentMethods.map((method) {
                      final isMethodSelected = _selectedPaymentMethod == method;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPaymentMethod = method),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMethodSelected ? AppTheme.mkbhdRed : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMethodSelected ? AppTheme.mkbhdRed : colorScheme.outline.withOpacity(0.3),
                              width: isMethodSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            method,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isMethodSelected ? Colors.white : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  
  // Step 2: Products Management - Google Material Design 3
  Widget _buildProductsStep() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // Modern Product Search Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Search',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search and add products to your cart',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: GoogleFonts.poppins(
                  fontSize: 15.sp, 
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Type product name to search...',
                  hintStyle: GoogleFonts.poppins(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search, 
                    color: colorScheme.onSurfaceVariant,
                    size: 18.r,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                onChanged: _searchProducts,
              ),
            ],
          ),
        ),
        
        // Search Results with Modern Design
        if (_isSearching)
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.mkbhdRed,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Searching products...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        
        if (_searchResults.isNotEmpty) ...[
          Container(
            height: 220,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                return _buildModernProductCard(product);
              },
            ),
          ),
          // Divider between search results and cart
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ],
        
        // Empty search state
        if (_hasSearched && _searchResults.isEmpty && !_isSearching) ...[
          Container(
            height: 220,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/Empty_box.json',
                    width: 120.w,
                    height: 120.h,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No products found',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Try searching with different keywords',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider between empty state and cart
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ],
        
        // Modern Shopping Cart
        Expanded(
          child: _items.isEmpty
              ? _buildEmptyCartState(colorScheme)
              : Column(
                  children: [
                    // Cart Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.shoppingCart,
                            color: AppTheme.mkbhdRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Shopping Cart',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.mkbhdRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_items.length} items',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.mkbhdRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Cart Items List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final adjustedPrice = _productPriceAdjustments[item.productId] ?? item.price;
                          
                          return _buildModernCartItem(item, adjustedPrice, index);
                        },
                      ),
                    ),
                  ],
                ),
        ),
        
        // Modern Cart Summary
        if (_items.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.05),
              border: Border(
                top: BorderSide(
                  color: AppTheme.mkbhdRed.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.receipt,
                  color: AppTheme.mkbhdRed,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subtotal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${_items.length} ${_items.length == 1 ? 'item' : 'items'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'TZS ${_subtotal.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mkbhdRed,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildModernProductCard(dynamic product) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _addProductToCart(product, 1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.mkbhdRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    LucideIcons.package,
                    color: AppTheme.mkbhdRed,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TZS ${product.sellingPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Add Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.mkbhdRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _addProductToCart(product, 1),
                      child: Icon(
                        LucideIcons.plus,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyCartState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Empty_box.json',
              width: 180.w,
              height: 180.h,
              fit: BoxFit.contain,
              repeat: true,
            ),
            SizedBox(height: 24.h),
            Text(
              'Your cart is empty',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Search for products above to add them to your cart',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernCartItem(dynamic item, double adjustedPrice, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header
            Row(
              children: [
                // Product Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.mkbhdRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.package,
                    color: AppTheme.mkbhdRed,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Base: TZS ${item.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Delete Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _removeItem(index),
                      child: Icon(
                        LucideIcons.trash2,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Price Adjustment Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selling Price',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: ValueKey('price_${item.productId}'),
                    controller: _priceControllers[item.productId],
                    decoration: InputDecoration(
                      prefixText: 'TZS ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.mkbhdRed, width: 2),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    onChanged: (value) {
                      final newPrice = double.tryParse(value);
                      if (newPrice != null && newPrice >= item.price) {
                        _adjustProductPrice(item.productId, newPrice, item.price);
                      }
                    },
                    onFieldSubmitted: (value) {
                      final newPrice = double.tryParse(value) ?? adjustedPrice;
                      _adjustProductPrice(item.productId, newPrice, item.price);
                    },
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price < item.price) {
                        return 'Min: TZS ${item.price.toStringAsFixed(0)}';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quantity and Total Section
            Row(
              children: [
                // Quantity Controls
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                onTap: () => _updateItemQuantity(index, item.quantity - 1),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    LucideIcons.minus,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withOpacity(0.3),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.quantity}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                onTap: () => _updateItemQuantity(index, item.quantity + 1),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    LucideIcons.plus,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Item Total
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Item Total',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.mkbhdRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.mkbhdRed.withOpacity(0.2)),
                        ),
                        child: Text(
                          'TZS ${(adjustedPrice * item.quantity).toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.mkbhdRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Step 3: Payment & Offers
  Widget _buildPaymentStep() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VAT Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.percent, color: AppTheme.mkbhdRed),
                      const SizedBox(width: 8),
                      Text(
                        'VAT (Optional)',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VAT is optional and at seller discretion. Please confirm whether to apply VAT to this sale.',
                    style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_applyVAT ? Colors.blue : Colors.orange).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: (_applyVAT ? Colors.blue : Colors.orange).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _applyVAT ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
                          color: _applyVAT ? Colors.blue : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _applyVAT 
                              ? 'VAT (${_vatPercentage.toStringAsFixed(0)}%) will be applied to this sale'
                              : 'No VAT will be applied to this sale',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: (_applyVAT ? Colors.blue : Colors.orange).shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _applyVAT,
                        onChanged: (value) {
                          setState(() {
                            _applyVAT = value ?? false;
                          });
                        },
                      ),
                      Text('Apply VAT (${_vatPercentage.toStringAsFixed(0)}%)'),
                      const Spacer(),
                      if (_applyVAT)
                        Text(
                          'TZS ${_vatAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.mkbhdRed),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Offers Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.gift, color: AppTheme.mkbhdRed),
                      const SizedBox(width: 8),
                      Text(
                        'Special Offers',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Free Accessory
                  Row(
                    children: [
                      Checkbox(
                        value: _hasFreeAccessory,
                        onChanged: (value) {
                          setState(() {
                            _hasFreeAccessory = value ?? false;
                            if (!_hasFreeAccessory) {
                              _selectedAccessory = 'None';
                            }
                          });
                        },
                      ),
                      Text('Free Accessory'),
                    ],
                  ),
                  
                  if (_hasFreeAccessory) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedAccessory,
                      decoration: InputDecoration(
                        labelText: 'Select Accessory',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _availableAccessories.where((acc) => acc != 'None').map((accessory) {
                        return DropdownMenuItem(
                          value: accessory,
                          child: Text(accessory),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccessory = value ?? 'None';
                        });
                      },
                    ),
                  ],
                  
                  // Paid Accessory (not free)
                  if (!_hasFreeAccessory) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _selectedAccessory != 'None',
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedAccessory = 'Phone Case';
                              } else {
                                _selectedAccessory = 'None';
                                _customAccessoryPrice = 0.0;
                              }
                            });
                          },
                        ),
                        Text('Add Accessory (Paid)'),
                      ],
                    ),
                    
                    if (_selectedAccessory != 'None') ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedAccessory,
                        decoration: InputDecoration(
                          labelText: 'Select Accessory',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: _availableAccessories.where((acc) => acc != 'None').map((accessory) {
                          return DropdownMenuItem(
                            value: accessory,
                            child: Text(accessory),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccessory = value ?? 'None';
                            if (_selectedAccessory != 'Custom') {
                              _customAccessoryPrice = 0.0;
                            }
                          });
                        },
                      ),
                      
                      // Custom price input for custom accessory
                      if (_selectedAccessory == 'Custom') ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Custom Accessory Price (TZS)',
                            prefixIcon: Icon(LucideIcons.dollarSign),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _customAccessoryPrice = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ],
                      
                      // Show accessory price
                      if (_selectedAccessory != 'None') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.info, color: Colors.blue, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Accessory: $_selectedAccessory - TZS ${_accessoryPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                  
                  // Free Delivery (for delivery customers)
                  if (_customerType == 'Delivery Customer' && _deliveryCharge > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _hasFreeDelivery,
                          onChanged: (value) {
                            setState(() {
                              _hasFreeDelivery = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Free Delivery'),
                              Text(
                                'Waive TZS ${_deliveryCharge.toStringAsFixed(0)} delivery charge',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment Method
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.creditCard, color: AppTheme.mkbhdRed),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Details',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Show selected payment method from step 1
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.mkbhdRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.mkbhdRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.checkCircle, color: AppTheme.mkbhdRed, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Payment Method:',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.mkbhdRed.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                '${_selectedPaymentMethod ?? "None"} (${_salesType})',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.mkbhdRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Currency Selection
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _exchangeRates.keys.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currency),
                            if (currency != 'TZS') ...[
                              const SizedBox(width: 8),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  '1 $currency = ${_exchangeRates[currency]!.toStringAsFixed(0)} TZS',
                                  style: GoogleFonts.poppins(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value;
                        _exchangeRate = _exchangeRates[_selectedCurrency] ?? 1.0;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Amount Paid
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _paidAmountController,
                          decoration: InputDecoration(
                            labelText: 'Amount Paid (${_currencySymbol})',
                            prefixIcon: Icon(LucideIcons.dollarSign),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            helperText: 'Minimum: ${_currencySymbol} ${_totalInSelectedCurrency.toStringAsFixed(0)}',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final amount = double.tryParse(value) ?? 0.0;
                            if (_paidAmount != amount) {
                              setState(() {
                                _paidAmount = amount;
                              });
                            }
                          },
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            if (_salesType == 'Direct Sale' && amount < _totalInSelectedCurrency) {
                              return 'Payment must be at least ${_currencySymbol} ${_totalInSelectedCurrency.toStringAsFixed(0)}';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _paidAmount = _totalInSelectedCurrency;
                            _paidAmountController.text = _totalInSelectedCurrency.toStringAsFixed(0);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: Text('Exact', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  
                  // Change/Remaining amount
                  if (_paidAmount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isPaymentComplete ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isPaymentComplete ? LucideIcons.checkCircle : LucideIcons.clock,
                                color: _isPaymentComplete ? Colors.green : Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPaymentComplete ? 'Payment Complete' : 'Payment Incomplete',
                                style: GoogleFonts.poppins(
                                  color: _isPaymentComplete ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Due: ${_currencySymbol} ${_totalInSelectedCurrency.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            'Amount Paid: ${_currencySymbol} ${_paidAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (_isPaymentComplete) ...[
                            Text(
                              'Change: ${_currencySymbol} ${_changeAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Remaining: ${_currencySymbol} ${(_totalInSelectedCurrency - _paidAmount).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes (Optional)',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Add any notes about this sale...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Required Fields Warning
          Card(
            color: Colors.red.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.alertTriangle, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Required Before Completing Sale',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(
                        LucideIcons.checkCircle,
                        color: _applyVAT ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VAT Decision: ${_applyVAT ? "Apply VAT" : "No VAT"}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _applyVAT ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        _selectedPaymentMethod != null ? LucideIcons.checkCircle : LucideIcons.circle,
                        color: _selectedPaymentMethod != null ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Method: ${_selectedPaymentMethod ?? "Not Selected"}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _selectedPaymentMethod != null ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        _paidAmount > 0 ? LucideIcons.checkCircle : LucideIcons.circle,
                        color: _paidAmount > 0 ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Amount Paid: ${_paidAmount > 0 ? "${_currencySymbol} ${_paidAmount.toStringAsFixed(0)}" : "Not Entered"}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _paidAmount > 0 ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  if (_salesType == 'Direct Sale' && !_isPaymentComplete && _paidAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Payment incomplete. Remaining: ${_currencySymbol} ${(_totalInSelectedCurrency - _paidAmount).toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Final Summary
          Card(
            color: AppTheme.mkbhdRed.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sale Summary',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  
                  _buildSummaryRow('Subtotal:', 'TZS ${_subtotal.toStringAsFixed(0)}'),
                  
                  if (_applyVAT)
                    _buildSummaryRow('VAT (${_vatPercentage.toStringAsFixed(0)}%):', 'TZS ${_vatAmount.toStringAsFixed(0)}'),
                  
                  if (_customerType == 'Delivery Customer' && _actualDeliveryCharge > 0)
                    _buildSummaryRow('Delivery ($_selectedRegion):', 'TZS ${_actualDeliveryCharge.toStringAsFixed(0)}'),
                  
                  if (_customerType == 'Delivery Customer' && _hasFreeDelivery && _deliveryCharge > 0)
                    _buildSummaryRow('Delivery (FREE):', 'TZS 0', originalPrice: 'TZS ${_deliveryCharge.toStringAsFixed(0)}'),
                  
                  if (_selectedAccessory != 'None' && !_hasFreeAccessory)
                    _buildSummaryRow('$_selectedAccessory:', 'TZS ${_accessoryPrice.toStringAsFixed(0)}'),
                  
                  if (_selectedAccessory != 'None' && _hasFreeAccessory)
                    _buildSummaryRow('$_selectedAccessory (FREE):', 'TZS 0', originalPrice: 'TZS ${_accessoryPrice.toStringAsFixed(0)}'),
                  
                  const Divider(),
                  
                  _buildSummaryRow(
                    'Total (${_selectedCurrency}):',
                    '${_currencySymbol} ${_totalInSelectedCurrency.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                  
                  if (_selectedCurrency != 'TZS')
                    _buildSummaryRow('Total (TZS):', 'TZS ${_totalInTZS.toStringAsFixed(0)}', isSubtext: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {String? originalPrice, bool isTotal = false, bool isSubtext = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isSubtext ? Colors.grey : null,
            ),
          ),
          Row(
            children: [
              if (originalPrice != null) ...[
                Text(
                  originalPrice,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: isTotal ? AppTheme.mkbhdRed : (isSubtext ? Colors.grey : null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
