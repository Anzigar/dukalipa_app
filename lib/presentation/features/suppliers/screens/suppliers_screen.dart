import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../models/supplier_model.dart';
import '../repositories/supplier_repository.dart';
import '../../../common/widgets/custom_search_bar.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../common/widgets/empty_state.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SupplierModel> _suppliers = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;
  late SupplierRepository _repository;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchSuppliers();
    });
  }
  
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<SupplierRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance with default API client
      final apiClient = ApiClient();
      _repository = SupplierRepositoryImpl(apiClient);
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchSuppliers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final suppliers = await _repository.getSuppliers(
        search: _searchController.text,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      if (mounted) {
        setState(() {
          _suppliers = suppliers;
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
    _fetchSuppliers();
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
      _fetchSuppliers();
    }
  }
  
  double get _totalOrders => 
    _suppliers.fold(0, (total, supplier) => total + supplier.totalOrders);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarDays),
            onPressed: _showDateRangeDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: const Icon(LucideIcons.barChart2),
            onPressed: () {
              // Show supplier analytics
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
                      _fetchSuppliers();
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
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search suppliers',
              onSearch: _onSearch,
            ),
          ),
          
          // Suppliers summary
          if (!_isLoading && !_hasError && _suppliers.isNotEmpty)
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
                        'Total Suppliers',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_suppliers.length}',
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
                        'Total Orders',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TSh ${NumberFormat('#,###').format(_totalOrders)}',
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
          
          // Suppliers list
          Expanded(
            child: _buildSuppliersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/suppliers/add'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Supplier'),
      ),
    );
  }
  
  Widget _buildSuppliersList() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
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
              _errorMessage ?? 'An error occurred while loading suppliers',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchSuppliers,
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
    
    if (_suppliers.isEmpty) {
      return EmptyState(
        icon: LucideIcons.truck,
        title: 'No Suppliers Found',
        message: 'Add your first supplier to start tracking your supply chain',
        buttonText: 'Add Supplier',
        onButtonPressed: () => context.push('/suppliers/add'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchSuppliers,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _suppliers.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final supplier = _suppliers[index];
          return SupplierCard(
            supplier: supplier,
            onTap: () => context.push('/suppliers/${supplier.id}'),
          );
        },
      ),
    );
  }
}

class SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback onTap;
  
  const SupplierCard({
    super.key,
    required this.supplier,
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
              // Supplier avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                child: Text(
                  supplier.initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mkbhdRed,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Supplier details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.user,
                          size: 16,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          supplier.contactName,
                          style: TextStyle(
                            color: isDarkMode 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
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
                          supplier.phoneNumber,
                          style: TextStyle(
                            color: isDarkMode 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Order info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    supplier.formattedTotalOrders,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mkbhdRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${supplier.orderCount} orders',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode 
                          ? Colors.grey.shade400 
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last: ${supplier.formattedLastOrderDate}',
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
