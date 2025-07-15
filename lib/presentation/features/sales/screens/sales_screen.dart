import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/sale_model.dart';
import '../repositories/sales_repository.dart';
import '../widgets/sales_empty_state.dart';
import '../../../common/widgets/shimmer_loading.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final SalesRepository _repository;
  List<SaleModel> _sales = [];
  List<SaleModel> _filteredSales = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String _selectedStatus = 'All';
  
  late AnimationController _loadingController;
  late AnimationController _fabController;
  bool _controllersInitialized = false;

  final List<String> _statuses = ['All', 'completed', 'pending', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _repository = SalesRepositoryImpl();
    _initializeControllers();
    _fetchSales();
  }

  void _initializeControllers() {
    if (!_controllersInitialized && mounted) {
      _loadingController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
      
      _fabController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      
      _controllersInitialized = true;
      
      if (_isLoading) {
        _loadingController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_controllersInitialized) {
      _loadingController.dispose();
      _fabController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchSales() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    if (_controllersInitialized && _loadingController.isAnimating) {
      _loadingController.stop();
    }

    try {
      final sales = await _repository.getSales(
        search: _searchController.text,
        status: _selectedStatus == 'All' ? null : _selectedStatus,
      );
      
      if (mounted) {
        setState(() {
          _sales = sales;
          _filteredSales = sales;
          _isLoading = false;
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

  void _applyFilters() {
    List<SaleModel> filtered = List.from(_sales);
    
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filtered = filtered.where((sale) =>
        sale.customerName?.toLowerCase().contains(searchQuery) == true ||
        sale.customerPhone?.toLowerCase().contains(searchQuery) == true ||
        sale.id.toLowerCase().contains(searchQuery)
      ).toList();
    }
    
    if (_selectedStatus != 'All') {
      filtered = filtered.where((sale) => sale.status == _selectedStatus).toList();
    }
    
    filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    setState(() {
      _filteredSales = filtered;
    });
  }

  Widget _buildSalesList() {
    if (_filteredSales.isEmpty) {
      return SalesEmptyState(
        title: _searchController.text.isNotEmpty 
            ? 'No sales found' 
            : 'No sales yet',
        message: _searchController.text.isNotEmpty 
            ? 'Try adjusting your search or filters'
            : 'Start making sales to see them here',
        icon: Icons.receipt_long_outlined,
        actionLabel: _searchController.text.isNotEmpty 
            ? 'Clear Search' 
            : 'Add New Sale',
        onAction: _searchController.text.isNotEmpty 
            ? () {
                _searchController.clear();
                _applyFilters();
              }
            : () => context.push('/sales/add'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: _filteredSales.length,
      itemBuilder: (context, index) {
        final sale = _filteredSales[index];
        return _buildSaleCard(sale);
      },
    );
  }

  Widget _buildSaleCard(SaleModel sale) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/sales/${sale.id}'),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppTheme.mkbhdRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.receipt_rounded,
                      color: AppTheme.mkbhdRed,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sale #${sale.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          sale.customerName ?? 'Walk-in Customer',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(sale.status),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      sale.status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Text(
                    sale.formattedAmount,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    sale.formattedDateTime,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.mkbhdGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          l10n?.sales ?? 'Sales',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            onPressed: _fetchSales,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilters(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Search sales...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    size: 24.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) => const SalesCardShimmer(),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.mkbhdGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading sales',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage ?? 'Unknown error occurred',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _fetchSales,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.mkbhdRed,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchSales,
                        color: AppTheme.mkbhdRed,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSalesList(),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.mkbhdRed,
              AppTheme.mkbhdDarkRed,
            ],
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/sales/add'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'New Sale',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
