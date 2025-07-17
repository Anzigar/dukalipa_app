import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
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
  bool _isLoading = false;
  List<ProductModel> _searchResults = [];
  int _currentStep = 0;
  
  // 1. Customer Type Management
  String _customerType = 'Walk-in Customer'; // 'Walk-in Customer' or 'Delivery Customer'
  String _salesType = 'Direct Sale'; // 'Direct Sale' or 'Field Sales Agent'
  
  // 2. Product & Pricing
  Map<String, double> _productPriceAdjustments = {}; // Store price adjustments per product
  
  // 3. VAT Handling
  bool _applyVAT = false;
  double _vatPercentage = 18.0;
  
  // 4. Payment Processing
  double _paidAmount = 0.0;
  String? _selectedPaymentMethod;
  String? _selectedCurrency;
  double _exchangeRate = 1.0;
  
  final List<String> _paymentMethods = [
    'Cash', 'M-Pesa', 'Tigo Pesa', 'Airtel Money', 'Selcom',
    'NMB Bank', 'CRDB Bank', 'NBC Bank', 'Other Bank'
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
  bool _hasFreeDelivery = false;
  String _selectedRegion = 'Near Shop';
  double _deliveryCharge = 0.0;
  
  final List<String> _availableAccessories = [
    'None', 'Phone Case', 'Screen Protector', 'Earphones',
    'Phone Charger', 'Memory Card', 'Power Bank'
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
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
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
      _items.removeAt(index);
    });
  }
  
  void _adjustProductPrice(String productId, double newPrice, double basePrice) {
    if (newPrice >= basePrice) {
      setState(() {
        _productPriceAdjustments[productId] = newPrice;
        // Update the total for this item
        final itemIndex = _items.indexWhere((item) => item.productId == productId);
        if (itemIndex != -1) {
          final item = _items[itemIndex];
          _items[itemIndex] = item.copyWith(
            total: newPrice * item.quantity,
          );
        }
      });
    } else {
      _showErrorSnackBar('Price cannot be below base selling price: TZS ${basePrice.toStringAsFixed(0)}');
    }
  }
  
  // Navigation helpers
  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // Sale completion
  Future<void> _completeSale() async {
    if (_items.isEmpty) {
      _showErrorSnackBar('Please add items to the sale');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Determine if sale should be marked as credit
      final isCredit = _salesType == 'Field Sales Agent' && !_isPaymentComplete;
      
      // Create sale object for future API integration
      // final sale = SaleModel.withCurrentTime(
      //   id: DateTime.now().millisecondsSinceEpoch.toString(),
      //   customerName: _customerNameController.text.isNotEmpty ? _customerNameController.text : null,
      //   customerPhone: _customerPhoneController.text.isNotEmpty ? _customerPhoneController.text : null,
      //   items: _items,
      //   totalAmount: _totalInSelectedCurrency,
      //   discount: 0.0,
      //   status: isCredit ? 'pending' : 'completed',
      //   paymentMethod: _selectedPaymentMethod,
      //   dateTime: DateTime.now(),
      //   note: _noteController.text.isNotEmpty ? _noteController.text : null,
      // );
      
      // Create comprehensive sale data for future API integration
      // final saleData = {
      //   'sale': [sale object],
      //   'customerType': _customerType,
      //   'salesType': _salesType,
      //   'isDelivery': _customerType == 'Delivery Customer',
      //   'deliveryAddress': _deliveryAddressController.text,
      //   'deliveryContact': _deliveryContactController.text,
      //   'deliveryPhone': _deliveryPhoneController.text,
      //   'deliveryRegion': _selectedRegion,
      //   'deliveryCharge': _actualDeliveryCharge,
      //   'hasFreeDelivery': _hasFreeDelivery,
      //   'accessory': _selectedAccessory,
      //   'hasFreeAccessory': _hasFreeAccessory,
      //   'accessoryPrice': _accessoryPrice,
      //   'vatApplied': _applyVAT,
      //   'vatAmount': _vatAmount,
      //   'currency': _selectedCurrency,
      //   'exchangeRate': _exchangeRate,
      //   'paidAmount': _paidAmount,
      //   'remainingAmount': _totalInSelectedCurrency - _paidAmount,
      //   'priceAdjustments': _productPriceAdjustments,
      //   'isCredit': isCredit,
      // };
      
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
        
        // Navigate back after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
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
  
  // UI helpers
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
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
              Icon(LucideIcons.printer, color: Colors.white),
              const SizedBox(width: 8),
              Text('Receipt copied to clipboard - Ready to print!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    });
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

TOTAL: TZS ${_totalInTZS.toStringAsFixed(0)}
Payment Method: ${_selectedPaymentMethod ?? 'Cash'}''';

    if (_selectedCurrency != 'TZS') {
      final amountInForeignCurrency = _totalInTZS / _exchangeRate;
      receipt += '''
Currency: $_selectedCurrency
Amount: $_currencySymbol${amountInForeignCurrency.toStringAsFixed(2)}
Exchange Rate: 1 $_selectedCurrency = ${_exchangeRate.toStringAsFixed(0)} TZS''';
    }

    if (_paidAmount > 0) {
      final change = _paidAmount - (_totalInTZS / _exchangeRate);
      receipt += '''
Paid: $_currencySymbol${_paidAmount.toStringAsFixed(2)}''';
      if (change > 0) {
        receipt += '''
Change: $_currencySymbol${change.toStringAsFixed(2)}''';
      }
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
              const SizedBox(height: 16),
              Text(
                'Processing Sale...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (_salesType == 'Field Sales Agent' && !_isPaymentComplete) ...[
                const SizedBox(height: 8),
                Text(
                  'Adding to Madeni tracking',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: Text(
          'New Sale',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    for (int i = 0; i <= 2; i++) ...[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: i <= _currentStep ? AppTheme.mkbhdRed : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: i <= _currentStep ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (i < 2) ...[
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i < _currentStep ? AppTheme.mkbhdRed : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              
              // Step labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Customer', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    Text('Products', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    Text('Payment', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildCustomerStep(),
                    _buildProductsStep(),
                    _buildPaymentStep(),
                  ],
                ),
              ),
              
              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppTheme.mkbhdRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Previous',
                            style: TextStyle(color: AppTheme.mkbhdRed, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    
                    if (_currentStep > 0) const SizedBox(width: 16),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentStep == 2 ? _completeSale : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mkbhdRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _currentStep == 2 ? 'Complete Sale' : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
      ),
    );
  }
  
  // Step 1: Customer Management
  Widget _buildCustomerStep() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Type Selection
          Text(
            'Customer Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildCustomerTypeCard(
                  title: 'Walk-in Customer',
                  subtitle: 'In-shop purchase',
                  icon: LucideIcons.store,
                  isSelected: _customerType == 'Walk-in Customer',
                  onTap: () {
                    setState(() {
                      _customerType = 'Walk-in Customer';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCustomerTypeCard(
                  title: 'Delivery Customer',
                  subtitle: 'Goods to be delivered',
                  icon: LucideIcons.truck,
                  isSelected: _customerType == 'Delivery Customer',
                  onTap: () {
                    setState(() {
                      _customerType = 'Delivery Customer';
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Sales Type (Direct or Field Agent)
          Text(
            'Sales Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSalesTypeCard(
                  title: 'Direct Sale',
                  subtitle: 'Immediate payment',
                  icon: LucideIcons.creditCard,
                  isSelected: _salesType == 'Direct Sale',
                  onTap: () {
                    setState(() {
                      _salesType = 'Direct Sale';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSalesTypeCard(
                  title: 'Field Sales Agent',
                  subtitle: 'Payment by 8 PM',
                  icon: LucideIcons.userCheck,
                  isSelected: _salesType == 'Field Sales Agent',
                  onTap: () {
                    setState(() {
                      _salesType = 'Field Sales Agent';
                    });
                  },
                ),
              ),
            ],
          ),
          
          // Field Sale Warning
          if (_salesType == 'Field Sales Agent') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.clock, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Field sales must be paid by 8:00 PM today. Unpaid sales will be tracked in Madeni and notifications will be sent.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Customer Details
          Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _customerNameController,
            decoration: InputDecoration(
              labelText: 'Customer Name',
              prefixIcon: Icon(LucideIcons.user),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _customerPhoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(LucideIcons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.phone,
          ),
          
          // Delivery specific fields
          if (_customerType == 'Delivery Customer') ...[
            const SizedBox(height: 24),
            Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _deliveryAddressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                prefixIcon: Icon(LucideIcons.mapPin),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _deliveryContactController,
              decoration: InputDecoration(
                labelText: 'Delivery Contact Person',
                prefixIcon: Icon(LucideIcons.userCheck),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _deliveryPhoneController,
              decoration: InputDecoration(
                labelText: 'Delivery Contact Phone',
                prefixIcon: Icon(LucideIcons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 16),
            
            // Delivery Region Selection
            Text(
              'Delivery Region',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _regionalDeliveryCharges.keys.map((region) {
                final isSelected = _selectedRegion == region;
                final charge = _regionalDeliveryCharges[region]!;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRegion = region;
                      _deliveryCharge = charge;
                      // Auto-apply free delivery for near shop
                      _hasFreeDelivery = charge == 0.0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.mkbhdRed : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.mkbhdRed),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          region,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.mkbhdRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          charge == 0 ? 'Free' : 'TZS ${charge.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : AppTheme.mkbhdRed.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  // Step 2: Products Management
  Widget _buildProductsStep() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // Product search
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products to add...',
              prefixIcon: Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: _searchProducts,
          ),
        ),
        
        // Search results
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.mkbhdRed),
                const SizedBox(width: 12),
                Text('Searching products...'),
              ],
            ),
          ),
        
        if (_searchResults.isNotEmpty) ...[
          Container(
            height: 200,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.mkbhdRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.package, color: AppTheme.mkbhdRed),
                    ),
                    title: Text(product.name),
                    subtitle: Text('TZS ${product.sellingPrice.toStringAsFixed(0)}'),
                    trailing: IconButton(
                      icon: Icon(LucideIcons.plus, color: AppTheme.mkbhdRed),
                      onPressed: () => _addProductToCart(product, 1),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
        // Cart items
        Expanded(
          child: _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.shoppingCart, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No items in cart',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search and add products to begin',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final adjustedPrice = _productPriceAdjustments[item.productId] ?? item.price;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Base: TZS ${item.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(LucideIcons.trash2, color: Colors.red),
                                  onPressed: () => _removeItem(index),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Price adjustment
                            Row(
                              children: [
                                Text('Selling Price:'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: adjustedPrice.toStringAsFixed(0),
                                    decoration: InputDecoration(
                                      prefixText: 'TZS ',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onFieldSubmitted: (value) {
                                      final newPrice = double.tryParse(value) ?? adjustedPrice;
                                      _adjustProductPrice(item.productId, newPrice, item.price);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Quantity controls
                            Row(
                              children: [
                                Text('Quantity:'),
                                const Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(LucideIcons.minus, size: 16),
                                        onPressed: () => _updateItemQuantity(index, item.quantity - 1),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      IconButton(
                                        icon: Icon(LucideIcons.plus, size: 16),
                                        onPressed: () => _updateItemQuantity(index, item.quantity + 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Item total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Item Total:'),
                                Text(
                                  'TZS ${(adjustedPrice * item.quantity).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.mkbhdRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Cart summary
        if (_items.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.1),
              border: Border(top: BorderSide(color: AppTheme.mkbhdRed.withOpacity(0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${_items.length} items):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'TZS ${_subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VAT is optional and at seller discretion',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
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
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.mkbhdRed),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                style: TextStyle(
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
                        'Payment Method',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem(value: method, child: Text(method));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
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
                          children: [
                            Text(currency),
                            if (currency != 'TZS') ...[
                              const Spacer(),
                              Text(
                                '1 $currency = ${_exchangeRates[currency]!.toStringAsFixed(0)} TZS',
                                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
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
                  TextFormField(
                    controller: _paidAmountController,
                    decoration: InputDecoration(
                      labelText: 'Amount Paid (${_currencySymbol})',
                      prefixIcon: Icon(LucideIcons.dollarSign),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _paidAmount = double.tryParse(value) ?? 0.0;
                      });
                    },
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
                      child: Row(
                        children: [
                          Icon(
                            _isPaymentComplete ? LucideIcons.checkCircle : LucideIcons.clock,
                            color: _isPaymentComplete ? Colors.green : Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isPaymentComplete
                                ? 'Change: ${_currencySymbol} ${_changeAmount.toStringAsFixed(2)}'
                                : 'Remaining: ${_currencySymbol} ${(_totalInSelectedCurrency - _paidAmount).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: _isPaymentComplete ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
  
  Widget _buildCustomerTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.mkbhdRed : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.mkbhdRed),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.mkbhdRed,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.mkbhdRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : AppTheme.mkbhdRed.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSalesTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.mkbhdRed : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.mkbhdRed),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.mkbhdRed,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.mkbhdRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : AppTheme.mkbhdRed.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }
  
  Widget _buildSummaryRow(String label, String value, {String? originalPrice, bool isTotal = false, bool isSubtext = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: TextStyle(
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

