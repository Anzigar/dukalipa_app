import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';

class InventorySummaryWidget extends StatelessWidget {
  final List<ProductModel> products;
  final ColorScheme colorScheme;

  const InventorySummaryWidget({
    Key? key,
    required this.products,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summary = _calculateInventorySummary();
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Inventory Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Total Value - Primary stat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Inventory Value',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'TSh ${NumberFormat('#,###').format(summary['totalValue'])}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: 'Total Products',
                      value: '${summary['totalProducts']}',
                      icon: Icons.apps_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: 'Low Stock',
                      value: '${summary['lowStockCount']}',
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: 'Out of Stock',
                      value: '${summary['outOfStockCount']}',
                      icon: Icons.remove_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: colorScheme.primary,
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateInventorySummary() {
    int totalProducts = products.length;
    int lowStockCount = products.where((p) => p.isLowStock).length;
    int outOfStockCount = products.where((p) => p.isOutOfStock).length;
    
    // Fix: Calculate total inventory value properly for all product types
    double totalValue = products.fold(0.0, (sum, product) {
      // Handle products with or without serial numbers
      // Use quantity * cost price for accessories and other non-serialized items
      double productValue = product.quantity * product.costPrice;
      return sum + productValue;
    });
    
    return {
      'totalProducts': totalProducts,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'totalValue': totalValue,
    };
  }
}
