import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/dukalipa_colors.dart';
import '../../../common/widgets/material3_search_bar.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../inventory/models/product_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  bool _isSearching = false;
  final List<String> _recentSearches = ['Product name', 'Sale #12345', 'Customer name'];
  List<ProductModel> _productResults = [];
  List<String> _generalResults = [];

  @override
  void initState() {
    super.initState();
    // Auto-focus search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      if (inventoryProvider.products.isEmpty) {
        inventoryProvider.loadProducts();
      }
    });
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _productResults = [];
        _generalResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Search in inventory products
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      
      final products = inventoryProvider.products
          .where((item) => 
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              (item.barcode?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (item.category?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .take(10) // Limit to 10 results for performance
          .toList();

      // Add mock general results for other categories
      final generalResults = <String>[];
      if (query.toLowerCase().contains('sale') || query.toLowerCase().contains('#')) {
        generalResults.add('Sale: #12345 (${query})');
        generalResults.add('Sale: #12346 (${query})');
      }
      if (query.toLowerCase().contains('customer') || query.toLowerCase().contains('client')) {
        generalResults.add('Customer: ${query} Johnson');
        generalResults.add('Customer: ${query} Smith');
      }

      setState(() {
        _isSearching = false;
        _productResults = products;
        _generalResults = generalResults;
      });

      // Add to recent searches if not empty and not already present
      if (query.trim().isNotEmpty && !_recentSearches.contains(query.trim())) {
        setState(() {
          _recentSearches.insert(0, query.trim());
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      debugPrint('Search error: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft, 
            color: isDark ? Colors.white : AirbnbColors.secondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Search',
          style: TextStyle(
            color: isDark ? Colors.white : AirbnbColors.secondary,
          ),
        ),
      ),
      body: Column(
        children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Material3SearchBar(
                controller: _searchController,
                onChanged: _performSearch,
                hintText: 'Search products, sales, clients...',
              ),
            ),          if (_isSearching)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: AirbnbColors.primary,
                ),
              ),
            )
          else if (_searchController.text.isNotEmpty && _productResults.isEmpty && _generalResults.isEmpty)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120.w,
                      height: 120.w,
                      child: Lottie.asset(
                        'assets/animations/No_Data.json',
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.contain,
                        repeat: true,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Lottie loading error: $error');
                          return Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Icon(
                              LucideIcons.search,
                              size: 60.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'No Results Found',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Try searching with different keywords\nor check your spelling',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (_productResults.isNotEmpty || _generalResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _productResults.length + _generalResults.length,
                itemBuilder: (context, index) {
                  if (index < _productResults.length) {
                    // Product result
                    final product = _productResults[index];
                    return _buildProductResult(product);
                  } else {
                    // General result
                    final generalIndex = index - _productResults.length;
                    final result = _generalResults[generalIndex];
                    return _buildGeneralResult(result);
                  }
                },
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AirbnbColors.secondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _recentSearches.isNotEmpty
                        ? ListView.builder(
                            itemCount: _recentSearches.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(LucideIcons.clock),
                                title: Text(_recentSearches[index]),
                                trailing: IconButton(
                                  icon: Icon(
                                    LucideIcons.x, 
                                    size: 16,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _recentSearches.removeAt(index);
                                    });
                                  },
                                ),
                                onTap: () {
                                  _searchController.text = _recentSearches[index];
                                  _performSearch(_recentSearches[index]);
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'No recent searches',
                              style: TextStyle(
                                color: AirbnbColors.lightText,
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

  Widget _buildProductResult(ProductModel product) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _openProductDetails(product),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    LucideIcons.package,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (product.category?.isNotEmpty == true)
                        Text(
                          product.category!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      SizedBox(height: 2.h),
                      Text(
                        'Stock: ${product.quantity}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: product.quantity > 0 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TSh ${product.sellingPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (product.barcode?.isNotEmpty == true)
                      Text(
                        product.barcode!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralResult(String result) {
    IconData icon;
    Color iconColor;
    
    if (result.startsWith('Product:')) {
      icon = LucideIcons.package;
      iconColor = Colors.blue;
    } else if (result.startsWith('Customer:')) {
      icon = LucideIcons.user;
      iconColor = Colors.green;
    } else if (result.startsWith('Sale:')) {
      icon = LucideIcons.receipt;
      iconColor = Colors.orange;
    } else {
      icon = LucideIcons.wallet;
      iconColor = Colors.purple;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _handleGeneralResultTap(result),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    result,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openProductDetails(ProductModel product) {
    context.push('/inventory/details/${product.id}');
  }

  void _handleGeneralResultTap(String result) {
    if (result.startsWith('Sale:')) {
      context.push('/sales');
    } else if (result.startsWith('Customer:')) {
      context.push('/customers');
    } else {
      context.push('/expenses');
    }
  }
}

