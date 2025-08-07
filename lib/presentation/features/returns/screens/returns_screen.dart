import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/returns_service.dart';
import '../providers/returns_provider.dart';
import '../../../common/widgets/custom_search_bar.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../../core/di/service_locator.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({Key? key}) : super(key: key);

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ReturnModel> _returns = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  late ReturnsProvider _provider;
  
  @override
  void initState() {
    super.initState();
    // We need to delay the initialization until after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProvider();
      _fetchReturns();
    });
  }
  
  void _initProvider() {
    try {
      // Try to get the provider from the context first
      _provider = Provider.of<ReturnsProvider>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance
      _provider = locator<ReturnsProvider>();
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchReturns() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Use the provider to load returns
      await _provider.loadReturns(
        refresh: true,
        status: _selectedStatus,
        customerName: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      
      if (mounted) {
        setState(() {
          _returns = _provider.returns;
          _isLoading = false;
          _hasError = _provider.error != null;
          _errorMessage = _provider.error;
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
    _fetchReturns();
  }
  
  void _onStatusSelected(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _fetchReturns();
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
      _fetchReturns();
    }
  }
  
  // Calculate total amount of returns
  double get _totalReturnsAmount => 
      _returns.fold(0, (total, returnItem) => total + returnItem.totalAmount);
  
  @override
  Widget build(BuildContext context) {
    // Get AppLocalizations without immediately using non-existent properties
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        // Use a string literal instead of accessing non-existent property
        title: const Text('Returns'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarDays),
            onPressed: _showDateRangeDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: const Icon(LucideIcons.barChart2),
            onPressed: () {
              // Show returns analytics
            },
            tooltip: 'Analytics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date filter chip
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(
                      LucideIcons.x,
                      size: 16,
                    ),
                    onDeleted: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _fetchReturns();
                    },
                    backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                    deleteIconColor: AppTheme.mkbhdRed,
                    labelStyle: const TextStyle(color: AppTheme.mkbhdRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: l10n?.search ?? 'Search',
              onSearch: _onSearch,
            ),
          ),
          
          // Status filters
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                FilterChip(
                  label: Text(l10n?.all ?? 'All'),
                  selected: _selectedStatus == null,
                  selectedColor: AppTheme.mkbhdRed,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedStatus == null ? Colors.white : null,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _onStatusSelected(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedStatus == 'pending',
                  selectedColor: AppTheme.mkbhdRed,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'pending' ? Colors.white : null,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _onStatusSelected('pending');
                    } else {
                      _onStatusSelected(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Approved'),
                  selected: _selectedStatus == 'approved',
                  selectedColor: AppTheme.mkbhdRed,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'approved' ? Colors.white : null,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _onStatusSelected('approved');
                    } else {
                      _onStatusSelected(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Rejected'),
                  selected: _selectedStatus == 'rejected',
                  selectedColor: AppTheme.mkbhdRed,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'rejected' ? Colors.white : null,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _onStatusSelected('rejected');
                    } else {
                      _onStatusSelected(null);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Returns summary
          if (!_isLoading && !_hasError && _returns.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.grey.shade800
                    : AppTheme.mkbhdRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode 
                      ? Colors.grey.shade700
                      : AppTheme.mkbhdRed.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total Returns
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Returns',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TSh ${NumberFormat('#,###').format(_totalReturnsAmount)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ],
                  ),
                  
                  // Return Count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Number of Returns',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_returns.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Returns list
          Expanded(
            child: _buildReturnsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => context.push('/returns/add'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Process Return'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
  
  Widget _buildReturnsList() {
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => const TransactionCardShimmer(),
      );
    }
    
    if (_hasError) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load returns',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'An error occurred',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchReturns,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                // Use a string literal or try to access a valid property with fallback
                child: Text(l10n?.retry ?? 'Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_returns.isEmpty) {
      return EmptyState(
        icon: LucideIcons.refreshCcw,
        title: 'No Returns Found',
        message: 'Process a product return to track customer returns and refunds.',
        // Use a string literal instead of accessing non-existent property
        buttonText: 'Process Return',
        onButtonPressed: () => context.push('/returns/add'),
      );
    }
    
    // Group returns by date
    final groupedReturns = <String, List<ReturnModel>>{};
    for (final returnItem in _returns) {
      final key = DateFormat('MMMM yyyy').format(returnItem.dateTime);
      if (groupedReturns.containsKey(key)) {
        groupedReturns[key]!.add(returnItem);
      } else {
        groupedReturns[key] = [returnItem];
      }
    }
    
    return RefreshIndicator(
      onRefresh: _fetchReturns,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: groupedReturns.length,
        itemBuilder: (context, index) {
          final monthYear = groupedReturns.keys.elementAt(index);
          final returns = groupedReturns[monthYear]!;
          final totalForMonth = returns.fold<double>(
            0, (sum, returnItem) => sum + returnItem.totalAmount
          );
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      monthYear,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total: TSh ${NumberFormat('#,###').format(totalForMonth)}',
                      style: const TextStyle(
                        color: AppTheme.mkbhdRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...returns.map((returnItem) => ReturnCard(
                returnData: returnItem,
                onTap: () => context.push('/returns/${returnItem.id}'),
              )),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}

class ReturnCard extends StatelessWidget {
  final ReturnModel returnData;
  final VoidCallback onTap;
  
  const ReturnCard({
    Key? key,
    required this.returnData,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode 
              ? Colors.grey.shade700
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Return ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Return #${returnData.id.split('-').last}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              
              // Order ID reference
              Row(
                children: [
                  const Icon(
                    LucideIcons.shoppingBag,
                    size: 16,
                    color: AppTheme.mkbhdLightGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Order #${returnData.originalSaleId.split('-').last}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Customer info
              Row(
                children: [
                  const Icon(
                    LucideIcons.user,
                    size: 16,
                    color: AppTheme.mkbhdLightGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    returnData.customerName,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Return reason
              Row(
                children: [
                  const Icon(
                    LucideIcons.info,
                    size: 16,
                    color: AppTheme.mkbhdLightGrey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Reason: ${returnData.reason}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Return items summary
              Text(
                'Returned Items (${returnData.items.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              
              // Display first item or a summary
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.grey.shade800 
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.package,
                      size: 20,
                      color: isDarkMode 
                          ? Colors.grey.shade400 
                          : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            returnData.items.first.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            returnData.items.first.reason,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode 
                                  ? Colors.grey.shade400 
                                  : Colors.grey.shade700,
                            ),
                            maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'x${returnData.items.first.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Show indication of more items
              if (returnData.items.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '+ ${returnData.items.length - 1} more items',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode 
                          ? Colors.grey.shade400 
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              
              const Divider(height: 24),
              
              // Footer with amount and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Return Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TSh ${NumberFormat('#,###').format(returnData.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
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
                        'Return Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM yyyy').format(returnData.dateTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode 
                              ? Colors.grey.shade400 
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor() {
    switch (returnData.status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  String _getStatusText() {
    // Capitalize first letter
    return returnData.status.isNotEmpty 
        ? returnData.status[0].toUpperCase() + returnData.status.substring(1)
        : '';
  }
  
  IconData _getStatusIcon() {
    switch (returnData.status.toLowerCase()) {
      case 'approved':
        return LucideIcons.checkCircle;
      case 'pending':
        return LucideIcons.clock;
      case 'rejected':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.helpCircle;
    }
  }
}
