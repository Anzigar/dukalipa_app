import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/installment_model.dart';
import '../repositories/installment_repository.dart';
import '../repositories/installment_repository_impl.dart' as impl;
import '../../../common/widgets/animated_empty_state.dart';

class InstallmentsScreen extends StatefulWidget {
  const InstallmentsScreen({Key? key}) : super(key: key);

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<InstallmentModel> _installments = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  late InstallmentRepository _repository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchInstallments();
    });
  }

  void _initRepository() {
    try {
      _repository = Provider.of<InstallmentRepository>(context, listen: false);
    } catch (e) {
      _repository = impl.InstallmentRepositoryImpl();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInstallments() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final installments = await _repository.getInstallments(
        search: _searchController.text,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      if (mounted) {
        setState(() {
          _installments = installments;
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
    _fetchInstallments();
  }

  void _onStatusSelected(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _fetchInstallments();
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
      _fetchInstallments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasInstallments = _installments.isNotEmpty;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Installments',
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
            onPressed: () => context.push('/installments/add'),
            tooltip: 'Add installment plan',
          ),
        ],
        // Only show search and filter when there are installments
        bottom: hasInstallments ? PreferredSize(
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
      body: _isLoading 
          ? _buildLoadingState()
          : _hasError 
              ? _buildErrorState()
              : hasInstallments 
                  ? _buildInstallmentsList()
                  : _buildEmptyState(),
      floatingActionButton: hasInstallments ? FloatingActionButton.extended(
        onPressed: () => context.push('/installments/add'),
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        icon: Icon(LucideIcons.plus, size: 20.sp),
        label: Text(
          'New Plan',
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
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r),
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
          hintText: 'Search installments...',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            size: 20.sp,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    size: 20.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
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
    final statuses = ['All', 'Active', 'Overdue', 'Completed', 'Defaulted'];
    
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status || (_selectedStatus == null && status == 'All');
          
          return Container(
            margin: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(
                status,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                _onStatusSelected(status == 'All' ? null : status);
              },
              backgroundColor: colorScheme.surface,
              selectedColor: AppTheme.mkbhdRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: AnimatedLoadingState.general(
        message: 'Loading installments...',
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
            'Error loading installments',
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
            onPressed: _fetchInstallments,
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
    return AnimatedEmptyState.installments(
      title: 'No Installment Plans',
      message: 'Create installment plans to offer flexible payment options to your customers.',
      buttonText: 'Create Plan',
      onButtonPressed: () => context.push('/installments/add'),
    );
  }

  Widget _buildInstallmentsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _installments.length,
      itemBuilder: (context, index) {
        return _buildInstallmentCard(_installments[index]);
      },
    );
  }

  Widget _buildInstallmentCard(InstallmentModel installment) {
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
          onTap: () => context.push('/installments/${installment.id}'),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            installment.clientName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (installment.notes != null && installment.notes!.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              installment.notes!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(installment).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        _getStatusText(installment),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(installment),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn(
                        'Total Amount',
                        'TZS ${NumberFormat('#,###').format(installment.totalAmount)}',
                        AppTheme.mkbhdRed,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Paid',
                        'TZS ${NumberFormat('#,###').format(installment.paidAmount)}',
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Remaining',
                        'TZS ${NumberFormat('#,###').format(installment.remainingAmount)}',
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 14.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Due: ${DateFormat('MMM d, yyyy').format(installment.dueDate)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${installment.payments.length} payments made',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
  
  Color _getStatusColor(InstallmentModel installment) {
    if (installment.isCompleted) {
      return Colors.green;
    } else if (installment.isDefaulted) {
      return Colors.red;
    } else if (installment.isOverdue) {
      return Colors.orange;
    } else {
      return AppTheme.mkbhdRed;
    }
  }
  
  String _getStatusText(InstallmentModel installment) {
    if (installment.isCompleted) {
      return 'Completed';
    } else if (installment.isDefaulted) {
      return 'Defaulted';
    } else if (installment.isOverdue) {
      return 'Overdue';
    } else {
      return 'Active';
    }
  }
}
