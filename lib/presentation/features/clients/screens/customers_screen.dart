import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import '../../../common/widgets/animated_empty_state.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CustomerModel> _customers = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;
  late CustomerRepository _repository;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchCustomers();
    });
  }
  
  void _initRepository() {
    try {
      _repository = Provider.of<CustomerRepository>(context, listen: false);
    } catch (e) {
      _repository = CustomerRepositoryImpl();
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchCustomers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final customers = await _repository.getCustomers(
        search: _searchController.text,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      if (mounted) {
        setState(() {
          _customers = customers;
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
  
  void _onSearch(String query) {
    _fetchCustomers();
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
    );
    
    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
      _fetchCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasCustomers = _customers.isNotEmpty;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Customers',
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
        actions: [
          IconButton(
            icon: Icon(LucideIcons.calendarDays, size: 20.sp),
            onPressed: _showDateRangeDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: Icon(LucideIcons.plus, size: 20.sp),
            onPressed: () => context.push('/customers/add'),
            tooltip: 'Add customer',
          ),
        ],
        // Only show search when there are customers
        bottom: hasCustomers ? PreferredSize(
          preferredSize: Size.fromHeight(80.h),
          child: Column(
            children: [
              _buildSearchBar(),
              SizedBox(height: 16.h),
            ],
          ),
        ) : null,
      ),
      body: _isLoading 
          ? _buildLoadingState()
          : _hasError 
              ? _buildErrorState()
              : hasCustomers 
                  ? _buildCustomersList()
                  : _buildEmptyState(),
      floatingActionButton: hasCustomers ? FloatingActionButton.extended(
        onPressed: () => context.push('/customers/add'),
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        icon: Icon(LucideIcons.plus, size: 20.sp),
        label: Text(
          'Add Customer',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ) : null,
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SearchBar(
        controller: _searchController,
        onChanged: _onSearch,
        hintText: 'Search customers...',
        leading: Icon(
          LucideIcons.search,
          color: colorScheme.onSurfaceVariant,
          size: 20.sp,
        ),
        trailing: _searchController.text.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: colorScheme.onSurfaceVariant,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                ),
              ]
            : null,
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.focused)) {
              return colorScheme.surface;
            }
            return colorScheme.surfaceContainerHigh;
          },
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        side: WidgetStateProperty.resolveWith<BorderSide?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.focused)) {
              return BorderSide(
                color: colorScheme.primary,
                width: 2.0,
              );
            }
            return BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1.0,
            );
          },
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
        constraints: BoxConstraints(
          minHeight: 56.h,
          maxHeight: 56.h,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: AnimatedLoadingState.general(
        message: 'Loading customers...',
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 48.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error loading customers',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage ?? 'Please try again later',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: _fetchCustomers,
            icon: Icon(LucideIcons.refreshCw, size: 20.sp),
            label: Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.mkbhdRed,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedEmptyState.customers(
      title: 'No Customers Yet',
      message: 'Add customers to manage their information, track purchases, and build relationships.',
      buttonText: 'Add Customer',
      onButtonPressed: () => context.push('/customers/add'),
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        return _buildCustomerCard(_customers[index]);
      },
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/customers/${customer.id}'),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                      child: Text(
                        customer.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (customer.phoneNumber.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.phone,
                                  size: 12.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  customer.phoneNumber,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TZS ${NumberFormat('#,###').format(customer.totalPurchases)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mkbhdRed,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Total purchases',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: LucideIcons.shoppingBag,
                      label: '${customer.purchaseCount} orders',
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.w),
                    _buildInfoChip(
                      icon: LucideIcons.calendar,
                      label: 'Since ${DateFormat('MMM yyyy').format(customer.createdAt)}',
                      color: Colors.green,
                    ),
                  ],
                ),
                if (customer.email != null || customer.address != null) ...[
                  SizedBox(height: 12.h),
                  if (customer.email != null)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mail,
                          size: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          customer.email!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  if (customer.address != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            customer.address!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
