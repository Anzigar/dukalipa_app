import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../common/widgets/custom_button.dart';

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
      // Try to get the repository from the provider first
      _repository = Provider.of<CustomerRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance with default API client
      final apiClient = ApiClient();
      _repository = CustomerRepositoryImpl(apiClient);
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit2),
            onPressed: _customer != null ? () => _editCustomer() : null,
            tooltip: 'Edit Customer',
          ),
        ],
      ),
      body: _buildContent(isDarkMode),
      floatingActionButton: _customer != null ? FloatingActionButton.extended(
        onPressed: () => context.push('/sales/add', extra: {'customer': _customer}),
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.shoppingCart),
        label: const Text('New Sale'),
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
              _errorMessage ?? 'An error occurred while loading customer details',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchCustomer,
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
    
    if (_customer == null) {
      return const Center(
        child: Text('Customer not found'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer header with avatar
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
                    _customer!.initials,
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
                        _customer!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                            _customer!.phoneNumber,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (_customer!.email != null) ...[
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
                              _customer!.email!,
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
              const SizedBox(width: 16),
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
          
          const SizedBox(height: 16),
          
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
              const SizedBox(width: 16),
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
          
          const SizedBox(height: 24),
          
          // Customer details section
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
                    'Customer Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow('Name', _customer!.name),
                  _buildDetailRow('Phone', _customer!.phoneNumber),
                  if (_customer!.email != null)
                    _buildDetailRow('Email', _customer!.email!),
                  if (_customer!.address != null)
                    _buildDetailRow('Address', _customer!.address!),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent purchases section
          const Text(
            'Recent Purchases',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentPurchases(),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'View All Purchases',
                  icon: LucideIcons.shoppingBag,
                  onPressed: () => context.push('/customers/${_customer!.id}/purchases'),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Delete Customer',
                  icon: LucideIcons.trash2,
                  onPressed: () => _showDeleteConfirmation(),
                  backgroundColor: Colors.red,
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
            width: 100,
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
  
  Widget _buildRecentPurchases() {
    // In a real app, you would fetch and display real purchase data
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
        itemCount: 3, // Showing only 3 most recent purchases
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          // Mock purchase data
          final dates = [
            DateTime.now().subtract(const Duration(days: 2)),
            DateTime.now().subtract(const Duration(days: 10)),
            DateTime.now().subtract(const Duration(days: 25)),
          ];
          
          final amounts = [25000.0, 35000.0, 48000.0];
          final itemCounts = [3, 5, 2];
          
          return ListTile(
            title: Text('Purchase #${1000 + index}'),
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
            onTap: () => context.push('/sales/${1000 + index}'),
          );
        },
      ),
    );
  }
  
  void _editCustomer() {
    // Navigate to edit customer screen
    context.push('/customers/edit/${_customer!.id}');
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
