import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../../../common/widgets/material3_search_bar.dart';

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
  String _searchQuery = '';
  
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
          deletedBy: 'Ansigar Erasm',
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
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Deleted Items'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) => const TransactionCardShimmer(),
            )
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material3SearchBar(
                    controller: _searchController,
                    hintText: 'Search deleted items',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    leading: Icon(
                      LucideIcons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                // Items list
                Expanded(
                  child: _deletedItems.isEmpty
                      ?  Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Deleted Items',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'There are no deleted items to display.',
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDeletedItems,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _deletedItems.length,
                            itemBuilder: (context, index) {
                              final item = _deletedItems[index];
                              
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppTheme.mkbhdRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2,
                                      color: AppTheme.mkbhdRed,
                                    ),
                                  ),
                                  title: Text(
                                    item.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('SKU: ${item.sku}'),
                                      Text('Deleted: ${_formatDate(item.deletedAt)}'),
                                      Text('Reason: ${item.reason}'),
                                    ],
                                  ),
                                  trailing: Text(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.mkbhdRed,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
