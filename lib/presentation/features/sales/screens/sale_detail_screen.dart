import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer; // Add this import for logging

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../models/sale_model.dart';
import '../repositories/sales_repository.dart';
import '../repositories/sales_repository_impl.dart' as impl;
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/loading_widget.dart';

class SaleDetailScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailScreen({
    super.key,
    required this.saleId,
  });

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _hasError = false;
  SaleModel? _sale;
  String? _errorMessage;
  late SalesRepository _repository; // Change to late and remove nullable

  @override
  void initState() {
    super.initState();
    // Initialize repository after the widget is inserted in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchSaleDetails();
    });
  }

  // Add this method to safely initialize repository
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<SalesRepository>(context, listen: false);
      developer.log('SalesRepository obtained from Provider',
          name: 'SaleDetailScreen');
    } catch (e) {
      // If provider not found, create a local instance with default API client
      developer.log('SalesRepository not found in Provider, creating local instance',
          name: 'SaleDetailScreen', error: e.toString());
      final apiClient = ApiClient();
      _repository = impl.SalesRepositoryImpl(apiClient);
    }
  }

  Future<void> _fetchSaleDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      developer.log('Fetching sale with ID: ${widget.saleId}',
          name: 'SaleDetailScreen');

      // Ensure repository is initialized before use
      if (_repository == null) {
        developer.log('Repository was null, initializing now',
            name: 'SaleDetailScreen');
        _initRepository();
      }

      // Use the initialized repository to get sale by ID
      final sale = await _repository.getSaleById(widget.saleId);
      developer.log('Sale fetched successfully: ${sale.id}',
          name: 'SaleDetailScreen');

      if (mounted) {
        setState(() {
          _sale = sale;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      // Enhanced error logging with stack trace
      developer.log(
          'Error fetching sale details',
          name: 'SaleDetailScreen',
          error: e.toString(),
          stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load sale: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _handleUpdateStatus(String newStatus) async {
    try {
      setState(() {
        _isUpdating = true;
      });

      // Use _repository directly instead of trying to get it from Provider
      final updatedSale = await _repository.updateSale(
        id: widget.saleId,
        status: newStatus,
      );

      if (mounted) {
        setState(() {
          _sale = updatedSale;
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteSale() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text(
            'Are you sure you want to delete this sale? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isUpdating = true;
      });

      // Use _repository directly instead of trying to get it from Provider
      await _repository.deleteSale(widget.saleId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete sale: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Enhanced loading UI with skeleton/shimmer effect
      return Scaffold(
        appBar: AppBar(
          title: const Text("Sale Details"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sale info card skeleton - Fix: Remove fixed height constraint
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Use min size to prevent overflow
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLoadingLine(width: 120),
                                const SizedBox(height: 16),
                                _buildLoadingLine(width: 180),
                                const SizedBox(height: 8),
                                _buildLoadingLine(width: 160),
                                const SizedBox(height: 8),
                                _buildLoadingLine(width: 140),
                              ],
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Items section skeleton
              _buildLoadingLine(width: 80, height: 22),
              const SizedBox(height: 16),

              // Fix: Remove fixed height constraint in second card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Use min size to prevent overflow
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child:
                                  _buildLoadingLine(width: double.infinity, height: 16)),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: _buildLoadingLine(width: 50, height: 16)),
                          const SizedBox(width: 16),
                          Expanded(flex: 3, child: _buildLoadingLine(width: 60, height: 16)),
                        ],
                      ),
                      const Divider(height: 24),

                      // Generate 3 skeleton items (reduced from original to avoid overflow)
                      for (int i = 0; i < 2; i++) ...[
                        Row(
                          children: [
                            Expanded(
                                flex: 5,
                                child:
                                    _buildLoadingLine(width: double.infinity, height: 16)),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: _buildLoadingLine(width: 50, height: 16)),
                            const SizedBox(width: 16),
                            Expanded(flex: 3, child: _buildLoadingLine(width: 60, height: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      const Divider(height: 24),

                      // Totals
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLoadingLine(width: 80, height: 16),
                          _buildLoadingLine(width: 100, height: 16),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLoadingLine(width: 60, height: 20),
                          _buildLoadingLine(width: 100, height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Sale Details"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  "Error Loading Sale",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? "Unknown Error",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Debug info for developer testing
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Debug Info:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("Sale ID: ${widget.saleId}"),
                        Text("Repository initialized: ${_repository != null}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                CustomButton(
                  text: "Try Again",
                  onPressed: () {
                    // Re-initialize repository before retrying
                    _initRepository();
                    _fetchSaleDetails();
                  },
                  icon: Icons.refresh,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sale = _sale!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale Details"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'update') {
                // Show dialog to update status
                _showUpdateStatusDialog();
              } else if (value == 'delete') {
                _handleDeleteSale();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'update',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text("Update Status"),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isUpdating
          ? const Center(child: LoadingWidget())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sale information
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.mkbhdLightGrey.withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sale Info',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(sale.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(sale.status),
                                  style: TextStyle(
                                    color: _getStatusColor(sale.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Date', sale.dateTime.toString()),
                          if (sale.customerName != null)
                            _buildInfoRow('Customer', sale.customerName!),
                          if (sale.customerPhone != null)
                            _buildInfoRow('Phone', sale.customerPhone!),
                          if (sale.paymentMethod != null)
                            _buildInfoRow('Payment Method', sale.paymentMethod!),
                          if (sale.note != null && sale.note!.isNotEmpty)
                            _buildInfoRow('Note', sale.note!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Items List
                  Text(
                    'Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Fix: Replace ListView.builder with Column to avoid nested scrolling issues
                  Column(
                    children: List.generate(sale.items.length, (index) {
                      final item = sale.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Increased border radius
                          side: BorderSide(
                            color: AppTheme.mkbhdLightGrey.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'TSh ${item.price.toStringAsFixed(0)} × ${item.quantity}',
                                      style: const TextStyle(
                                        color: AppTheme.mkbhdLightGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'TSh ${item.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Summary
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Increased border radius
                    ),
                    color: AppTheme.mkbhdDarkGrey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                'TSh ${(sale.totalAmount + sale.discount).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (sale.discount > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Discount',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '- TSh ${sale.discount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Divider(color: Colors.white30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'TSh ${sale.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Add some padding at the bottom for better UX
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Completed'),
              onTap: () {
                Navigator.of(context).pop();
                _handleUpdateStatus('completed');
              },
            ),
            ListTile(
              title: const Text('Pending'),
              onTap: () {
                Navigator.of(context).pop();
                _handleUpdateStatus('pending');
              },
            ),
            ListTile(
              title: const Text('Cancelled'),
              onTap: () {
                Navigator.of(context).pop();
                _handleUpdateStatus('cancelled');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.mkbhdLightGrey,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    // Capitalize first letter
    return status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : '';
  }

  // Helper methods for modern loading UI - Modified to remove fixed heights
  Widget _buildLoadingLine({required double width, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: _buildShimmerEffect(),
    );
  }

  Widget _buildShimmerEffect() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: const [0.1, 0.3, 0.4],
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      child: Container(
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}
