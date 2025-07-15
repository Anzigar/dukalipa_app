import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/damaged_products_service.dart';
import '../providers/damaged_products_provider.dart';
import '../../../common/widgets/custom_search_bar.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../../core/di/service_locator.dart';

class DamagedProductsScreen extends StatefulWidget {
  const DamagedProductsScreen({super.key});

  @override
  State<DamagedProductsScreen> createState() => _DamagedProductsScreenState();
}

class _DamagedProductsScreenState extends State<DamagedProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DamagedProductModel> _damagedProducts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;
  late DamagedProductsProvider _provider;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProvider();
      _fetchDamagedProducts();
    });
  }
  
  void _initProvider() {
    try {
      // Try to get the provider from the context first
      _provider = Provider.of<DamagedProductsProvider>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance
      _provider = locator<DamagedProductsProvider>();
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchDamagedProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Use the provider to load damaged products
      await _provider.loadDamagedProducts(refresh: true);
      
      if (mounted) {
        setState(() {
          _damagedProducts = _provider.damagedProducts;
          _isLoading = false;
          _hasError = _provider.error != null;
          _errorMessage = _provider.error;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }
  
  void _onSearch(String query) {
    if (query.isEmpty) {
      _fetchDamagedProducts();
    } else {
      _provider.searchDamagedProducts(query);
      setState(() {
        _damagedProducts = _provider.damagedProducts;
      });
    }
  }
  
  Future<void> _showDateRangeDialog() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      end: _endDate ?? DateTime.now(),
    );
    
    final dateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.mkbhdRed,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black87,
              surface: AppTheme.mkbhdRed.withOpacity(0.1),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.mkbhdRed,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
      _fetchDamagedProducts();
    }
  }
  
  double get _totalLoss => 
    _damagedProducts.fold(0, (total, product) => total + product.estimatedLoss);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Damaged Products'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarDays),
            onPressed: _showDateRangeDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: const Icon(LucideIcons.barChart2),
            onPressed: () {
              // Show damaged product analytics
            },
            tooltip: 'Analytics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date filter chip
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(LucideIcons.x, size: 16),
                    onDeleted: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _fetchDamagedProducts();
                    },
                    backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                    deleteIconColor: AppTheme.mkbhdRed,
                    labelStyle: const TextStyle(color: AppTheme.mkbhdRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search damaged products',
              onSearch: _onSearch,
            ),
          ),
          
          // Damaged products summary
          if (!_isLoading && !_hasError && _damagedProducts.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Damaged Items',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_damagedProducts.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Loss',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TSh ${NumberFormat('#,###').format(_totalLoss)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Damaged products list
          Expanded(
            child: _buildDamagedProductsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/settings/damaged/report'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Report Damaged'),
      ),
    );
  }
  
  Widget _buildDamagedProductsList() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => const TransactionCardShimmer(),
      );
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred while loading damaged products',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDamagedProducts,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.mkbhdRed,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_damagedProducts.isEmpty) {
      return EmptyState(
        icon: LucideIcons.packageX,
        title: 'No Damaged Products Found',
        message: 'Report damaged products to track inventory losses',
        buttonText: 'Report Damaged',
        onButtonPressed: () => context.push('/settings/damaged/report'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchDamagedProducts,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _damagedProducts.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final product = _damagedProducts[index];
          return DamagedProductCard(
            product: product,
            onTap: () => context.push('/settings/damaged/${product.id}'),
          );
        },
      ),
    );
  }
}

class DamagedProductCard extends StatelessWidget {
  final DamagedProductModel product;
  final VoidCallback onTap;
  
  const DamagedProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode 
              ? Colors.grey.shade700
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Product image or icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            LucideIcons.packageX,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                      )
                    : const Icon(
                        LucideIcons.packageX,
                        color: Colors.red,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${product.quantity}',
                      style: TextStyle(
                        color: isDarkMode 
                            ? Colors.grey.shade400 
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reported: ${DateFormat('MMM d, yyyy').format(product.dateDiscovered)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode 
                            ? Colors.grey.shade400 
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // Loss info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TSh ${NumberFormat('#,###').format(product.estimatedLoss)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Loss',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
