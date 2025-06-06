import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../repositories/inventory_repository.dart';
import '../../../common/widgets/loading_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  
  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  ProductModel? _product;
  late InventoryRepository _repository;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchProduct();
    });
  }
  
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<InventoryRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance with default API client
      final apiClient = ApiClient();
      _repository = InventoryRepositoryImpl(apiClient);
    }
  }
  
  Future<void> _fetchProduct() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final product = await _repository.getProductById(widget.productId);
      
      if (mounted) {
        setState(() {
          _product = product;
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
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: () {
              // Navigate to edit product page
              // context.push('/inventory/edit/${widget.productId}');
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: _buildContent(isDarkMode),
      floatingActionButton: _product != null ? FloatingActionButton.extended(
        onPressed: () {
          // Navigate to the add sale screen with this product pre-selected
          // context.push('/sales/add?productId=${widget.productId}');
        },
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add to Sale'),
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
              _errorMessage ?? 'An error occurred while loading the product',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchProduct,
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
    
    if (_product == null) {
      return const Center(
        child: Text('Product not found'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          if (_product!.imageUrl != null && _product!.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _product!.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,  // Fix: Change 'fit' to 'BoxFit.cover'
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      LucideIcons.image,
                      size: 64,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.package,
                  size: 64,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
            
          const SizedBox(height: 24),
          
          // Product Details
          Text(
            _product!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          if (_product!.category != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.mkbhdRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _product!.category!,
                style: const TextStyle(
                  color: AppTheme.mkbhdRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Price Information
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  title: 'Selling Price',
                  value: 'TSh ${NumberFormat('#,###').format(_product!.sellingPrice)}',
                  icon: LucideIcons.tag,
                  color: AppTheme.mkbhdRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  title: 'Cost Price',
                  value: 'TSh ${NumberFormat('#,###').format(_product!.costPrice)}',
                  icon: LucideIcons.receipt,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Inventory Information
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                width: 1,
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          title: 'In Stock',
                          value: '${_product!.quantity}',
                          icon: LucideIcons.package,
                          color: _getStockColor(_product!),
                        ),
                      ),
                      ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          title: 'Low Stock Alert',
                          value: '${_product!.lowStockThreshold}',
                          icon: LucideIcons.alertTriangle,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Inventory Value', 'TSh ${NumberFormat('#,###').format(_product!.inventoryValue)}'),
                  if (_product!.sku.isNotEmpty)
                    _buildDetailRow('SKU', _product!.sku),
                  _buildDetailRow('Created At', _product!.formattedCreatedAt),
                  _buildDetailRow('Last Updated', _product!.formattedUpdatedAt),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Product Additional Details
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                width: 1,
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_product!.sku.isNotEmpty)
                    _buildDetailRow('SKU', _product!.sku),
                  if (_product!.supplier != null && _product!.supplier!.isNotEmpty)
                    _buildDetailRow('Supplier', _product!.supplier!),
                  if (_product!.description != null && _product!.description!.isNotEmpty)
                    _buildDetailRow('Description', _product!.description!),
                  _buildDetailRow('Created', _product!.formattedCreatedAt),
                  _buildDetailRow('Last Updated', _product!.formattedUpdatedAt),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to update stock screen
                  },
                  icon: const Icon(LucideIcons.clipboardList),
                  label: const Text('Update Stock'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to add sale screen
                  },
                  icon: const Icon(LucideIcons.shoppingCart),
                  label: const Text('Add to Sale'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppTheme.mkbhdRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  // Fixed with named parameters to match how it's called in the code
  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.mkbhdLightGrey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
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
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey.shade400 
                    : Colors.grey.shade700,
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
  
  Color _getStockColor(ProductModel product) {
    if (product.isOutOfStock) {
      return Colors.red;
    } else if (product.isLowStock) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProduct();
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
  
  Future<void> _deleteProduct() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _repository.deleteProduct(widget.productId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
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
            content: Text('Failed to delete product: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
