import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/presentation/features/sales/models/sale_item_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lumina/core/theme/airbnb_colors.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../models/sale_model.dart';
import '../repositories/sales_repository.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<SaleModel> _sales = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;
  late SalesRepository _repository;
  
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
    
    // We need to delay the initialization until after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchSales();
    });
  }
  
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<SalesRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance with default API client
      final apiClient = ApiClient();
      _repository = SalesRepositoryImpl(apiClient);
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _loadingController.dispose(); // Dispose animation controller
    super.dispose();
  }
  
  Future<void> _fetchSales() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final sales = await _repository.getSales(
        search: _searchController.text,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      if (mounted) {
        setState(() {
          // Use dummy data if empty or API fails
          _sales = sales.isNotEmpty ? sales : _generateDummySales();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Use dummy data on error
          _sales = _generateDummySales();
          _isLoading = false;
          _hasError = false; // Set to false since we're showing dummy data
        });
      }
    }
  }
  
  // Generate dummy sales data
  List<SaleModel> _generateDummySales() {
    final now = DateTime.now();
    final random = Random();
    
    return List.generate(10, (index) {
      final id = '${1000 + index}';
      final dateTime = now.subtract(Duration(days: random.nextInt(30), hours: random.nextInt(24)));
      final itemCount = random.nextInt(3) + 1;
      final status = _getRandomStatus(random);
      
      final items = List.generate(itemCount, (i) {
        final productOptions = [
          'Samsung Galaxy S21',
          'iPhone 13 Pro',
          'AirPods Pro',
          'MacBook Air',
          'Wireless Mouse',
          'USB-C Cable',
          'Wireless Charger',
          'Bluetooth Speaker',
          'Power Bank',
          'Smart Watch'
        ];
        
        final productName = productOptions[random.nextInt(productOptions.length)];
        final price = (random.nextInt(900) + 100) * 1000.0;
        final quantity = random.nextInt(3) + 1;
        
        return SaleItemModel(
          productId: '${100 + i}',
          productName: productName,
          price: price,
          quantity: quantity,
          total: price * quantity,
        );
      });
      
      final totalAmount = items.fold<double>(0, (prev, item) => prev + item.total);
      final discount = random.nextBool() ? random.nextInt(50) * 1000.0 : 0.0;
      final customerNames = ['John Doe', 'Jane Smith', 'Alex Johnson', null, 'Mary Wilson', null];
      
      return SaleModel(
        id: id,
        items: items,
        totalAmount: totalAmount - discount,
        discount: discount,
        customerName: customerNames[random.nextInt(customerNames.length)],
        customerPhone: random.nextBool() ? '+255${700000000 + random.nextInt(9999999)}' : null,
        paymentMethod: _getRandomPaymentMethod(random),
        dateTime: dateTime,
        status: status,
        note: random.nextBool() ? 'Customer requested fast delivery' : null,
        createdBy: 'system',
        createdAt: dateTime,
      );
    });
  }
  
  String _getRandomStatus(Random random) {
    final statuses = ['completed', 'pending', 'cancelled'];
    final weights = [70, 20, 10]; // 70% completed, 20% pending, 10% cancelled
    
    final totalWeight = weights.fold<int>(0, (sum, weight) => sum + weight);
    final randomValue = random.nextInt(totalWeight);
    
    int cumulativeWeight = 0;
    for (int i = 0; i < statuses.length; i++) {
      cumulativeWeight += weights[i];
      if (randomValue < cumulativeWeight) {
        return statuses[i];
      }
    }
    
    return statuses[0]; // Default to completed
  }
  
  String? _getRandomPaymentMethod(Random random) {
    final methods = ['Cash', 'Mobile Money', 'Bank Transfer', 'Credit Card', null];
    return methods[random.nextInt(methods.length)];
  }
  
  void _onSearch(String query) {
    if (query.isEmpty) {
      _fetchSales();
      return;
    }
    
    // Add a small delay to prevent multiple API calls while typing
    Future.delayed(const Duration(milliseconds: 300), () {
      if (query == _searchController.text) {
        _fetchSales();
      }
    });
  }
  
  // Show modern calendar picker
  void _showDateRangeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar at the top
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Date Range',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      Navigator.pop(context);
                      _fetchSales();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AirbnbColors.primary,
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            
            // Modern calendar widget
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ModernCalendarDatePicker(
                  initialStartDate: _startDate,
                  initialEndDate: _endDate,
                  onRangeSelected: (start, end) {
                    setState(() {
                      _startDate = start;
                      _endDate = end;
                    });
                  },
                ),
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AirbnbColors.primary,
                        side: BorderSide(color: AirbnbColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _fetchSales();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AirbnbColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                      Icons.point_of_sale_rounded, // Sales-specific M3 expressive icon
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
                  'Loading sales data...',
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
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sales',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          // Modern Material 3 action buttons
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceVariant,
              shape: const CircleBorder(),
              child: IconButton(
                icon: Icon(Icons.calendar_month_rounded, color: colorScheme.primary, size: 22),
                onPressed: _showDateRangeDialog,
                tooltip: 'Filter by date',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceVariant,
              shape: const CircleBorder(),
              child: IconButton(
                icon: Icon(Icons.analytics_rounded, color: colorScheme.primary, size: 22),
                onPressed: () {
                  // Show sales analytics
                },
                tooltip: 'Analytics',
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildMaterial3LoadingIndicator()
          : Column(
              children: [
                // Search bar - Material 3 style
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _buildMaterial3SearchBar(colorScheme),
                ),
                
                // Date filter chip - Material 3 style
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.date_range_rounded,
                                size: 16,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _startDate = null;
                                    _endDate = null;
                                  });
                                  _fetchSales();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Sales summary card - Material 3 style
                if (!_isLoading && !_hasError && _sales.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Adjusted margins
                    padding: const EdgeInsets.all(20), // Reduced from 24
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          // No need for mainAxisAlignment since we're using Expanded
                          children: [
                            _buildSummaryItem(
                              'Total Sales', 
                              _calculateTotalSales().toStringAsFixed(0),
                              Icons.attach_money_rounded,
                              colorScheme,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Provide flexible spacing
                              child: Container(
                                width: 1,
                                height: 40,
                                color: colorScheme.onPrimary.withOpacity(0.2),
                              ),
                            ),
                            _buildSummaryItem(
                              'Orders', 
                              '${_sales.length}',
                              Icons.shopping_bag_rounded,
                              colorScheme,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Provide flexible spacing
                              child: Container(
                                width: 1,
                                height: 40,
                                color: colorScheme.onPrimary.withOpacity(0.2),
                              ),
                            ),
                            _buildSummaryItem(
                              'Avg Sale', 
                              (_calculateTotalSales() / (_sales.length > 0 ? _sales.length : 1)).toStringAsFixed(0),
                              Icons.trending_up_rounded,
                              colorScheme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                // Sales list
                Expanded(
                  child: _buildSalesList(l10n, colorScheme),
                ),
              ],
            ),
      // Updated Material 3 Expressive FloatingActionButton
      floatingActionButton: FloatingActionButton(
        heroTag: 'sales_fab',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () => context.push('/sales/add'),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: const Icon(
            Icons.add_rounded,
            key: ValueKey('add_icon'),
            size: 28,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMaterial3SearchBar(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: SizedBox(
        height: 52,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search sales...',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant, size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: _onSearch,
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Expanded(  // Wrap in Expanded to prevent overflow
      child: Column(
        children: [
          Icon(
            icon,
            color: colorScheme.onPrimary.withOpacity(0.9),
            size: 24,
          ),
          const SizedBox(height: 6),
          FittedBox(  // Use FittedBox to ensure text scales down if needed
            fit: BoxFit.scaleDown,
            child: Text(
              value.startsWith('TSh') ? value : 'TSh $value',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,  // Reduced from 20
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2), // Reduced from 4
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.8),
              fontSize: 12,  // Reduced from 13
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesList(AppLocalizations l10n, ColorScheme colorScheme) {
    if (_hasError) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load sales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'An error occurred',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  onPressed: _fetchSales,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_sales.isEmpty) {
      return RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: _fetchSales,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height / 1.5,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.point_of_sale_outlined,
                  size: 80,
                  color: colorScheme.outlineVariant,
                ),
                const SizedBox(height: 24),
                Text(
                  'No Sales Found',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first sale to track your business performance',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.push('/sales/add'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addSale),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: _fetchSales,
      child: ListView.builder(
        controller: _scrollController,
        key: const PageStorageKey<String>('sales_list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        itemCount: _sales.length,
        itemBuilder: (context, index) {
          final sale = _sales[index];
          return ModernSaleCard(
            sale: sale,
            colorScheme: colorScheme,
            onTap: () {
              context.push('/sales/${sale.id}');
            },
          );
        },
      ),
    );
  }
  
  double _calculateTotalSales() {
    return _sales.fold(0, (prev, sale) => prev + sale.totalAmount);
  }
  
  @override
  bool get wantKeepAlive => true;
}

// Modern Sale Card updated for Material 3 expressive design
class ModernSaleCard extends StatelessWidget {
  final SaleModel sale;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  
  const ModernSaleCard({
    super.key,
    required this.sale,
    required this.onTap,
    required this.colorScheme,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sale #${sale.id.substring(0, min(8, sale.id.length))}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sale.formattedDateTime,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusChip(sale.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sale.formattedAmount,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${sale.items.length} items',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Customer info
              _buildCustomerInfoSection(),
              
              // Items preview
              if (sale.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sale.items.take(2).map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.productName,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (sale.items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${sale.items.length - 2} more items',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    final Color statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'mobile money':
        return Icons.smartphone_rounded;
      case 'bank transfer':
        return Icons.account_balance_rounded;
      case 'credit card':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }
  
  String _getStatusText(String status) {
    return status.isNotEmpty 
        ? status[0].toUpperCase() + status.substring(1)
        : '';
  }
  
  // Fix overflow in customer info container
  Widget _buildCustomerInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sale.customerName ?? 'Walk-in Customer',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (sale.paymentMethod != null) ...[
            Container(
              width: 1,
              height: 20,
              color: colorScheme.outlineVariant,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            Icon(
              _getPaymentIcon(sale.paymentMethod!),
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            // Wrap payment method text in Flexible to prevent overflow
            Flexible(
              child: Text(
                sale.paymentMethod!,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ModernCalendarDatePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onRangeSelected;

  const ModernCalendarDatePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onRangeSelected,
  });

  @override
  State<ModernCalendarDatePicker> createState() => _ModernCalendarDatePickerState();
}

class _ModernCalendarDatePickerState extends State<ModernCalendarDatePicker> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialStartDate;
    _rangeEnd = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          rangeSelectionMode: RangeSelectionMode.enforced,
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: const Color(0xFFFF5A60).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            formatButtonTextStyle: const TextStyle(
              color: Color(0xFFFF5A60),
            ),
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          calendarStyle: CalendarStyle(
            rangeHighlightColor: const Color(0xFFFF5A60).withOpacity(0.2),
            rangeStartDecoration: const BoxDecoration(
              color: Color(0xFFFF5A60),
              shape: BoxShape.circle,
            ),
            rangeEndDecoration: const BoxDecoration(
              color: Color(0xFFFF5A60),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: const Color(0xFFFF5A60).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFFFF5A60),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            rangeStartTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            rangeEndTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          onRangeSelected: (start, end, focused) {
            setState(() {
              _rangeStart = start;
              _rangeEnd = end;
              _focusedDay = focused;
            });
            widget.onRangeSelected(start, end);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Show selected range info
        if (_rangeStart != null || _rangeEnd != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _rangeStart != null ? DateFormat('MMM d, yyyy').format(_rangeStart!) : 'Not selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _rangeEnd != null ? DateFormat('MMM d, yyyy').format(_rangeEnd!) : 'Not selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SaleReceiptView extends StatelessWidget {
  final SaleModel sale;
  final ScrollController scrollController;
  
  const SaleReceiptView({
    Key? key,
    required this.sale,
    required this.scrollController,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'RECEIPT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sale #${sale.id}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  sale.formattedDateTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mkbhdLightGrey,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Items
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                // Customer info
                if (sale.customerName != null) ...[
                  ListTile(
                    title: const Text('Customer'),
                    subtitle: Text(sale.customerName!),
                    leading: const Icon(Icons.person_outline),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                
                // Items header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Qty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Price',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Items list
                ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.productName,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'TSh ${item.price.toStringAsFixed(0)}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const Divider(),
                
                // Subtotals
                if (sale.discount > 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text('TSh ${(sale.totalAmount + sale.discount).toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount'),
                        Text('- TSh ${sale.discount.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                ],
                
                // Total
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'TSh ${sale.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Print'),
                      onPressed: () {
                        // Implement printing functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Printing not implemented')),
                        );
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                      onPressed: () {
                        // Implement sharing functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing not implemented')),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Class for repository implementation
class SalesRepositoryImpl implements SalesRepository {
  final ApiClient _apiClient;

  SalesRepositoryImpl(this._apiClient);
  
  @override
  Future<List<SaleModel>> getSales({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      // Implement API call here using _apiClient
      // For now return empty list since we're using dummy data elsewhere
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SaleModel> getSaleById(String id) async {
    try {
      // Implement API call here using _apiClient
      throw UnimplementedError('getSaleById not implemented');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SaleModel> createSale({
    String? customerName,
    String? customerPhone,
    double discount = 0.0,
    required List<SaleItemModel> items,
    String? note,
    String? paymentMethod,
  }) async {
    try {
      // Implement API call here using _apiClient
      throw UnimplementedError('createSale not implemented');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SaleModel> updateSale({
    required String id,
    String? note,
    String? paymentMethod,
    String? status,
  }) async {
    try {
      // Implement API call here using _apiClient
      throw UnimplementedError('updateSale not implemented');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    try {
      // Implement API call here using _apiClient
      throw UnimplementedError('deleteSale not implemented');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> cancelSale(String id) async {
    try {
      // Implement API call here using _apiClient
      throw UnimplementedError('cancelSale not implemented');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Implement API call here using _apiClient
      // For now return empty statistics since we're using dummy data elsewhere
      return {
        'totalSales': 0,
        'totalAmount': 0.0,
        'averageSale': 0.0,
      };
    } catch (e) {
      rethrow;
    }
  }
}
