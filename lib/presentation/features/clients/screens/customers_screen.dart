import 'package:dukalipa_app/presentation/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import '../../../common/widgets/material3_search_bar.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../../../common/widgets/empty_state.dart';

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
      // Try to get the repository from the provider first
      _repository = Provider.of<CustomerRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance
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
      _fetchCustomers();
    }
  }
  
  double get _totalPurchases => 
    _customers.fold(0, (total, customer) => total + customer.totalPurchases);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarDays),
            onPressed: _showDateRangeDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: const Icon(LucideIcons.barChart2),
            onPressed: () {
              // Show customer analytics
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
                    deleteIcon: const Icon(LucideIcons.x, size: 16),
                    onDeleted: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _fetchCustomers();
                    },
                    backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                    deleteIconColor: AppTheme.mkbhdRed,
                    labelStyle: const TextStyle(color: AppTheme.mkbhdRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          
          // Material 3 Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material3SearchBar(
              controller: _searchController,
              onChanged: (query) => _onSearch(query),
              hintText: 'Search customers',
            ),
          ),
          
          // Customers summary
          if (!_isLoading && !_hasError && _customers.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Customers',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_customers.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Purchases',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TSh ${NumberFormat('#,###').format(_totalPurchases)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Customers list
          Expanded(
            child: _buildCustomersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/customers/add'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Customer'),
      ),
    );
  }
  
  Widget _buildCustomersList() {
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
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred while loading customers',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchCustomers,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.mkbhdRed,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_customers.isEmpty) {
      return EmptyState(
        icon: LucideIcons.users,
        title: 'No Customers Found',
        message: 'Add your first customer to start tracking your sales more effectively',
        buttonText: 'Add Customer',
        onButtonPressed: () => context.push('/customers/add'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchCustomers,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _customers.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return CustomerCard(
            customer: customer,
            onTap: () => context.push('/customers/${customer.id}'),
          );
        },
      ),
    );
  }
}

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;
  
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
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
          child: Row(
            children: [
              // Customer avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                child: Text(
                  customer.initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mkbhdRed,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Customer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.phone,
                          size: 16,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.phoneNumber,
                          style: TextStyle(
                            color: isDarkMode 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (customer.email != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.mail,
                            size: 16,
                            color: AppTheme.mkbhdLightGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer.email!,
                            style: TextStyle(
                              color: isDarkMode 
                                  ? Colors.grey.shade400 
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Purchase info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    customer.formattedTotalPurchases,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mkbhdRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${customer.purchaseCount} purchases',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode 
                          ? Colors.grey.shade400 
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last: ${customer.formattedLastPurchaseDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode 
                          ? Colors.grey.shade400 
                          : Colors.grey.shade600,
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
}
