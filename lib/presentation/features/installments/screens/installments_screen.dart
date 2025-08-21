import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../../../common/widgets/custom_snack_bar.dart';

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
        });
        CustomSnackBar.showError(context: context, message: e.toString());
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
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
          preferredSize: Size.fromHeight(120.h),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              SizedBox(height: 16.h),
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
          style: GoogleFonts.poppins(
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
        hintText: 'Search installments...',
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
          GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(
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

  Widget _buildFilterChips() {
    final colorScheme = Theme.of(context).colorScheme;
    final statuses = ['All', 'Active', 'Overdue', 'Completed', 'Defaulted'];
    
    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status || (_selectedStatus == null && status == 'All');
          
          return Container(
            margin: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                _onStatusSelected(status == 'All' ? null : status);
              },
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.secondaryContainer,
              labelStyle: WidgetStateTextStyle.resolveWith(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondaryContainer,
                    );
                  }
                  return GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  );
                },
              ),
              side: BorderSide(
                color: isSelected 
                    ? colorScheme.secondary 
                    : colorScheme.outline.withOpacity(0.2),
                width: isSelected ? 1.5 : 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => const TransactionCardShimmer(),
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
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage ?? 'Please try again later',
            style: GoogleFonts.poppins(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Empty_box.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'No Installment Plans',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create installment plans to offer flexible payment options to your customers.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/installments/add'),
            icon: const Icon(LucideIcons.plus),
            label: const Text('Create Plan'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.mkbhdRed,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
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
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (installment.notes != null && installment.notes!.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              installment.notes!,
                              style: GoogleFonts.poppins(
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
                        style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${installment.payments.length} payments made',
                      style: GoogleFonts.poppins(
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
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.poppins(
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
