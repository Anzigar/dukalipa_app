import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../common/widgets/material3_search_bar.dart';

class DamagedProductsScreen extends StatefulWidget {
  const DamagedProductsScreen({super.key});

  @override
  State<DamagedProductsScreen> createState() => _DamagedProductsScreenState();
}

class _DamagedProductsScreenState extends State<DamagedProductsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<DamagedProduct> _damagedProducts = [];
  Set<String> _selectedStatus = {'all'}; // For segmented button
  
  @override
  void initState() {
    super.initState();
    _loadDamagedProducts();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDamagedProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API loading
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    setState(() {
      _damagedProducts = [
        DamagedProduct(
          id: '1',
          name: 'iPhone 13 Pro',
          sku: 'IP13-PRO-256',
          damageType: 'Screen Cracked',
          damageDate: DateTime.now().subtract(const Duration(days: 2)),
          quantity: 2,
          value: 1200.00,
          notes: 'Dropped during unpacking',
          status: 'Pending',
          imageUrl: 'https://example.com/image1.jpg',
        ),
        DamagedProduct(
          id: '2',
          name: 'Samsung Galaxy S21',
          sku: 'SAM-S21-128',
          damageType: 'Water Damage',
          damageDate: DateTime.now().subtract(const Duration(days: 5)),
          quantity: 1,
          value: 800.00,
          notes: 'Liquid spill on device',
          status: 'Processed',
          imageUrl: 'https://example.com/image2.jpg',
        ),
        DamagedProduct(
          id: '3',
          name: 'AirPods Pro',
          sku: 'APP-PRO-2',
          damageType: 'Battery Issue',
          damageDate: DateTime.now().subtract(const Duration(days: 1)),
          quantity: 3,
          value: 249.00,
          notes: 'Does not charge properly',
          status: 'Written Off',
          imageUrl: null,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Damaged Products'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Material 3 Segmented Button replacing TabBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'all',
                        label: Text('All'),
                        icon: Icon(Icons.list_rounded),
                      ),
                      ButtonSegment<String>(
                        value: 'pending',
                        label: Text('Pending'),
                        icon: Icon(Icons.schedule_rounded),
                      ),
                      ButtonSegment<String>(
                        value: 'processed',
                        label: Text('Processed'),
                        icon: Icon(Icons.check_circle_outline),
                      ),
                    ],
                    selected: _selectedStatus,
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedStatus = newSelection;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      foregroundColor: AppTheme.mkbhdLightGrey,
                      selectedBackgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                      selectedForegroundColor: AppTheme.mkbhdRed,
                      side: BorderSide(color: AppTheme.mkbhdLightGrey.withOpacity(0.2)),
                    ),
                  ),
                ),
                
                // Content based on selection
                Expanded(
                  child: _selectedStatus.contains('all')
                      ? _buildProductList(_damagedProducts)
                      : _selectedStatus.contains('pending')
                          ? _buildProductList(_damagedProducts.where((p) => p.status == 'Pending').toList())
                          : _buildProductList(_damagedProducts.where((p) => p.status == 'Processed' || p.status == 'Written Off').toList()),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddDamagedProductDialog();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report Damage'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  Widget _buildProductList(List<DamagedProduct> products) {
    if (products.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.inventory_2,
        title: 'No Damaged Products',
        description: 'There are no damaged products to display in this category.',
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadDamagedProducts,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _DamagedProductCard(
            product: product,
            onViewDetails: () {
              // Navigate to view details
              _showProductDetailsDialog(product);
            },
          );
        },
      ),
    );
  }
  
  void _showAddDamagedProductDialog() {
    final productSearchController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Report Damaged Product',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Document damaged inventory for tracking',
                      style: TextStyle(
                        color: AppTheme.mkbhdLightGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Material 3 Search Bar
                    Material3SearchBar(
                      controller: productSearchController,
                      onChanged: (query) {
                        // Handle search
                      },
                      hintText: 'Search products...',
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Damage Type',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.mkbhdLightGrey.withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.mkbhdRed,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.warning_amber_outlined),
                      ),
                      items: ['Screen Damage', 'Water Damage', 'Battery Issue', 'Physical Damage', 'Other']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Number of damaged units',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.mkbhdLightGrey.withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.mkbhdRed,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the damage...',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.mkbhdLightGrey.withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.mkbhdRed,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.notes),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.mkbhdRed.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.mkbhdRed.withOpacity(0.2),
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Add image functionality
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppTheme.mkbhdRed,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Add Photo Evidence',
                                  style: TextStyle(
                                    color: AppTheme.mkbhdRed,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.mkbhdRed.withOpacity(0.9),
                            AppTheme.mkbhdRed,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            // Handle save damaged product
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Save Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  void _showProductDetailsDialog(DamagedProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SKU: ${product.sku}'),
              const SizedBox(height: 8),
              Text('Damage Type: ${product.damageType}'),
              const SizedBox(height: 8),
              Text('Date: ${_formatDate(product.damageDate)}'),
              const SizedBox(height: 8),
              Text('Quantity: ${product.quantity}'),
              const SizedBox(height: 8),
              Text('Value: \$${product.value.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Status: ${product.status}'),
              const SizedBox(height: 16),
              Text('Notes: ${product.notes}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (product.status == 'Pending')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle processing damage report
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.mkbhdRed,
              ),
              child: const Text('Process'),
            ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DamagedProductCard extends StatelessWidget {
  final DamagedProduct product;
  final VoidCallback onViewDetails;

  const _DamagedProductCard({
    required this.product,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    switch (product.status) {
      case 'Pending':
        statusColor = Theme.of(context).colorScheme.secondary;
        statusBgColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
        break;
      case 'Processed':
        statusColor = Theme.of(context).colorScheme.primary;
        statusBgColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
        break;
      case 'Written Off':
        statusColor = Theme.of(context).colorScheme.tertiary;
        statusBgColor = Theme.of(context).colorScheme.tertiary.withOpacity(0.1);
        break;
      default:
        statusColor = Theme.of(context).colorScheme.outline;
        statusBgColor = Theme.of(context).colorScheme.outline.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 14,
                      color: AppTheme.mkbhdLightGrey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product.sku,
                      style: TextStyle(
                        color: AppTheme.mkbhdLightGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.mkbhdLightGrey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Damage Type',
                            style: TextStyle(
                              color: AppTheme.mkbhdLightGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.damageType,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppTheme.mkbhdLightGrey.withOpacity(0.2),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              color: AppTheme.mkbhdLightGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppTheme.mkbhdLightGrey.withOpacity(0.2),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Value',
                            style: TextStyle(
                              color: AppTheme.mkbhdLightGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.mkbhdRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppTheme.mkbhdLightGrey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(product.damageDate),
                      style: TextStyle(
                        color: AppTheme.mkbhdLightGrey,
                        fontSize: 13,
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
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class DamagedProduct {
  final String id;
  final String name;
  final String sku;
  final String damageType;
  final DateTime damageDate;
  final int quantity;
  final double value;
  final String notes;
  final String status;
  final String? imageUrl;

  DamagedProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.damageType,
    required this.damageDate,
    required this.quantity,
    required this.value,
    required this.notes,
    required this.status,
    this.imageUrl,
  });
}