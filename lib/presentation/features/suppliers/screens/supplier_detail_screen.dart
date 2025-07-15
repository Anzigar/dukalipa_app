import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/supplier_model.dart';
import '../repositories/supplier_repository.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../common/widgets/custom_button.dart';

class SupplierDetailScreen extends StatefulWidget {
  final String supplierId;
  
  const SupplierDetailScreen({
    Key? key,
    required this.supplierId,
  }) : super(key: key);

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  SupplierModel? _supplier;
  late SupplierRepository _repository;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchSupplier();
    });
  }
  
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<SupplierRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance
      _repository = SupplierRepositoryImpl();
    }
  }
  
  Future<void> _fetchSupplier() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final supplier = await _repository.getSupplierById(widget.supplierId);
      
      if (mounted) {
        setState(() {
          _supplier = supplier;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit2),
            onPressed: _supplier != null ? () => _editSupplier() : null,
            tooltip: 'Edit Supplier',
          ),
        ],
      ),
      body: _buildContent(isDarkMode),
      floatingActionButton: _supplier != null ? FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/add', extra: {'supplier': _supplier}),
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Order'),
      ) : null,
    );
  }
  
  Widget _buildContent(bool isDarkMode) {
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
              _errorMessage ?? 'An error occurred while loading supplier details',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchSupplier,
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
    
    if (_supplier == null) {
      return const Center(
        child: Text('Supplier not found'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Supplier header with avatar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.mkbhdRed.withOpacity(0.3),
                  child: Text(
                    _supplier!.initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mkbhdRed,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _supplier!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.user,
                            size: 16,
                            color: AppTheme.mkbhdRed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _supplier!.contactName,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
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
                            color: AppTheme.mkbhdRed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _supplier!.phoneNumber,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (_supplier!.email != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.mail,
                              size: 16,
                              color: AppTheme.mkbhdRed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _supplier!.email!,
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
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
          
          const SizedBox(height: 24),
          
          // Order summary cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Total Orders',
                  value: _supplier!.formattedTotalOrders,
                  icon: LucideIcons.shoppingCart,
                  color: AppTheme.mkbhdRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  label: 'Order Count',
                  value: _supplier!.orderCount.toString(),
                  icon: LucideIcons.clipboardCheck,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Last Order',
                  value: _supplier!.formattedLastOrderDate,
                  icon: LucideIcons.calendar,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  label: 'Supplier Since',
                  value: DateFormat('MMM yyyy').format(_supplier!.createdAt),
                  icon: LucideIcons.truck,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Supplier details section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supplier Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow('Company Name', _supplier!.name),
                  _buildDetailRow('Contact Person', _supplier!.contactName),
                  _buildDetailRow('Phone', _supplier!.phoneNumber),
                  if (_supplier!.email != null)
                    _buildDetailRow('Email', _supplier!.email!),
                  if (_supplier!.address != null)
                    _buildDetailRow('Address', _supplier!.address!),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent orders section
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentOrders(),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'View All Orders',
                  icon: LucideIcons.shoppingBag,
                  onPressed: () => context.push('/suppliers/${_supplier!.id}/orders'),
                  backgroundColor: Colors.white,
                  textColor: AppTheme.mkbhdRed,
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Delete Supplier',
                  icon: LucideIcons.trash2,
                  onPressed: () => _showDeleteConfirmation(),
                  backgroundColor: Colors.transparent,
                  textColor: Colors.red,
                  borderColor: Colors.red,
                  isOutlined: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentOrders() {
    // In a real app, you would fetch and display real order data
    // Here we're using mock data for demonstration
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade700 
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3, // Showing only 3 most recent orders
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          // Mock order data
          final dates = [
            DateTime.now().subtract(const Duration(days: 5)),
            DateTime.now().subtract(const Duration(days: 15)),
            DateTime.now().subtract(const Duration(days: 30)),
          ];
          
          final amounts = [150000.0, 230000.0, 185000.0];
          final itemCounts = [8, 12, 6];
          
          return ListTile(
            title: Text('Order #${1000 + index}'),
            subtitle: Text('${itemCounts[index]} items'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TSh ${NumberFormat("#,###").format(amounts[index])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.mkbhdRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(dates[index]),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            onTap: () => context.push('/inventory/order/${1000 + index}'),
          );
        },
      ),
    );
  }
  
  void _editSupplier() {
    // Navigate to edit supplier screen
    context.push('/suppliers/edit/${_supplier!.id}');
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: const Text('Are you sure you want to delete this supplier? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSupplier();
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
  
  Future<void> _deleteSupplier() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _repository.deleteSupplier(widget.supplierId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier deleted successfully'),
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
            content: Text('Failed to delete supplier: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
