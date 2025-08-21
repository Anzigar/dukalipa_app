import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import '../screens/add_customer_screen.dart';
import '../../../common/widgets/custom_snack_bar.dart';

class CustomerSelectionDialog extends StatefulWidget {
  final String? initialSearch;
  final bool allowNewCustomer;
  
  const CustomerSelectionDialog({
    Key? key,
    this.initialSearch,
    this.allowNewCustomer = true,
  }) : super(key: key);

  @override
  State<CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<CustomerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final CustomerRepository _repository = CustomerRepositoryImpl();
  
  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
    }
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final customers = await _repository.getCustomers();
      if (mounted) {
        setState(() {
          _customers = customers;
          _filteredCustomers = customers;
          _isLoading = false;
        });
        _filterCustomers();
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

  void _filterCustomers() {
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      setState(() {
        _filteredCustomers = _customers;
      });
    } else {
      setState(() {
        _filteredCustomers = _customers.where((customer) {
          return customer.name.toLowerCase().contains(searchTerm) ||
                 customer.phoneNumber.contains(searchTerm) ||
                 (customer.email?.toLowerCase().contains(searchTerm) ?? false);
        }).toList();
      });
    }
  }

  Future<void> _addNewCustomer() async {
    final result = await context.push<CustomerModel>(
      '/customers/add',
      extra: {
        'fromSales': true,
        'initialPhone': _searchController.text.isNotEmpty ? _searchController.text : null,
      },
    );
    
    if (result != null) {
      context.pop(result);
    }
  }

  void _selectCustomer(CustomerModel customer) {
    context.pop(customer);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.users,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Select Customer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      LucideIcons.x,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _filterCustomers(),
                decoration: InputDecoration(
                  hintText: 'Search customers by name, phone, or email...',
                  prefixIcon: Icon(LucideIcons.search, color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ),
            
            // Customer List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTheme.mkbhdRed),
                          SizedBox(height: 16.h),
                          Text('Loading customers...'),
                        ],
                      ),
                    )
                  : _hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.alertCircle,
                                size: 48.sp,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16.h),
                              Text('Error loading customers'),
                              SizedBox(height: 8.h),
                              Text(_errorMessage ?? 'Please try again'),
                              SizedBox(height: 16.h),
                              FilledButton(
                                onPressed: _loadCustomers,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredCustomers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.users,
                                    size: 64.sp,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'No customers yet'
                                        : 'No customers found',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'Add your first customer to get started'
                                        : 'Try adjusting your search terms',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (widget.allowNewCustomer) ...[
                                    SizedBox(height: 24.h),
                                    FilledButton.icon(
                                      onPressed: _addNewCustomer,
                                      icon: Icon(LucideIcons.userPlus),
                                      label: Text('Add Customer'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppTheme.mkbhdRed,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: _filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = _filteredCustomers[index];
                                return _buildCustomerTile(customer);
                              },
                            ),
            ),
            
            // Bottom Actions
            if (widget.allowNewCustomer && _filteredCustomers.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addNewCustomer,
                    icon: Icon(LucideIcons.userPlus),
                    label: Text('Add New Customer'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.mkbhdRed),
                      foregroundColor: AppTheme.mkbhdRed,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTile(CustomerModel customer) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectCustomer(customer),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Customer Avatar
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                  child: Text(
                    customer.initials,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mkbhdRed,
                    ),
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Customer Info
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
                      SizedBox(height: 4.h),
                      Text(
                        customer.phoneNumber,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (customer.email != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          customer.email!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Customer Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      customer.formattedTotalPurchases,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mkbhdRed,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${customer.purchaseCount} purchases',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(width: 8.w),
                
                // Select Icon
                Icon(
                  LucideIcons.chevronRight,
                  color: colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
