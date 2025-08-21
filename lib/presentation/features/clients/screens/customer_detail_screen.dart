import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import '../../../common/widgets/loading_widget.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  
  const CustomerDetailScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  CustomerModel? _customer;
  late CustomerRepository _repository;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchCustomer();
    });
  }
  
  void _initRepository() {
    try {
      _repository = Provider.of<CustomerRepository>(context, listen: false);
    } catch (e) {
      _repository = CustomerRepositoryImpl();
    }
  }
  
  Future<void> _fetchCustomer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final customer = await _repository.getCustomerById(widget.customerId);
      
      if (mounted) {
        setState(() {
          _customer = customer;
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
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Customer Details',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.edit2, size: 20.sp),
            onPressed: _customer != null ? () => _editCustomer() : null,
            tooltip: 'Edit Customer',
          ),
        ],
      ),
      body: _buildContent(colorScheme),
      floatingActionButton: _customer != null ? FloatingActionButton.extended(
        onPressed: () => context.push('/sales/add', extra: {'customer': _customer}),
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        icon: Icon(LucideIcons.shoppingCart, size: 20.sp),
        label: Text(
          'New Sale',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ) : null,
    );
  }
  
  Widget _buildContent(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertTriangle,
              size: 48.sp,
              color: Colors.orange,
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage ?? 'An error occurred while loading customer details',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 48.h,
              child: FilledButton.icon(
                onPressed: _fetchCustomer,
                icon: Icon(LucideIcons.refreshCw, size: 20.sp),
                label: Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.mkbhdRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_customer == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.userX,
              size: 64.sp,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'Customer not found',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'The customer you are looking for does not exist.',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer header with avatar
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppTheme.mkbhdRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppTheme.mkbhdRed.withOpacity(0.3),
                  child: Text(
                    _customer!.initials,
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mkbhdRed,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _customer!.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.phone,
                            size: 16.sp,
                            color: AppTheme.mkbhdRed,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _customer!.phoneNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (_customer!.email != null) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mail,
                              size: 16.sp,
                              color: AppTheme.mkbhdRed,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _customer!.email!,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Purchase summary cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Total Purchases',
                  value: _customer!.formattedTotalPurchases,
                  icon: LucideIcons.shoppingCart,
                  color: AppTheme.mkbhdRed,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildInfoCard(
                  label: 'Purchase Count',
                  value: _customer!.purchaseCount.toString(),
                  icon: LucideIcons.clipboardCheck,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Last Purchase',
                  value: _customer!.formattedLastPurchaseDate,
                  icon: LucideIcons.calendar,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildInfoCard(
                  label: 'Customer Since',
                  value: DateFormat('MMM yyyy').format(_customer!.createdAt),
                  icon: LucideIcons.userCheck,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          // Customer details section
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                
                _buildDetailRow('Name', _customer!.name, colorScheme),
                _buildDetailRow('Phone', _customer!.phoneNumber, colorScheme),
                if (_customer!.email != null)
                  _buildDetailRow('Email', _customer!.email!, colorScheme),
                if (_customer!.address != null)
                  _buildDetailRow('Address', _customer!.address!, colorScheme),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Recent purchases section
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Purchases',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildRecentPurchases(colorScheme),
              ],
            ),
          ),
          
          SizedBox(height: 32.h),
          
          // Action buttons - centered and rounded
          Center(
            child: Column(
              children: [
                // View All Purchases button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton.icon(
                    onPressed: () => _showPurchasesInfo(),
                    icon: Icon(LucideIcons.shoppingBag, size: 20.sp),
                    label: Text(
                      'View All Purchases',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.mkbhdRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Edit Customer button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton.icon(
                    onPressed: () => _editCustomer(),
                    icon: Icon(LucideIcons.edit2, size: 20.sp),
                    label: Text(
                      'Edit Customer',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.mkbhdRed),
                      foregroundColor: AppTheme.mkbhdRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Delete Customer button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(),
                    icon: Icon(LucideIcons.trash2, size: 20.sp),
                    label: Text(
                      'Delete Customer',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentPurchases(ColorScheme colorScheme) {
    // In a real app, you would fetch and display real purchase data
    // Here we're using mock data for demonstration
    return Column(
      children: List.generate(3, (index) {
        // Mock purchase data
        final dates = [
          DateTime.now().subtract(const Duration(days: 2)),
          DateTime.now().subtract(const Duration(days: 10)),
          DateTime.now().subtract(const Duration(days: 25)),
        ];
        
        final amounts = [25000.0, 35000.0, 48000.0];
        final itemCounts = [3, 5, 2];
        
        return Container(
          margin: EdgeInsets.only(bottom: index < 2 ? 12.h : 0),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.mkbhdRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  LucideIcons.shoppingBag,
                  size: 16.sp,
                  color: AppTheme.mkbhdRed,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase #${1000 + index}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${itemCounts[index]} items',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TSh ${NumberFormat("#,###").format(amounts[index])}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: AppTheme.mkbhdRed,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    DateFormat('MMM d, yyyy').format(dates[index]),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
  
  void _editCustomer() {
    // Navigate to add customer screen in edit mode
    context.push('/customers/add', extra: {'customer': _customer});
  }
  
  void _showPurchasesInfo() {
    // Show info about purchases since the detailed view route doesn't exist yet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customer Purchases'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${_customer!.name}'),
            SizedBox(height: 8.h),
            Text('Total Purchases: ${_customer!.formattedTotalPurchases}'),
            SizedBox(height: 8.h),
            Text('Purchase Count: ${_customer!.purchaseCount}'),
            SizedBox(height: 8.h),
            Text('Last Purchase: ${_customer!.formattedLastPurchaseDate}'),
            SizedBox(height: 16.h),
            Text(
              'Detailed purchase history view will be implemented in future updates.',
              style: GoogleFonts.poppins(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCustomer();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteCustomer() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _repository.deleteCustomer(widget.customerId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete customer: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
