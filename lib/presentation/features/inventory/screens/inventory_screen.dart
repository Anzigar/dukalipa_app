import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/constants/shop_types.dart';
import '../models/product_model.dart';
import '../providers/inventory_provider.dart';
import '../widgets/product_card_widget.dart';

class InventoryScreen extends StatefulWidget {
  final String shopType;

  const InventoryScreen({
    super.key,
    this.shopType = ShopTypes.general,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  List<ProductModel> _products = [];
  List<String> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInventory();
      _fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventory() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final provider = context.read<InventoryProvider>();
      provider.searchProducts(_searchController.text);
      provider.filterByCategory(_selectedCategory);
      
      await provider.loadProducts(forceRefresh: true);
      final products = provider.products;
      
      if (mounted) {
        final filteredProducts = _filterProductsByShopType(products);
        
        setState(() {
          _products = filteredProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = [];
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  List<ProductModel> _filterProductsByShopType(List<ProductModel> products) {
    if (widget.shopType == ShopTypes.general) {
      return products;
    }
    
    return products.where((product) => 
      product.category?.toLowerCase() == widget.shopType.toLowerCase()
    ).toList();
  }

  Future<void> _fetchCategories() async {
    try {
      final provider = context.read<InventoryProvider>();
      await provider.loadCategories(forceRefresh: true);
      final categories = provider.categories;
      
      if (mounted) {
        if (widget.shopType != ShopTypes.general) {
          setState(() {
            _categories = [widget.shopType];
            _selectedCategory = widget.shopType;
          });
        } else {
          setState(() {
            _categories = categories;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categories = ['Electronics', 'Clothing', 'Food', 'Beverages', 'Stationery'];
        });
      }
    }
  }

  void _onSearch(String query) {
    _fetchInventory();
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchInventory();
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      height: 48.h, // Increased height for Material3 design
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r), // Fully rounded like Material3
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategory == null;
            return _buildCategoryChip('All', isSelected, () => _onCategorySelected(null));
          }
          
          final category = _categories[index - 1];
          final isSelected = _selectedCategory == category;
          
          return _buildCategoryChip(
            category, 
            isSelected, 
            () => _onCategorySelected(isSelected ? null : category)
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected 
                ? colorScheme.primary
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected 
                ? null 
                : Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    
    String title;
    String message;
    IconData? icon;
    bool showLottie = false;

    if (_searchController.text.isNotEmpty) {
      title = 'No products found';
      message = 'No products match "${_searchController.text}".\nTry adjusting your search terms.';
      icon = Icons.search_off_rounded;
    } else if (_selectedCategory != null) {
      title = 'No products in this category';
      message = 'No products found in the selected category.\nTry selecting a different category.';
      icon = Icons.category_outlined;
    } else {
      title = 'Start your inventory';
      message = 'Add your first product to get started with inventory management.';
      showLottie = true;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showLottie)
              SizedBox(
                width: 200.w,
                height: 200.w,
                child: Lottie.asset(
                  'assets/animations/Empty_box.json',
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              )
            else
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon!,
                  size: 80.sp,
                  color: colorScheme.primary,
                ),
              ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            SizedBox(height: 32.h),
            if (_searchController.text.isEmpty && _selectedCategory == null)
              ElevatedButton.icon(
                onPressed: () => context.push('/inventory/add', extra: {'shopType': widget.shopType}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.add_rounded, size: 18.sp),
                label: Text(
                  'Add Product',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40.sp,
                color: colorScheme.error,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Failed to load products',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'There was an error loading your inventory.\nPlease check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: _fetchInventory,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ProductCardWidget(
            product: _products[index],
            onTap: () => context.push('/inventory/product/${_products[index].id}'),
            colorScheme: Theme.of(context).colorScheme,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSpecificShopType = widget.shopType != ShopTypes.general;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          isSpecificShopType 
              ? '${widget.shopType} Inventory'
              : l10n.inventory,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : _products.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        _buildSearchBar(),
                        _buildCategoryFilters(),
                        Expanded(child: _buildProductsList()),
                      ],
                    ),
      floatingActionButton: !_isLoading && !_hasError && _products.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => context.push('/inventory/add', extra: {'shopType': widget.shopType}),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              mini: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(Icons.add_rounded, size: 20.sp),
            )
          : null,
    );
  }
}

