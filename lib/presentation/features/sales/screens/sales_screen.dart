import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../providers/sales_provider.dart';
import '../models/sale_model.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  final List<String> _filterOptions = ['All', 'completed', 'pending', 'cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesData();
    });
  }

  Future<void> _loadSalesData() async {
    try {
      await context.read<SalesProvider>().loadSales();
    } catch (e) {
      // Handle network errors gracefully
      if (mounted) {
        final provider = context.read<SalesProvider>();
        // Clear error so we show empty state instead of error state
        provider.clearError();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SaleModel> _getFilteredSales(List<SaleModel> sales) {
    var filtered = sales;
    
    if (_selectedFilter != 'All') {
      filtered = filtered.where((sale) => sale.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((sale) {
        return (sale.customerName?.toLowerCase().contains(query) ?? false) ||
               sale.id.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        final hasSales = salesProvider.sales.isNotEmpty;
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Sales',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: colorScheme.onSurface,
            // Only show search and filter when there are sales
            bottom: hasSales ? PreferredSize(
              preferredSize: Size.fromHeight(100.h),
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildFilterChips(),
                  SizedBox(height: 10.h),
                ],
              ),
            ) : null,
          ),
          body: _buildBody(salesProvider),
          floatingActionButton: _buildFloatingActionButton(salesProvider),
        );
      },
    );
  }

  Widget _buildBody(SalesProvider salesProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (salesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredSales = _getFilteredSales(salesProvider.sales);

    // Show empty state if no sales, even if there's an error
    if (filteredSales.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200.w,
                height: 200.w,
                child: Lottie.asset(
                  'assets/animations/Tags.json',
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                  errorBuilder: (context, error, stackTrace) {
                    print('Lottie loading error: $error');
                    return Container(
                      width: 200.w,
                      height: 200.w,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 100.sp,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Start your sales',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Record your first sale to get started with sales management.',
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
                onPressed: () => context.push('/sales/add'),
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
                  'Add Sale',
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

    // Only show error state if there are sales but there's an error
    if (salesProvider.errorMessage != null && salesProvider.sales.isNotEmpty) {
      return Center(
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
            SizedBox(height: 16.h),
            Text(
              'Error: ${salesProvider.errorMessage}',
              style: TextStyle(
                fontSize: 16.sp,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => _loadSalesData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      itemCount: filteredSales.length,
      itemBuilder: (context, index) {
        final sale = filteredSales[index];
        return _buildSaleCard(sale);
      },
    );
  }

  Widget _buildFloatingActionButton(SalesProvider salesProvider) {
    final filteredSales = _getFilteredSales(salesProvider.sales);
    final colorScheme = Theme.of(context).colorScheme;
    
    return !salesProvider.isLoading && 
           filteredSales.isNotEmpty
        ? FloatingActionButton(
            onPressed: () {
              context.push('/sales/add');
            },
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            mini: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(Icons.add_rounded, size: 20.sp),
          )
        : const SizedBox.shrink();
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      height: 48.h, // Material3 standard height
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r), // Fully rounded Material3 style
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        decoration: InputDecoration(
          hintText: 'Search sales...',
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

  Widget _buildFilterChips() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option;
          
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = option;
                });
              },
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
                  option,
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
        },
      ),
    );
  }

  Widget _buildSaleCard(SaleModel sale) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.push('/sales/${sale.id}');
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sale #${sale.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  _buildStatusChip(sale.status),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                sale.customerName ?? 'Walk-in Customer',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${sale.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    _formatDate(sale.dateTime),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
