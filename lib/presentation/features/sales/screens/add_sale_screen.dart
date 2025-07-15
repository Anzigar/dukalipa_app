import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/sale_model.dart';
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
  
  // Progress tracking
  double _saleProgress = 0.0;
  bool _showProgress = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this, // FIX: add required vsync argument
    )..repeat();
    
    // If a product was pre-selected, add it to the cart
    if (widget.preSelectedProduct != null) {
      _addProductToCart(widget.preSelectedProduct!, 1);
      _updateSaleProgress();
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
      // Mock search results for demo
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockProducts = [
        ProductModel(
          id: '1',
          name: 'Samsung Galaxy S21',
          description: 'Latest smartphone',
          barcode: '1234567890',
          sellingPrice: 950000,
          costPrice: 850000,
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
          name: 'Wireless Earbuds',
          description: 'High quality sound',
          barcode: '0987654321',
          sellingPrice: 85000,
          costPrice: 65000,
          quantity: 15,
          lowStockThreshold: 3,
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
      _searchQuery = '';
      _updateSaleProgress();
    });
  }

  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
      return;
    }
    
    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(
        quantity: newQuantity,
        total: item.price * newQuantity,
      );
      _updateSaleProgress();
    });
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _updateSaleProgress();
    });
  }

  // Update sale progress based on completion criteria
  void _updateSaleProgress() {
    double progress = 0.0;
    
    // Items added (40% weight)
    if (_items.isNotEmpty) {
      progress += 0.4;
    }
    
    // Customer details (20% weight)
    if (_customerNameController.text.isNotEmpty || _customerPhoneController.text.isNotEmpty) {
      progress += 0.2;
    }
    
    // Payment method (20% weight) - simplified for demo
    progress += 0.2;
    
    // Discount applied (20% weight) - if any customization
    if (_discount > 0 || _items.length > 1) {
      progress += 0.2;
    }
    
    setState(() {
      _saleProgress = progress.clamp(0.0, 1.0);
      _showProgress = _items.isNotEmpty;
    });
  }

  // Material 3 progressive loading indicator
  Widget _buildMaterial3ProgressiveIndicator() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showProgress ? 80 : 0,
      child: _showProgress ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.mkbhdRed.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.mkbhdRed.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.trendingUp,
                  color: AppTheme.mkbhdRed,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sale Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_saleProgress * 100).toInt()}% Complete',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mkbhdRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: _saleProgress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.mkbhdRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.mkbhdRed,
                              AppTheme.mkbhdDarkRed,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ) : const SizedBox.shrink(),
    );
  }

  // Enhanced Material 3 loading indicator for sale processing
  Widget _buildMaterial3LoadingIndicator() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main loading container with flat design
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.mkbhdRed.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated background pulse - no shadow
                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    return Container(
                      width: 100 + (20 * _loadingController.value),
                      height: 100 + (20 * _loadingController.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.mkbhdRed.withOpacity(0.1 * (1 - _loadingController.value)),
                            AppTheme.mkbhdRed.withOpacity(0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Main circular progress with Material 3 styling
                SizedBox(
                  width: 80,
                  height: 80,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: null, // Indeterminate
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        color: AppTheme.mkbhdRed,
                        backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                      );
                    },
                  ),
                ),
                
                // Central icon with scaling animation
                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    final scale = 0.9 + 0.1 * (0.5 + 0.5 * (_loadingController.value));
                    
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.mkbhdRed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.shoppingCart,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Processing text with fade animation
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              final opacity = 0.7 + 0.3 * (0.5 + 0.5 * (_loadingController.value));
              
              return AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 150),
                child: Column(
                  children: [
                    Text(
                      'Processing Sale...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait while we complete your transaction',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Step progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return AnimatedBuilder(
                animation: _loadingController,
                builder: (context, _) {
                  final delay = index * 0.2;
                  final animValue = ((_loadingController.value + delay) % 1.0);
                  final isActive = animValue > 0.5;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive 
                            ? AppTheme.mkbhdRed 
                            : AppTheme.mkbhdRed.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Items being processed - flat design
          if (_items.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.mkbhdRed.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_items.length} items',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'TSh ${_total.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar for processing
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.mkbhdRed),
                        minHeight: 4,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleCompleteSale() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add items to the sale'),
          backgroundColor: AppTheme.mkbhdRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create sale using SaleModel.withCurrentTime factory
      final sale = SaleModel.withCurrentTime(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _customerNameController.text.isNotEmpty ? _customerNameController.text : null,
        customerPhone: _customerPhoneController.text.isNotEmpty ? _customerPhoneController.text : null,
        items: _items,
        totalAmount: _total,
        discount: _discount,
        status: 'completed',
        paymentMethod: _paymentMethodController.text.isNotEmpty ? _paymentMethodController.text : null,
        dateTime: DateTime.now(),
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale completed successfully! Total: TSh ${_total.toStringAsFixed(0)}'),
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
            content: Text('Failed to complete sale: ${e.toString()}'),
            backgroundColor: AppTheme.mkbhdRed,
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

  double get _subtotal => 
    _items.fold(0, (total, item) => total + item.total);
    
  double get _total => 
    _subtotal - _discount;
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: _buildMaterial3LoadingIndicator(),
      );
    }
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: Text(
          'Add Sales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Material 3 Progress Indicator
            _buildMaterial3ProgressiveIndicator(),
            
            // Cart/Items section header - flat design
            if (_items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.mkbhdRed.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.mkbhdRed.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.shoppingCart,
                      color: AppTheme.mkbhdRed,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Sale Items (${_items.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.mkbhdRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'TSh ${_total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product search section - flat design
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.metaLightBackground.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLarge),
                        border: Border.all(
                          color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.search,
                                color: AppTheme.mkbhdRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Products',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search products to add...',
                              prefixIcon: Icon(
                                LucideIcons.package,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.mkbhdRed,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: _searchProducts,
                          ),
                        ],
                      ),
                    ),
                    
                    // Search results or loading with Material 3 progress
                    if (_isSearching) ...[
                      const SizedBox(height: 16),
                      // Search progress with flat design
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                strokeCap: StrokeCap.round,
                                color: AppTheme.mkbhdRed,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Searching products...',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Search Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_searchResults.map((product) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.mkbhdRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.package,
                              color: AppTheme.mkbhdRed,
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Text('TSh ${product.sellingPrice.toStringAsFixed(0)}'),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.mkbhdRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                LucideIcons.plus,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () => _addProductToCart(product, 1),
                            ),
                          ),
                        ),
                      ))),
                    ],
                    
                    // Cart items - flat design
                    if (_items.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      ...(_items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
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
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          // FIX: Use item.price instead of item.unitPrice
                                          'TSh ${item.price.toStringAsFixed(0)} × ${item.quantity}',
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.mkbhdRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'TSh ${item.total.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.mkbhdRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.mkbhdLightGrey.withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            LucideIcons.minus,
                                            size: 16,
                                            color: AppTheme.mkbhdRed,
                                          ),
                                          onPressed: () => _updateItemQuantity(index, item.quantity - 1),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            LucideIcons.plus,
                                            size: 16,
                                            color: AppTheme.mkbhdRed,
                                          ),
                                          onPressed: () => _updateItemQuantity(index, item.quantity + 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      LucideIcons.trash2,
                                      color: Colors.red.shade400,
                                      size: 18,
                                    ),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      })),
                    ],
                    
                    // Customer details section - flat design
                    if (_items.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.metaLightBackground.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLarge),
                          border: Border.all(
                            color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.user,
                                  color: AppTheme.mkbhdRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Customer Details (Optional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _customerNameController,
                              decoration: InputDecoration(
                                labelText: 'Customer Name',
                                prefixIcon: Icon(LucideIcons.user),
                                filled: true,
                                fillColor: colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _customerPhoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(LucideIcons.phone),
                                filled: true,
                                fillColor: colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
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
            
            // Bottom section with total and complete button
            if (_items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      // Total summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.mkbhdRed.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.mkbhdRed.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'TSh ${_subtotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            if (_discount > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Discount:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '- TSh ${_discount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'TSh ${_total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.mkbhdRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Complete sale button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.mkbhdRed,
                                AppTheme.mkbhdDarkRed,
                              ],
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleCompleteSale,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: _isLoading 
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    LucideIcons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            label: Text(
                              _isLoading ? 'Processing...' : 'Complete Sale',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
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
}
