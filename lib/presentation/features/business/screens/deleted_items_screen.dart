import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class DeletedItemsScreen extends StatefulWidget {
  const DeletedItemsScreen({super.key});

  @override
  State<DeletedItemsScreen> createState() => _DeletedItemsScreenState();
}

class _DeletedItemsScreenState extends State<DeletedItemsScreen> {
  bool _isLoading = false;
  final List<DeletedItem> _deletedItems = [];
  bool _showSelectOptions = false;
  final Set<String> _selectedItems = {};
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  
  @override
  void initState() {
    super.initState();
    _loadDeletedItems();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDeletedItems() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    setState(() {
      _deletedItems.clear();
      _deletedItems.addAll([
        DeletedItem(
          id: '1',
          name: 'iPhone 13 Pro',
          sku: 'IP13-PRO-256',
          category: 'Smartphones',
          price: 999.99,
          deletedAt: DateTime.now().subtract(const Duration(days: 1)),
          deletedBy: 'John Doe',
          reason: 'Product discontinued',
        ),
        DeletedItem(
          id: '2',
          name: 'Samsung Galaxy S21',
          sku: 'SAM-S21-128',
          category: 'Smartphones',
          price: 799.99,
          deletedAt: DateTime.now().subtract(const Duration(days: 3)),
          deletedBy: 'Jane Smith',
          reason: 'Incorrect listing',
        ),
        DeletedItem(
          id: '3',
          name: 'AirPods Pro',
          sku: 'APP-PRO-2',
          category: 'Audio',
          price: 249.99,
          deletedAt: DateTime.now().subtract(const Duration(days: 7)),
          deletedBy: 'John Doe',
          reason: 'Duplicate entry',
        ),
        DeletedItem(
          id: '4',
          name: 'MacBook Air M2',
          sku: 'MBA-M2-512',
          category: 'Laptops',
          price: 1199.99,
          deletedAt: DateTime.now().subtract(const Duration(days: 12)),
          deletedBy: 'Admin',
          reason: 'Out of stock for long period',
        ),
        DeletedItem(
          id: '5',
          name: 'iPad Mini',
          sku: 'IP-MINI-64',
          category: 'Tablets',
          price: 499.99,
          deletedAt: DateTime.now().subtract(const Duration(days: 14)),
          deletedBy: 'System',
          reason: 'Auto cleanup - discontinued product',
        ),
      ]);
      _isLoading = false;
    });
  }

  void _toggleItemSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }
      
      // If no items selected, hide selection options
      if (_selectedItems.isEmpty) {
        _showSelectOptions = false;
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _showSelectOptions = !_showSelectOptions;
      if (!_showSelectOptions) {
        _selectedItems.clear();
      }
    });
  }

  Future<void> _restoreSelectedItems() async {
    if (_selectedItems.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Items'),
        content: Text('Are you sure you want to restore ${_selectedItems.length} item(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mkbhdRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _deletedItems.removeWhere((item) => _selectedItems.contains(item.id));
        _selectedItems.clear();
        _showSelectOptions = false;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Items restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _permanentlyDeleteSelectedItems() async {
    if (_selectedItems.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: Text(
          'Are you sure you want to permanently delete ${_selectedItems.length} item(s)?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _deletedItems.removeWhere((item) => _selectedItems.contains(item.id));
        _selectedItems.clear();
        _showSelectOptions = false;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Items permanently deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<DeletedItem> get _filteredItems {
    if (_searchController.text.isEmpty && _selectedFilter == null) {
      return _deletedItems;
    }
    
    return _deletedItems.where((item) {
      bool matchesSearch = true;
      bool matchesFilter = true;
      
      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final searchText = _searchController.text.toLowerCase();
        matchesSearch = item.name.toLowerCase().contains(searchText) || 
            item.sku.toLowerCase().contains(searchText);
      }
      
      // Apply category filter
      if (_selectedFilter != null) {
        matchesFilter = item.category == _selectedFilter;
      }
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Deleted Items'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_deletedItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _showSelectOptions 
                    ? AppTheme.mkbhdRed.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _toggleSelectionMode,
                icon: Icon(
                  _showSelectOptions ? Icons.close_rounded : Icons.checklist_rounded,
                  color: _showSelectOptions ? AppTheme.mkbhdRed : null,
                ),
                tooltip: _showSelectOptions ? 'Cancel selection' : 'Select multiple',
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and filter section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search deleted items',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
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
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', null),
                            const SizedBox(width: 8),
                            _buildFilterChip('Smartphones', 'Smartphones'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Laptops', 'Laptops'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Audio', 'Audio'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Tablets', 'Tablets'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection options bar
                if (_showSelectOptions)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.mkbhdRed.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.mkbhdRed.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.mkbhdRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_selectedItems.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'selected',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _selectedItems.isEmpty ? null : _restoreSelectedItems,
                          icon: const Icon(Icons.restore_rounded, size: 20),
                          label: const Text('Restore'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _selectedItems.isEmpty ? null : _permanentlyDeleteSelectedItems,
                          icon: const Icon(Icons.delete_forever_rounded, size: 20),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_showSelectOptions) const SizedBox(height: 8),

                // Items list
                Expanded(
                  child: _filteredItems.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.delete_outline,
                          title: 'No Deleted Items',
                          description: 'There are no deleted items to display.',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDeletedItems,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isSelected = _selectedItems.contains(item.id);
                              
                              return _DeletedItemCard(
                                item: item,
                                showSelectCheckbox: _showSelectOptions,
                                isSelected: isSelected,
                                onToggleSelect: () => _toggleItemSelection(item.id),
                                onTap: () {
                                  if (_showSelectOptions) {
                                    _toggleItemSelection(item.id);
                                  } else {
                                    _showItemDetailsBottomSheet(item);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildFilterChip(String label, String? filterValue) {
    final isSelected = _selectedFilter == filterValue;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = isSelected ? null : filterValue;
        });
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: AppTheme.mkbhdRed.withOpacity(0.1),
      checkmarkColor: AppTheme.mkbhdRed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected 
              ? AppTheme.mkbhdRed.withOpacity(0.3) 
              : AppTheme.mkbhdLightGrey.withOpacity(0.1),
        ),
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.mkbhdRed : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
  
  void _showItemDetailsBottomSheet(DeletedItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Item details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.mkbhdRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: AppTheme.mkbhdRed,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SKU: ${item.sku}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.mkbhdRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // Deletion info
                _DetailItem(
                  icon: Icons.calendar_today,
                  title: 'Deleted Date',
                  value: _formatDate(item.deletedAt),
                ),
                _DetailItem(
                  icon: Icons.person_outline,
                  title: 'Deleted By',
                  value: item.deletedBy,
                ),
                _DetailItem(
                  icon: Icons.info_outline,
                  title: 'Reason',
                  value: item.reason,
                ),
                const SizedBox(height: 32),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _permanentlyDeleteItem(item);
                        },
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Delete Permanently'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _restoreItem(item);
                        },
                        icon: const Icon(Icons.restore),
                        label: const Text('Restore Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mkbhdRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _permanentlyDeleteItem(DeletedItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: const Text(
          'Are you sure you want to permanently delete this item?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _deletedItems.removeWhere((i) => i.id == item.id);
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item permanently deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _restoreItem(DeletedItem item) async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _deletedItems.removeWhere((i) => i.id == item.id);
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item restored successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletedItemCard extends StatelessWidget {
  final DeletedItem item;
  final bool showSelectCheckbox;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onTap;

  const _DeletedItemCard({
    required this.item,
    required this.showSelectCheckbox,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected 
              ? AppTheme.mkbhdRed.withOpacity(0.5) 
              : AppTheme.mkbhdLightGrey.withOpacity(0.08),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSelectCheckbox)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppTheme.mkbhdRed : AppTheme.mkbhdLightGrey,
                          width: 2,
                        ),
                        color: isSelected ? AppTheme.mkbhdRed : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      size: 14,
                                      color: AppTheme.mkbhdLightGrey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.sku,
                                      style: TextStyle(
                                        color: AppTheme.mkbhdLightGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: AppTheme.mkbhdRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: AppTheme.mkbhdLightGrey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDaysAgo(item.deletedAt),
                                style: TextStyle(
                                  color: AppTheme.mkbhdLightGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}

class DeletedItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final DateTime deletedAt;
  final String deletedBy;
  final String reason;

  DeletedItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.deletedAt,
    required this.deletedBy,
    required this.reason,
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
