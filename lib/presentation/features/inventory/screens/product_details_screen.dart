import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/product_model.dart';
import '../providers/inventory_provider.dart';
import '../../../common/widgets/shimmer_loading.dart';

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
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProduct();
    });
  }
  
  Future<void> _fetchProduct() async {
    final inventoryProvider = context.read<InventoryProvider>();
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final product = await inventoryProvider.getProductById(widget.productId);
      
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
          // Better error message for 404 errors
          if (e.toString().contains('404') || e.toString().contains('Not Found')) {
            _errorMessage = 'Product not found. It may have been deleted or moved.';
          } else {
            _errorMessage = 'Failed to load product: ${e.toString()}';
          }
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_product?.name ?? 'Product Details'),
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => context.pop(),
            ),
            actions: _product != null ? [
              IconButton(
                onPressed: () => _handleEditProduct(),
                icon: const Icon(LucideIcons.edit),
                tooltip: 'Edit Product',
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(LucideIcons.trash2),
                tooltip: 'Delete Product',
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(width: 8),
            ] : null,
          ),
          body: _buildContent(isDarkMode),
          bottomNavigationBar: _product != null ? _buildActionButtons() : null,
        );
      },
    );
  }
  
  void _handleEditProduct() {
    if (_product != null) {
      // Navigate to edit product page with current product data
      context.push('/inventory/add', extra: {'product': _product, 'isEditing': true});
    }
  }
  
  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleUpdateStock(),
                    icon: const Icon(LucideIcons.package, size: 18),
                    label: const Text('Update Stock'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _handleAddToSale(),
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text('Add to Sale'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Only one row of actions now
          ],
        ),
      ),
    );
  }
  
  void _handleUpdateStock() {
    if (_product != null) {
      _showUpdateStockDialog();
    }
  }

  void _showUpdateStockDialog() {
    final currentQuantity = _product!.quantity;
    final TextEditingController quantityController = TextEditingController(
      text: currentQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${_product!.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Current Stock: $currentQuantity',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Quantity',
                border: OutlineInputBorder(),
                helperText: 'Enter the new stock quantity',
              ),
              autofocus: true,
              onSubmitted: (value) {
                if (value.isNotEmpty && int.tryParse(value) != null) {
                  Navigator.of(context).pop();
                  _updateProductStock(int.parse(value));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity >= 0) {
                Navigator.of(context).pop();
                _updateProductStock(newQuantity);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProductStock(int newQuantity) async {
    final inventoryProvider = context.read<InventoryProvider>();
    
    setState(() {
      _isLoading = true;
    });

    try {
      await inventoryProvider.updateProductStock(
        widget.productId,
        newQuantity,
        reason: 'Stock updated via product details screen',
      );

      // Get the updated product from the provider
      final updatedProduct = await inventoryProvider.getProductById(widget.productId);

      if (mounted) {
        setState(() {
          _product = updatedProduct;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock updated to $newQuantity'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stock: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _handleAddToSale() {
    if (_product != null) {
      // Navigate to the add sale screen with this product pre-selected
      context.push('/sales/add', extra: {'product': _product});
    }
  }
  
  Widget _buildContent(bool isDarkMode) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        // Show provider loading state
        if ((inventoryProvider.isUpdatingProduct || inventoryProvider.isDeletingProduct) && !_isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Updating product...'),
              ],
            ),
          );
        }
        
        if (_isLoading) {
          return const ProductDetailsShimmer();
        }
        
        if (_hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _errorMessage!.contains('not found') 
                      ? LucideIcons.packageX 
                      : LucideIcons.alertTriangle,
                  size: 64,
                  color: _errorMessage!.contains('not found') 
                      ? Colors.grey 
                      : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'An error occurred while loading the product',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_errorMessage!.contains('not found'))
                      ElevatedButton.icon(
                        onPressed: _fetchProduct,
                        icon: const Icon(LucideIcons.refreshCw),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(LucideIcons.arrowLeft),
                      label: const Text('Go Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.mkbhdRed,
                      ),
                    ),
                  ],
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
        
        return _buildProductDetails(isDarkMode);
      },
    );
  }
  
  Widget _buildProductDetails(bool isDarkMode) {
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
                  
                  // IMEI/Serial Numbers List for products with many quantities
                  if (_product!.hasSerialNumber && _product!.quantity > 1) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Serial Numbers (${_product!.quantity})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _navigateToSerialNumbersPage(),
                          icon: const Icon(LucideIcons.list, size: 16),
                          label: const Text('View All'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 160, // Increased height to accommodate device variations
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: (_product!.quantity > 5 ? 5 : _product!.quantity),
                        itemBuilder: (context, index) {
                          // Generate sample IMEI/Serial numbers and device variations
                          final serialNumber = _generateSerialNumber(index);
                          final deviceVariation = _generateDeviceVariation(index);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Serial Number
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.hash,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        serialNumber,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Device Variations
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildVariationChip(
                                      label: deviceVariation['color']!,
                                      icon: LucideIcons.palette,
                                      color: _getColorForVariation(deviceVariation['color']!),
                                    ),
                                    _buildVariationChip(
                                      label: deviceVariation['storage']!,
                                      icon: LucideIcons.hardDrive,
                                      color: Colors.blue,
                                    ),
                                    _buildVariationChip(
                                      label: deviceVariation['condition']!,
                                      icon: LucideIcons.star,
                                      color: _getConditionColor(deviceVariation['condition']!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (_product!.quantity > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Showing 5 of ${_product!.quantity} serial numbers',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
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

  // Helper method to build variation chips
  Widget _buildVariationChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get color for device color variation
  Color _getColorForVariation(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black87;
      case 'white':
        return Colors.grey;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.blueGrey;
      case 'gray':
        return Colors.grey;
      case 'green':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  // Helper method to get color for condition
  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'used':
        return Colors.orange;
      case 'refurbished':
        return Colors.blue;
      default:
        return Colors.grey;
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
    final inventoryProvider = context.read<InventoryProvider>();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await inventoryProvider.deleteProduct(widget.productId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete product: ${inventoryProvider.deleteError ?? "Unknown error"}'),
              backgroundColor: AppTheme.mkbhdRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: ${e.toString()}'),
            backgroundColor: AppTheme.mkbhdRed,
          ),
        );
      }
    }
  }

  // Navigate to dedicated serial numbers page
  void _navigateToSerialNumbersPage() {
    if (_product != null) {
      context.push('/inventory/serial-numbers', extra: {
        'product': _product,
        'productId': widget.productId,
      });
    }
  }

  // Generate serial number for a product item
  String _generateSerialNumber(int index) {
    // Generate a realistic serial number based on product info
    final productPrefix = _product!.name.toUpperCase().replaceAll(' ', '').substring(0, 2);
    final categoryCode = _product!.category?.substring(0, 2).toUpperCase() ?? 'PR';
    final itemNumber = (index + 1).toString().padLeft(3, '0');
    final year = DateTime.now().year.toString().substring(2);
    final randomSuffix = (1000 + index * 37 + _product!.id.hashCode % 9000).toString();
    
    return '$productPrefix$categoryCode$year$itemNumber$randomSuffix';
  }

  // Generate device variations (color, storage, condition)
  Map<String, String> _generateDeviceVariation(int index) {
    final colors = ['Black', 'White', 'Blue', 'Red', 'Gold', 'Silver', 'Gray', 'Green'];
    final storages = ['64GB', '128GB', '256GB', '512GB', '1TB'];
    final conditions = ['Used', 'New', 'Refurbished']; // Realistic conditions for retail
    
    // Use index and product ID to generate consistent variations
    final colorIndex = (index + _product!.id.hashCode) % colors.length;
    final storageIndex = (index * 2 + _product!.id.hashCode) % storages.length;
    final conditionIndex = (index * 3 + _product!.id.hashCode) % conditions.length;
    
    return {
      'color': colors[colorIndex],
      'storage': storages[storageIndex],
      'condition': conditions[conditionIndex],
    };
  }
}
