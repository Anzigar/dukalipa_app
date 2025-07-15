import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/installment_model.dart';
import '../repositories/installment_repository.dart';
import '../repositories/installment_repository_impl.dart' as impl;
import '../../../common/widgets/custom_search_bar.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/shimmer_loading.dart';

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
    // Initialize repository and fetch data
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
      _fetchInstallments();
    }
  }

  Map<String, dynamic> _calculateInstallmentSummary() {
    double totalAmount = _installments.fold(0, (sum, installment) => sum + installment.totalAmount);
    double remainingAmount = _installments.fold(0, (sum, installment) => sum + installment.remainingAmount);
    int overdueCount = _installments.where((installment) => installment.isOverdue).length;
    int activeCount = _installments.where((installment) => installment.isActive).length;
    
    return {
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'overdueCount': overdueCount,
      'activeCount': activeCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with slight transparency
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: isDark 
                  ? Colors.black.withOpacity(0.7) 
                  : Colors.white.withOpacity(0.9),
              elevation: 0,
              title: const Text(
                'Installments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    LucideIcons.calendarDays,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  onPressed: _showDateRangeDialog,
                  tooltip: 'Filter by date',
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.barChart2,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  onPressed: () {
                    // Show installment analytics
                  },
                  tooltip: 'Analytics',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  width: double.infinity,
                  height: 1,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date filter chip
                    if (_startDate != null && _endDate != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              deleteIcon: const Icon(
                                LucideIcons.x,
                                size: 16,
                                color: AppTheme.mkbhdRed,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                                _fetchInstallments();
                              },
                              backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50), // More rounded like Meta's design
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Search bar with modern design
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50), // More rounded
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CustomSearchBar(
                        controller: _searchController,
                        hintText: 'Search installments...',
                        onSearch: _onSearch,
                        borderRadius: 50, // Make sure CustomSearchBar accepts this param
                      ),
                    ),

                    // Status filters with modern pill design
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildStatusPill('All', null, 0),
                          _buildStatusPill('Active', 'active', 8),
                          _buildStatusPill('Completed', 'completed', 8),
                          _buildStatusPill('Defaulted', 'defaulted', 8),
                        ],
                      ),
                    ),

                    // Installments summary with modern card design
                    if (!_isLoading && !_hasError && _installments.isNotEmpty)
                      _buildInstallmentSummary(),
                  ],
                ),
              ),
            ),

            // Installments list
            SliverFillRemaining(
              child: _buildInstallmentsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: 1.0,
        child: FloatingActionButton.extended(
          backgroundColor: AppTheme.mkbhdRed,
          foregroundColor: Colors.white,
          elevation: 4,
          onPressed: () => context.push('/installments/add'),
          icon: const Icon(LucideIcons.plus),
          label: const Text(
            'New Installment',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, String? status, double leftMargin) {
    final isSelected = _selectedStatus == status;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.only(left: leftMargin),
      child: InkWell(
        onTap: () => _onStatusSelected(status),
        borderRadius: BorderRadius.circular(50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.mkbhdRed 
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(50),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.mkbhdRed.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstallmentSummary() {
    final summary = _calculateInstallmentSummary();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.mkbhdRed.withOpacity(0.05),
            AppTheme.mkbhdRed.withOpacity(0.15),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Value',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.mkbhdLightGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: 'TSh ').format(summary['totalAmount']),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.mkbhdRed,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Outstanding',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.mkbhdLightGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: 'TSh ').format(summary['remainingAmount']),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildStatChip(
                  'Active',
                  summary['activeCount'].toString(),
                  Colors.green,
                  flex: 1,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  'Overdue',
                  summary['overdueCount'].toString(),
                  Colors.red,
                  flex: 1,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  'Total',
                  _installments.length.toString(),
                  AppTheme.mkbhdRed,
                  flex: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color, {int flex = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? color.withOpacity(0.8) : color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentsList() {
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
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _errorMessage ?? 'An error occurred while loading installments',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchInstallments,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.mkbhdRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_installments.isEmpty) {
      return Center(
        child: EmptyState(
          icon: LucideIcons.fileText,
          title: 'No Installment Plans Found',
          message: 'Create your first installment plan to manage customer payments over time.',
          buttonText: 'Create Installment Plan',
          onButtonPressed: () => context.push('/installments/add'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _installments.length,
      itemBuilder: (context, index) {
        return InstallmentCard(
          installment: _installments[index],
          onTap: () => context.push('/installments/${_installments[index].id}'),
        );
      },
    );
  }
}

class InstallmentCard extends StatelessWidget {
  final InstallmentModel installment;
  final VoidCallback onTap;
  
  const InstallmentCard({
    Key? key,
    required this.installment,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Meta-styled card
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client avatar
                    CircleAvatar(
                      backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                      radius: 24,
                      child: Text(
                        installment.clientName.isNotEmpty ? 
                          installment.clientName[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          color: AppTheme.mkbhdDarkGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Client info and amount
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            installment.clientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            installment.clientPhone,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due: ${installment.formattedDueDate}',
                            style: TextStyle(
                              color: installment.isOverdue ? 
                                Colors.red : Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(installment).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(installment).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        _getStatusText(installment),
                        style: TextStyle(
                          color: _getStatusColor(installment),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Payment progress section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Progress',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${installment.percentagePaid.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: installment.paymentProgress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          installment.isOverdue ? Colors.orange : AppTheme.mkbhdRed,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Amount information with Meta styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountInfo(
                          'Total',
                          installment.formattedTotalAmount,
                          Colors.grey.shade700
                        ),
                        _buildAmountInfo(
                          'Paid',
                          installment.formattedPaidAmount,
                          Colors.green.shade700
                        ),
                        _buildAmountInfo(
                          'Remaining',
                          installment.formattedRemainingAmount,
                          installment.isOverdue ? Colors.red : AppTheme.mkbhdRed
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Actions with Meta styling
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MetaActionButton(
                      text: 'View Details',
                      icon: LucideIcons.arrowRight,
                      onPressed: onTap,
                    ),
                    const SizedBox(width: 8),
                    MetaActionButton(
                      text: 'Add Payment',
                      icon: LucideIcons.plus,
                      onPressed: () {
                        // Navigate to add payment screen
                        context.push('/installments/${installment.id}/add-payment');
                      },
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
  
  Widget _buildAmountInfo(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
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
