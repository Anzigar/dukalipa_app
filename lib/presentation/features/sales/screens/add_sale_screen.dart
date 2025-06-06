import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/sale_item_model.dart';
import '../repositories/sales_repository.dart';
import '../../inventory/models/product_model.dart';
import '../../inventory/repositories/inventory_repository.dart';
import '../../../common/widgets/custom_button.dart';

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

class _AddSaleScreenState extends State<AddSaleScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _discountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _noteController = TextEditingController();
  
  final List<SaleItemModel> _items = [];
  bool _isSearching = false;
  bool _isLoading = false;
  List<ProductModel> _searchResults = [];
  String _searchQuery = '';
  double _discount = 0;
  
  // Animation controller for loading animation
  late AnimationController _loadingController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize loading animation controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // If a product was pre-selected, add it to the cart
    if (widget.preSelectedProduct != null) {
      _addProductToCart(widget.preSelectedProduct!, 1);
    }
  }
  
  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _discountController.dispose();
    _paymentMethodController.dispose();
    _noteController.dispose();
    _loadingController.dispose(); // Dispose animation controller
    super.dispose();
  }
  
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });
    
    try {
      final repository = context.read<InventoryRepository>();
      final products = await repository.getProducts(search: query);
      
      if (mounted) {
        setState(() {
          _searchResults = products;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching products: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _addProductToCart(ProductModel product, int quantity) {
    // Check if product is already in cart
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    setState(() {
      if (existingIndex >= 0) {
        // Update quantity if product is already in cart
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: _items[existingIndex].quantity + quantity,
          total: _items[existingIndex].price * (_items[existingIndex].quantity + quantity)
        );
      } else {
        // Add new item to cart
        _items.add(
          SaleItemModel(
            productId: product.id,
            productName: product.name,
            price: product.sellingPrice,
            quantity: quantity,
            total: product.sellingPrice * quantity,
          ),
        );
      }
      
      // Clear search results
      _searchResults = [];
      _searchQuery = '';
    });
  }
  
  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      setState(() {
        _items.removeAt(index);
      });
      return;
    }
    
    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(
        quantity: newQuantity,
        total: item.price * newQuantity,
      );
    });
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
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
                  // Use scaling animation for the icon
                  final scale = 0.8 + 0.2 * ((_loadingController.value - 0.5).abs() * 2);
                  
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.shopping_cart_checkout_rounded, // Sale-specific M3 expressive icon
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
                // Material 3 expressive loading icon
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
                  'Processing your sale...',
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
        ],
      ),
    );
  }
  
  Future<void> _handleCompleteSale() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one item to the sale'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating, // Material 3 style
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final repository = context.read<SalesRepository>();
        
        // Parse discount
        double discount = 0;
        if (_discountController.text.isNotEmpty) {
          discount = double.tryParse(_discountController.text) ?? 0;
        }
        
        await repository.createSale(
          items: _items,
          customerName: _customerNameController.text.isNotEmpty ? _customerNameController.text : null,
          customerPhone: _customerPhoneController.text.isNotEmpty ? _customerPhoneController.text : null,
          discount: discount,
          paymentMethod: _paymentMethodController.text.isNotEmpty ? _paymentMethodController.text : null,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sale completed successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating, // Material 3 style
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating, // Material 3 style
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }
  
  double get _subtotal => 
    _items.fold(0, (total, item) => total + item.total);
    
  double get _total => 
    _subtotal - _discount;
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addSale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? _buildMaterial3LoadingIndicator() // Replace LoadingWidget with Material 3 indicator
          : SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                  // Product search
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Search Products',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: _searchProducts,
                          decoration: InputDecoration(
                            hintText: 'e.g., Samsung TV, iPhone, Rice 5kg...',
                            helperText: 'Type to search products by name or code',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppTheme.mkbhdLightGrey.withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppTheme.mkbhdLightGrey.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.mkbhdRed,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchProducts('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                        
                        // Search results
                        if (_isSearching)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_searchResults.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            height: 200,
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final product = _searchResults[index];
                                return ListTile(
                                  title: Text(product.name),
                                  subtitle: Text(
                                    '${product.formattedPrice} - ${product.quantity} in stock',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      _addProductToCart(product, 1);
                                    },
                                  ),
                                  onTap: () {
                                    _addProductToCart(product, 1);
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Cart items
                  Expanded(
                    child: _items.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: AppTheme.mkbhdLightGrey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Cart is empty',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Search for products to add to this sale',
                                  style: TextStyle(
                                    color: AppTheme.mkbhdLightGrey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: AppTheme.mkbhdLightGrey.withOpacity(0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Item details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'TSh ${item.price.toStringAsFixed(0)} × ${item.quantity} = TSh ${item.total.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                color: AppTheme.mkbhdLightGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Quantity controls
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: () {
                                              _updateItemQuantity(index, item.quantity - 1);
                                            },
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            onPressed: () {
                                              _updateItemQuantity(index, item.quantity + 1);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () {
                                              _removeItem(index);
                                            },
                                            color: Colors.red,
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
                  
                  // Sale details and checkout
                  if (_items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Summary
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text(
                                'TSh ${_subtotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Discount
                          Row(
                            children: [
                              const Text('Discount:'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: TextField(
                                    controller: _discountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'e.g., 5000',
                                      helperText: 'Enter discount amount in TSh',
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      prefixIcon: const Icon(Icons.discount_outlined),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _discount = double.tryParse(value) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Total
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'TSh ${_total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.mkbhdRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Customer Information
                          const Text(
                            'Customer Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Customer Name
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: _customerNameController,
                              decoration: InputDecoration(
                                hintText: 'e.g., John Doe',
                                helperText: 'Enter customer name if applicable',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Customer Phone
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: _customerPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'e.g., +255 123 456 789',
                                helperText: 'Enter customer phone if applicable',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                prefixIcon: const Icon(Icons.phone_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Payment Method
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              prefixIcon: const Icon(Icons.payment_outlined),
                            ),
                            hint: const Text('Select Payment Method'),
                            isExpanded: true,
                            value: _paymentMethodController.text.isEmpty ? null : _paymentMethodController.text,
                            items: const [
                              DropdownMenuItem(
                                value: 'Cash',
                                child: Text('Cash'),
                              ),
                              DropdownMenuItem(
                                value: 'Mobile Money',
                                child: Text('Mobile Money'),
                              ),
                              DropdownMenuItem(
                                value: 'Bank Transfer',
                                child: Text('Bank Transfer'),
                              ),
                              DropdownMenuItem(
                                value: 'Credit Card',
                                child: Text('Credit Card'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _paymentMethodController.text = value;
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Note
                          SizedBox(
                            height: 80,
                            child: TextField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'e.g., Customer paid via M-Pesa transaction ID 123456',
                                helperText: 'Add any additional notes about this sale',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                prefixIcon: const Icon(Icons.note_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Checkout button
                          CustomButton(
                            text: 'Complete Sale',
                            onPressed: _handleCompleteSale,
                            isLoading: _isLoading,
                            borderRadius: 16,  // Match other elements
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
}
