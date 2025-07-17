import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/constants/shop_types.dart';
import '../models/product_model.dart';
import '../providers/inventory_provider.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/inventory_summary_widget.dart';
import '../../../common/widgets/material3_search_bar.dart';
import '../../../common/widgets/shimmer_loading.dart';
import 'create_group_screen.dart';

class InventoryScreen extends StatefulWidget {
  final String shopType;

  const InventoryScreen({
    super.key,
    this.shopType = ShopTypes.general,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSupplier;
  List<ProductModel> _products = [];
  List<String> _categories = [];
  List<String> _suppliers = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFiltering = false;

  // Animation controllers with proper null safety
  late AnimationController _loadingController;
  late AnimationController _fabAnimationController;
  bool _isFabMenuOpen = false;
  bool _controllersInitialized = false;
  
  // Auto-refresh timer
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(minutes: 5); // Refresh every 5 minutes

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    
    // Use post frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchInventory();
        _fetchCategories();
        _fetchSuppliers();
      }
    });
    
    // Set up auto-refresh timer
    _startAutoRefresh();
  }
  
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (mounted && !_isLoading) {
        _fetchInventory();
      }
    });
  }

  void _initializeControllers() {
    if (!_controllersInitialized && mounted) {
      // Initialize loading animation controller
      _loadingController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
      
      // Initialize FAB animation controller
      _fabAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      
      _controllersInitialized = true;
      
      // Start loading animation only if still loading
      if (_isLoading) {
        _loadingController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    
    // Cancel auto-refresh timer
    _refreshTimer?.cancel();
    
    // Safely dispose animation controllers
    if (_controllersInitialized) {
      _loadingController.dispose();
      _fabAnimationController.dispose();
    }
    
    super.dispose();
  }

  Future<void> _fetchInventory() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Start loading animation for smooth transitions
    if (_controllersInitialized) {
      _loadingController.reset();
      _loadingController.forward();
    }

    try {
      // Try to get products from provider
      InventoryProvider? provider;
      try {
        provider = context.read<InventoryProvider>();
        // Set search parameters
        provider.searchProducts(_searchController.text);
        provider.filterByCategory(_selectedCategory);
        provider.filterBySupplier(_selectedSupplier);
        
        // Load products from backend
        await provider.loadProducts(forceRefresh: true);
        final products = provider.products;
        
        if (mounted) {
          // Filter products based on shop type and apply filters
          final filteredProducts = _applyFilters(_filterProductsByShopType(products));
          
          setState(() {
            _products = filteredProducts;
            _isLoading = false;
            _isFiltering = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _products = [];
            _isLoading = false;
            _isFiltering = false;
            _hasError = true;
          });
          
          // Show error message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load inventory: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: _fetchInventory,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = [];
          _isLoading = false;
          _isFiltering = false;
          _hasError = true;
        });
      }
    }
  }

  // Apply filters to the product list
  List<ProductModel> _applyFilters(List<ProductModel> products) {
    List<ProductModel> filteredProducts = List.from(products);
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filteredProducts = filteredProducts.where((product) =>
        product.name.toLowerCase().contains(searchQuery) ||
        product.description?.toLowerCase().contains(searchQuery) == true ||
        product.category?.toLowerCase().contains(searchQuery) == true ||
        product.supplier?.toLowerCase().contains(searchQuery) == true ||
        product.barcode?.toLowerCase().contains(searchQuery) == true
      ).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) =>
        product.category?.toLowerCase() == _selectedCategory!.toLowerCase()
      ).toList();
    }
    
    // Apply supplier filter
    if (_selectedSupplier != null && _selectedSupplier!.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) =>
        product.supplier?.toLowerCase() == _selectedSupplier!.toLowerCase()
      ).toList();
    }
    
    return filteredProducts;
  }

  // Filter products based on the shop type - ensure null safety
  List<ProductModel> _filterProductsByShopType(List<ProductModel> products) {
    // If it's a general shop, return all products
    if (widget.shopType == ShopTypes.general) {
      return products;
    }
    
    // Otherwise, filter products by their category matching the shop type
    return products.where((product) => 
      product.category?.toLowerCase() == widget.shopType.toLowerCase()
    ).toList();
  }

  Future<void> _fetchCategories() async {
    try {
      InventoryProvider? provider;
      try {
        provider = context.read<InventoryProvider>();
        await provider.loadCategories(forceRefresh: true);
        final categories = provider.categories;
        
        if (mounted) {
          // If shop type is specific, only show that category
          if (widget.shopType != ShopTypes.general) {
            setState(() {
              _categories = [widget.shopType];
              _selectedCategory = widget.shopType; // Preselect the category
            });
          } else {
            setState(() {
              _categories = categories;
            });
          }
        }
      } catch (e) {
        // Use dummy categories if provider fails
        if (mounted) {
          setState(() {
            _categories = ['Electronics', 'Clothing', 'Food', 'Beverages', 'Stationery', 'Other'];
          });
        }
      }
    } catch (e) {
      // Fallback to dummy categories
      if (mounted) {
        setState(() {
          _categories = ['Electronics', 'Clothing', 'Food', 'Beverages', 'Stationery', 'Other'];
        });
      }
    }
  }

  Future<void> _fetchSuppliers() async {
    try {
      InventoryProvider? provider;
      try {
        provider = context.read<InventoryProvider>();
        await provider.loadSuppliers(forceRefresh: true);
        final suppliers = provider.suppliers;
        
        if (mounted) {
          setState(() {
            _suppliers = suppliers;
          });
        }
      } catch (e) {
        // Use dummy suppliers if provider fails
        if (mounted) {
          setState(() {
            _suppliers = [
              'Local Supplier',
              'International Distributor', 
              'Wholesale Market', 
              'Direct Factory', 
              'Online Store'
            ];
          });
        }
      }
    } catch (e) {
      // Fallback to dummy suppliers
      if (mounted) {
        setState(() {
          _suppliers = [
            'Local Supplier',
            'International Distributor', 
            'Wholesale Market', 
            'Direct Factory', 
            'Online Store'
          ];
        });
      }
    }
  }

  void _onSearch(String query) {
    // Show filtering state
    setState(() {
      _isFiltering = true;
    });
    
    // Add a small delay to prevent multiple API calls while typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (query == _searchController.text && mounted) {
        _fetchInventory();
      }
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _isFiltering = true;
    });
    // Add smooth transition delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fetchInventory();
      }
    });
  }

  Widget _buildCategoriesStrip(ColorScheme colorScheme) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategory == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: isSelected,
                onSelected: (selected) => _onCategorySelected(null),
                selectedColor: colorScheme.primary.withOpacity(0.15),
                checkmarkColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                labelStyle: TextStyle(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            );
          }
          
          final category = _categories[index - 1];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) => _onCategorySelected(selected ? category : null),
              selectedColor: colorScheme.primary.withOpacity(0.15),
              checkmarkColor: colorScheme.primary,
              backgroundColor: colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    // Context-aware empty state messages
    String title;
    String message;
    IconData icon;

    if (_searchController.text.isNotEmpty) {
      title = 'No products found';
      message = 'No products match "${_searchController.text}".\nTry adjusting your search terms.';
      icon = Icons.search_off_rounded;
    } else if (_selectedCategory != null || _selectedSupplier != null) {
      title = 'No products found';
      message = 'No products match your current filters.\nTry adjusting or clearing your filters.';
      icon = Icons.filter_list_off_rounded;
    } else {
      title = 'No products yet';
      message = 'Start building your inventory by adding your first product.';
      icon = Icons.inventory_2_outlined;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedCategory != null || _selectedSupplier != null) ...[
              // Clear filters button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedSupplier = null;
                    _searchController.clear();
                    _isFiltering = true;
                  });
                  _fetchInventory();
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
              ),
              const SizedBox(height: 12),
            ],
            // Add product button
            FilledButton.icon(
              onPressed: () => context.push('/inventory/add', extra: {'shopType': widget.shopType}),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'There was an error loading your inventory.\nPlease check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _fetchInventory,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _onProductTap(ProductModel product) {
    // Navigate to product details with error handling
    try {
      context.push('/inventory/product/${product.id}');
    } catch (e) {
      // If navigation fails, show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open product details: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Store current filter state for local changes
    String? tempSelectedCategory = _selectedCategory;
    String? tempSelectedSupplier = _selectedSupplier;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempSelectedCategory = null;
                          tempSelectedSupplier = null;
                        });
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Filter options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Categories
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (tempSelectedCategory != null) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Meta blue
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '1 selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = tempSelectedCategory == category;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              tempSelectedCategory = selected ? category : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Suppliers
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Suppliers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (tempSelectedSupplier != null) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Meta blue
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '1 selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suppliers.map((supplier) {
                        final isSelected = tempSelectedSupplier == supplier;
                        return FilterChip(
                          label: Text(supplier),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              tempSelectedSupplier = selected ? supplier : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Filter summary
                    if (tempSelectedCategory != null || tempSelectedSupplier != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Meta blue
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Row(
                              children: [
                                Icon(
                                  Icons.filter_list_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Active Filters',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (tempSelectedCategory != null)
                              Text(
                                '• Category: $tempSelectedCategory',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (tempSelectedSupplier != null)
                              Text(
                                '• Supplier: $tempSelectedSupplier',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Apply button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          // Apply the filters
                          setState(() {
                            _selectedCategory = tempSelectedCategory;
                            _selectedSupplier = tempSelectedSupplier;
                            _isFiltering = true;
                          });
                          _fetchInventory();
                          Navigator.pop(context);
                          
                          // Show confirmation snackbar
                          final activeFilters = <String>[];
                          if (tempSelectedCategory != null) activeFilters.add('Category');
                          if (tempSelectedSupplier != null) activeFilters.add('Supplier');
                          
                          if (activeFilters.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Filters applied: ${activeFilters.join(', ')}'),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Apply Filters'),
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

  Widget _buildFloatingActionMenu(ColorScheme colorScheme) {
    // Add safety check for animation controller
    if (!_controllersInitialized) {
      return FloatingActionButton(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        onPressed: () => context.push('/inventory/add', extra: {'shopType': widget.shopType}),
        child: const Icon(Icons.add_rounded),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Create Group button
        if (_isFabMenuOpen)
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _fabAnimationController,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                heroTag: "createGroup",
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.white,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  _closeFabMenu();
                  _showCreateGroupDialog();
                },
                icon: const Icon(Icons.folder_outlined),
                label: const Text('Create Group'),
              ),
            ),
          ),

        // Add Product button
        if (_isFabMenuOpen)
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _fabAnimationController,
              curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                heroTag: "addProduct",
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  _closeFabMenu();
                  context.push('/inventory/add', extra: {'shopType': widget.shopType});
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Product'),
              ),
            ),
          ),

        // Main FAB
        FloatingActionButton(
          backgroundColor: _isFabMenuOpen 
              ? colorScheme.surfaceVariant
              : colorScheme.primary,
          foregroundColor: _isFabMenuOpen 
              ? colorScheme.onSurfaceVariant
              : Colors.white,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          disabledElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          onPressed: _toggleFabMenu,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _isFabMenuOpen ? 0.125 : 0.0,
            child: Icon(
              _isFabMenuOpen ? Icons.close_rounded : Icons.add_rounded,
            ),
          ),
        ),
      ],
    );
  }

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
      if (newGroup != null) {
        // Refresh inventory to show any new groups
        _fetchInventory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group "${newGroup.name}" created successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  void _toggleFabMenu() {
    if (!_controllersInitialized || !mounted) return;
    
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
    });
    
    if (_isFabMenuOpen) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  void _closeFabMenu() {
    if (!_controllersInitialized || !mounted) return;
    
    if (_isFabMenuOpen) {
      setState(() {
        _isFabMenuOpen = false;
      });
      _fabAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSpecificShopType = widget.shopType != ShopTypes.general;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: Text(
          isSpecificShopType 
              ? '${widget.shopType} Inventory'
              : l10n.inventory,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          // Filter button with active indicator
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.tune_rounded, 
                  color: colorScheme.primary,
                  size: 24,
                ),
                onPressed: () => _showFilterBottomSheet(context),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  minimumSize: const Size(44, 44),
                ),
              ),
              if (_selectedCategory != null || _selectedSupplier != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _closeFabMenu,
        child: Column(
          children: [
            // Material 3 SearchBar with expressive design - Fixed at top
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Material3SearchBar(
                controller: _searchController,
                onChanged: _onSearch,
                hintText: 'Search products...',
              ),
            ),
            
            // Active filters indicator - Fixed below search
            if (_selectedCategory != null || _selectedSupplier != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active filters:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (_selectedCategory != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _selectedCategory!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (_selectedSupplier != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _selectedSupplier!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                          _selectedSupplier = null;
                          _isFiltering = true;
                        });
                        _fetchInventory();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Scrollable content area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _isLoading || _isFiltering
                    ? Column(
                        key: const ValueKey('loading'),
                        children: [
                          const InventorySummaryShimmer(),
                          const CategoryStripShimmer(),
                          const Expanded(child: ListShimmer()),
                        ],
                      )
                    : RefreshIndicator(
                        key: const ValueKey('content'),
                        onRefresh: () async {
                          // Show smooth loading transition
                          setState(() {
                            _isFiltering = true;
                          });
                          
                          await Future.wait([
                            _fetchInventory(),
                            _fetchCategories(),
                            _fetchSuppliers(),
                          ]);
                        },
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        strokeWidth: 2.5,
                        displacement: 40,
                        child: _buildScrollableContent(colorScheme),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _products.isEmpty 
          ? _buildSimpleInventoryFAB(colorScheme)
          : _buildFloatingActionMenu(colorScheme),
    );
  }

  // Simple FAB for when no products exist
  Widget _buildSimpleInventoryFAB(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/add', extra: {'shopType': widget.shopType}),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        icon: Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Add First Product',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildScrollableContent(ColorScheme colorScheme) {
    final isSpecificShopType = widget.shopType != ShopTypes.general;
    
    // Show error state if there's an error
    if (_hasError) {
      return _buildErrorState(colorScheme);
    }

    // Show empty state for empty products with context-aware message
    if (_products.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    // Scrollable content with summary, categories, and products
    return CustomScrollView(
      slivers: [
        // Inventory Summary Section
        SliverToBoxAdapter(
          child: InventorySummaryWidget(
            products: _products,
            colorScheme: colorScheme,
          ),
        ),
        
        // Horizontal scrolling categories (only if no category filter is active)
        if (_categories.isNotEmpty && !isSpecificShopType && _selectedCategory == null)
          SliverToBoxAdapter(
            child: _buildCategoriesStrip(colorScheme),
          ),
          
        // Product List
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 800)),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProductCardWidget(
                      product: _products[index],
                      onTap: () => _onProductTap(_products[index]),
                      colorScheme: colorScheme,
                    ),
                  ),
                );
              },
              childCount: _products.length,
            ),
          ),
        ),
      ],
    );
  }
}

