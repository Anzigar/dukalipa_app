import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/inventory_service.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../../inventory/models/product_model.dart';

class StorageManagementScreen extends StatefulWidget {
  const StorageManagementScreen({super.key});

  @override
  State<StorageManagementScreen> createState() => _StorageManagementScreenState();
}

class _StorageManagementScreenState extends State<StorageManagementScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;
  final List<StorageLocation> _storageLocations = [];
  Set<String> _selectedView = {'locations'}; // For segmented button
  
  // Inventory data
  final InventoryService _inventoryService = InventoryService();
  List<ProductModel> _products = [];
  bool _isLoadingProducts = false;
  String? _inventoryError;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStorageData();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _inventoryError = null;
    });

    try {
      final products = await _inventoryService.getProducts();
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _inventoryError = e.toString();
        _isLoadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadStorageData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulated API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    setState(() {
      _storageLocations.addAll([
        StorageLocation(
          id: '1',
          name: 'Main Warehouse',
          address: '123 Main St, City',
          capacity: 500,
          usedCapacity: 340,
          itemCount: 248,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
          status: 'Active',
        ),
        StorageLocation(
          id: '2',
          name: 'Store Front',
          address: '456 Market Ave, City',
          capacity: 100,
          usedCapacity: 85,
          itemCount: 124,
          lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
          status: 'Active',
        ),
        StorageLocation(
          id: '3',
          name: 'Backup Storage',
          address: '789 Backup Lane, City',
          capacity: 200,
          usedCapacity: 50,
          itemCount: 42,
          lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
          status: 'Inactive',
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Storage Management'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? _buildMainLoadingShimmer()
          : Column(
              children: [
                // Material 3 Segmented Button replacing TabBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'locations',
                        label: Text('Locations'),
                        icon: Icon(Icons.location_on_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'inventory',
                        label: Text('Inventory'),
                        icon: Icon(Icons.inventory_2_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'transfers',
                        label: Text('Transfers'),
                        icon: Icon(Icons.swap_horiz_rounded),
                      ),
                    ],
                    selected: _selectedView,
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedView = newSelection;
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
                  child: _selectedView.contains('locations')
                      ? _buildLocationsTab()
                      : _selectedView.contains('inventory')
                          ? _buildInventoryTab()
                          : _buildTransfersTab(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddLocationDialog();
          } else if (_tabController.index == 1) {
            _showManageInventoryDialog();
          } else {
            _showCreateTransferDialog();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: Text(_tabController.index == 0 
            ? 'Add Location' 
            : _tabController.index == 1 
                ? 'Manage Stock' 
                : 'New Transfer'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  Widget _buildLocationsTab() {
    if (_storageLocations.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.warehouse_outlined,
        title: 'No Storage Locations',
        description: 'Add your first storage location to start managing inventory.',
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadStorageData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _storageLocations.length,
        itemBuilder: (context, index) {
          final location = _storageLocations[index];
          return _StorageLocationCard(
            location: location,
            onTap: () => _showLocationDetailsDialog(location),
          );
        },
      ),
    );
  }
  
  Widget _buildInventoryTab() {
    return Column(
      children: [
        // Header with refresh button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inventory Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: _loadProducts,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.mkbhdRed,
                ),
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: _isLoadingProducts
              ? _buildInventoryShimmer()
              : _inventoryError != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _inventoryError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.mkbhdLightGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadProducts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _products.isEmpty
                      ? _buildEmptyInventoryState()
                      : _buildProductsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyInventoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.mkbhdLightGrey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.mkbhdLightGrey.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding products to your inventory',
            style: TextStyle(
              color: AppTheme.mkbhdLightGrey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.mkbhdLightGrey.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(product).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: _getStatusColor(product),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (product.category != null)
              Text(
                product.category!,
                style: TextStyle(
                  color: AppTheme.mkbhdLightGrey,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(product),
                const SizedBox(width: 8),
                Text(
                  'Qty: ${product.quantity}',
                  style: TextStyle(
                    color: AppTheme.mkbhdLightGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'TSh ${_formatPrice(product.sellingPrice)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stock Value: TSh ${_formatPrice(product.inventoryValue)}',
              style: TextStyle(
                color: AppTheme.mkbhdLightGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to product details
        },
      ),
    );
  }

  Widget _buildStatusChip(ProductModel product) {
    String status;
    Color color;

    if (product.isOutOfStock) {
      status = 'Out of Stock';
      color = Theme.of(context).colorScheme.error;
    } else if (product.isLowStock) {
      status = 'Low Stock';
      color = Theme.of(context).colorScheme.secondary;
    } else {
      status = 'In Stock';
      color = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(ProductModel product) {
    if (product.isOutOfStock) {
      return Theme.of(context).colorScheme.error;
    } else if (product.isLowStock) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    } else {
      return price.toStringAsFixed(0);
    }
  }
  
  Widget _buildTransfersTab() {
    return const Center(
      child: Text('Inventory transfers tab content'),
    );
  }
  
  // Shimmer loading widgets
  Widget _buildMainLoadingShimmer() {
    return Column(
      children: [
        // Segmented button shimmer
        Padding(
          padding: const EdgeInsets.all(16),
          child: ShimmerLoading(
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        // Content shimmer based on current view
        Expanded(
          child: _selectedView.contains('locations')
              ? _buildStorageLocationsShimmer()
              : _selectedView.contains('inventory')
                  ? _buildInventoryShimmer()
                  : _buildTransfersShimmer(),
        ),
      ],
    );
  }

  Widget _buildInventoryShimmer() {
    return Column(
      children: [
        // Header shimmer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(
                child: Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              ShimmerLoading(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Product cards shimmer
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => _buildProductCardShimmer(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCardShimmer() {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Leading icon placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            // Content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 12,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Trailing price placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 16,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageLocationsShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: 4,
      itemBuilder: (context, index) => _buildStorageLocationCardShimmer(),
    );
  }

  Widget _buildStorageLocationCardShimmer() {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 17,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 14,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 15,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 15,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransfersShimmer() {
    return Center(
      child: ShimmerLoading(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddLocationDialog() {
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
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
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
                      'Add Storage Location',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new storage location for your inventory',
                      style: TextStyle(
                        color: AppTheme.mkbhdLightGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Location Name',
                        hintText: 'e.g., Main Warehouse',
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
                        prefixIcon: const Icon(Icons.warehouse_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter full address',
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
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Storage Capacity',
                        hintText: 'Maximum units',
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
                        prefixIcon: const Icon(Icons.inventory_outlined),
                        suffixText: 'units',
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
                            // Handle adding location
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Add Location',
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
  
  void _showManageInventoryDialog() {
    // Implement inventory management dialog
  }
  
  void _showCreateTransferDialog() {
    // Implement transfer creation dialog
  }
  
  void _showLocationDetailsDialog(StorageLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${location.address}'),
            const SizedBox(height: 8),
            Text('Status: ${location.status}'),
            const SizedBox(height: 8),
            Text('Capacity: ${location.usedCapacity}/${location.capacity} units (${(location.usedCapacity / location.capacity * 100).toStringAsFixed(1)}%)'),
            const SizedBox(height: 8),
            Text('Items: ${location.itemCount}'),
            const SizedBox(height: 8),
            Text('Last Updated: ${_formatDateTime(location.lastUpdated)}'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: location.usedCapacity / location.capacity,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                location.usedCapacity / location.capacity > 0.9 
                    ? Colors.red 
                    : location.usedCapacity / location.capacity > 0.7
                        ? Colors.orange
                        : Colors.green,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to detailed view or edit
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _StorageLocationCard extends StatelessWidget {
  final StorageLocation location;
  final VoidCallback onTap;
  
  const _StorageLocationCard({
    required this.location,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final capacityPercentage = location.usedCapacity / location.capacity;
    final capacityColor = capacityPercentage > 0.9 
        ? Colors.red 
        : capacityPercentage > 0.7
            ? Colors.orange
            : Colors.green;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.mkbhdLightGrey.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.mkbhdRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.warehouse,
                        color: AppTheme.mkbhdRed,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location.address,
                            style: TextStyle(
                              color: AppTheme.mkbhdLightGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: location.status == 'Active' 
                            ? Colors.green.withOpacity(0.1)
                            : AppTheme.mkbhdLightGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        location.status,
                        style: TextStyle(
                          color: location.status == 'Active' ? Colors.green : AppTheme.mkbhdLightGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${location.itemCount} items',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${location.usedCapacity}/${location.capacity} units',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: capacityColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: capacityPercentage,
                    backgroundColor: AppTheme.mkbhdLightGrey.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(capacityColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StorageLocation {
  final String id;
  final String name;
  final String address;
  final int capacity;
  final int usedCapacity;
  final int itemCount;
  final DateTime lastUpdated;
  final String status;

  StorageLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.capacity,
    required this.usedCapacity,
    required this.itemCount,
    required this.lastUpdated,
    required this.status,
  });
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
