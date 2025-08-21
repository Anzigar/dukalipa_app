import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';

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
  late CustomerRepository _repository;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchCustomers();
      _checkRouteParameters();
    });
  }

  void _checkRouteParameters() {
    final uri = Uri.parse(ModalRoute.of(context)?.settings.name ?? '');
    final searchParam = uri.queryParameters['search'];
    if (searchParam != null && searchParam.isNotEmpty) {
      _searchController.text = searchParam;
      _fetchCustomers();
    }
  }

  void _openBarcodeScanner() async {
    final result = await context.push('/barcode/scanner');
    if (result != null && result is String) {
      // Handle barcode result
      _searchController.text = result;
      _fetchCustomers();
    }
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
    // Add a small delay to avoid too many API calls while typing
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _searchController.text == query) {
        _fetchCustomers();
      }
    });
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
        // Always show search bar like homepage
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(76.h),
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: _isLoading 
          ? _buildLoadingState()
          : _hasError 
              ? _buildErrorState()
              : hasCustomers 
                  ? _buildCustomersList()
                  : _buildEmptyState(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24.r),
                onTap: () {
                  _showSearchDialog();
                },
                splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _searchController.text.isNotEmpty 
                              ? _searchController.text 
                              : 'Search customers...',
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 44.w,
            height: 44.h,
            margin: EdgeInsets.only(right: 2.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22.r),
                onTap: _openBarcodeScanner,
                splashColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                child: Icon(
                  LucideIcons.scanLine,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Customers'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter customer name, phone, or email...',
            border: OutlineInputBorder(),
          ),
          onChanged: _onSearch,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchCustomers();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }


  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return AnimatedEmptyState.customers(
      title: 'No Customers Yet',
      message: 'Add your first customer to track purchases and build relationships.',
      buttonText: 'Add Customer',
      onButtonPressed: () => context.push('/customers/add'),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty) {
      // Show search-specific empty state
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 24.h),
              Text(
                'No customers found',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'No customers match "${_searchController.text}".\nTry adjusting your search terms.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use standard AnimatedEmptyState for no customers
    return AnimatedEmptyState.customers(
      title: 'No Customers Yet',
      message: 'Add your first customer to track purchases and build relationships.',
      buttonText: 'Add Customer',
      onButtonPressed: () => context.push('/customers/add'),
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        return _buildCustomerCard(_customers[index]);
      },
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/customers/${customer.id}'),
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          Theme.of(context).colorScheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        customer.name.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (customer.phoneNumber.isNotEmpty)
                          Text(
                            customer.phoneNumber,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14.sp,
                            ),
                          ),
                        if (customer.email != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            customer.email!,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TZS ${NumberFormat('#,###').format(customer.totalPurchases)}',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Total Purchases',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${customer.purchaseCount}',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Orders',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (customer.address != null) ...[
                SizedBox(height: 12.h),
                Text(
                  customer.address!,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 8.h),
              Text(
                'Customer since ${DateFormat('MMM yyyy').format(customer.createdAt)}',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
