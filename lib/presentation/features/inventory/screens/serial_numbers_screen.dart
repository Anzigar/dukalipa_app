import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/product_model.dart';
import '../../../common/widgets/shimmer_loading.dart';

class SerialNumbersScreen extends StatefulWidget {
  final ProductModel product;
  final String productId;

  const SerialNumbersScreen({
    Key? key,
    required this.product,
    required this.productId,
  }) : super(key: key);

  @override
  State<SerialNumbersScreen> createState() => _SerialNumbersScreenState();
}

class _SerialNumbersScreenState extends State<SerialNumbersScreen> {
  String _searchQuery = '';
  String _selectedCondition = 'All';
  String _selectedColor = 'All';
  String _selectedStorage = 'All';
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  final List<String> _conditions = ['All', 'Used', 'New', 'Refurbished'];
  final List<String> _colors = ['All', 'Black', 'White', 'Blue', 'Red', 'Gold', 'Silver', 'Gray', 'Green'];
  final List<String> _storages = ['All', '64GB', '128GB', '256GB', '512GB', '1TB'];

  @override
  void initState() {
    super.initState();
    _loadSerialNumbers();
  }

  Future<void> _loadSerialNumbers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call to load serial numbers
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load serial numbers: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.product.name} - Serial Numbers'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isLoading) ...[
            IconButton(
              onPressed: _loadSerialNumbers,
              icon: Icon(
                LucideIcons.refreshCw,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Refresh',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                minimumSize: const Size(44, 44),
              ),
            ),
            IconButton(
              onPressed: _exportAllDevices,
              icon: Icon(
                LucideIcons.download,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Export All',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                minimumSize: const Size(44, 44),
              ),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const SerialNumbersShimmer()
          : _hasError
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertTriangle,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Serial Numbers',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An error occurred while loading the serial numbers',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadSerialNumbers,
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final filteredDevices = _getFilteredDevices();
    
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24), // Fully rounded Material3
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search serial numbers...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filter Chips
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Condition Filter
                    _buildFilterDropdown(
                      'Condition',
                      _selectedCondition,
                      _conditions,
                      (value) => setState(() => _selectedCondition = value!),
                      LucideIcons.star,
                    ),
                    const SizedBox(width: 12),
                    
                    // Color Filter
                    _buildFilterDropdown(
                      'Color',
                      _selectedColor,
                      _colors,
                      (value) => setState(() => _selectedColor = value!),
                      LucideIcons.palette,
                    ),
                    const SizedBox(width: 12),
                    
                    // Storage Filter
                    _buildFilterDropdown(
                      'Storage',
                      _selectedStorage,
                      _storages,
                      (value) => setState(() => _selectedStorage = value!),
                      LucideIcons.hardDrive,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Results Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                LucideIcons.package,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Showing ${filteredDevices.length} of ${widget.product.quantity} devices',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (filteredDevices.length != widget.product.quantity)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear Filters'),
                ),
            ],
          ),
        ),
        
        // Device List
        Expanded(
          child: filteredDevices.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final device = filteredDevices[index];
                    return _buildDeviceCard(device, index);
                  },
                ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredDevices() {
    List<Map<String, dynamic>> devices = [];
    
    for (int i = 0; i < widget.product.quantity; i++) {
      final serialNumber = _generateSerialNumber(i);
      final deviceVariation = _generateDeviceVariation(i);
      
      devices.add({
        'index': i,
        'serialNumber': serialNumber,
        'color': deviceVariation['color']!,
        'storage': deviceVariation['storage']!,
        'condition': deviceVariation['condition']!,
      });
    }
    
    return devices.where((device) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!device['serialNumber'].toLowerCase().contains(_searchQuery)) {
          return false;
        }
      }
      
      // Condition filter
      if (_selectedCondition != 'All' && device['condition'] != _selectedCondition) {
        return false;
      }
      
      // Color filter
      if (_selectedColor != 'All' && device['color'] != _selectedColor) {
        return false;
      }
      
      // Storage filter
      if (_selectedStorage != 'All' && device['storage'] != _selectedStorage) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            underline: const SizedBox(),
            isDense: true,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device, int displayIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with device number and copy button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${device['index'] + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _copyDeviceInfo(device),
                  icon: const Icon(LucideIcons.copy, size: 18),
                  tooltip: 'Copy device info',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Serial Number
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.hash,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      device['serialNumber'],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Device Variations
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildVariationChip(
                  label: device['color'],
                  icon: LucideIcons.palette,
                  color: _getColorForVariation(device['color']),
                ),
                _buildVariationChip(
                  label: device['storage'],
                  icon: LucideIcons.hardDrive,
                  color: Colors.blue,
                ),
                _buildVariationChip(
                  label: device['condition'],
                  icon: LucideIcons.star,
                  color: _getConditionColor(device['condition']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariationChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.searchX,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No devices found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCondition = 'All';
      _selectedColor = 'All';
      _selectedStorage = 'All';
    });
  }

  void _copyDeviceInfo(Map<String, dynamic> device) {
    final deviceInfo = '''
Serial Number: ${device['serialNumber']}
Color: ${device['color']}
Storage: ${device['storage']}
Condition: ${device['condition']}
Device #${device['index'] + 1}''';

    Clipboard.setData(ClipboardData(text: deviceInfo));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Device info copied to clipboard'),
        backgroundColor: AppTheme.mkbhdRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _exportAllDevices() async {
    if (_isLoading) return;

    // Show loading state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Preparing export...'),
          ],
        ),
        backgroundColor: AppTheme.mkbhdRed,
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate export processing
    await Future.delayed(const Duration(seconds: 2));
    
    final allDevices = _getFilteredDevices();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${allDevices.length} devices ready for export'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Export CSV',
            textColor: Colors.white,
            onPressed: () {
              // Here you would implement actual export functionality
              // Generate CSV content and save/share file
            },
          ),
        ),
      );
    }
  }

  // Helper methods for generating device variations (same as in product details)
  String _generateSerialNumber(int index) {
    final productPrefix = widget.product.name.toUpperCase().replaceAll(' ', '').substring(0, 2);
    final categoryCode = widget.product.category?.substring(0, 2).toUpperCase() ?? 'PR';
    final itemNumber = (index + 1).toString().padLeft(3, '0');
    final year = DateTime.now().year.toString().substring(2);
    final randomSuffix = (1000 + index * 37 + widget.product.id.hashCode % 9000).toString();
    
    return '$productPrefix$categoryCode$year$itemNumber$randomSuffix';
  }

  Map<String, String> _generateDeviceVariation(int index) {
    final colors = ['Black', 'White', 'Blue', 'Red', 'Gold', 'Silver', 'Gray', 'Green'];
    final storages = ['64GB', '128GB', '256GB', '512GB', '1TB'];
    final conditions = ['Used', 'New', 'Refurbished'];
    
    final colorIndex = (index + widget.product.id.hashCode) % colors.length;
    final storageIndex = (index * 2 + widget.product.id.hashCode) % storages.length;
    final conditionIndex = (index * 3 + widget.product.id.hashCode) % conditions.length;
    
    return {
      'color': colors[colorIndex],
      'storage': storages[storageIndex],
      'condition': conditions[conditionIndex],
    };
  }

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
}
