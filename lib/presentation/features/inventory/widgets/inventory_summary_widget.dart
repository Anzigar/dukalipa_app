import 'package:flutter/material.dart';
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
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        // No boxShadow - completely removed
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Products', 
                  '${summary['totalProducts']}',
                  Icons.inventory_2_outlined,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Low Stock', 
                  '${summary['lowStockCount']}',
                  Icons.warning_outlined,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Out of Stock', 
                  '${summary['outOfStockCount']}',
                  Icons.remove_shopping_cart_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: colorScheme.onPrimaryContainer.withOpacity(0.2), 
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.trending_up_outlined,
                color: colorScheme.onPrimaryContainer,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Total Inventory Value:',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'TSh ${summary['totalValue'].toStringAsFixed(0)}',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: colorScheme.onPrimaryContainer,
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateInventorySummary() {
    int totalProducts = products.length;
    int lowStockCount = products.where((p) => p.isLowStock).length;
    int outOfStockCount = products.where((p) => p.isOutOfStock).length;
    double totalValue = products.fold(0, (sum, product) => sum + product.inventoryValue);
    
    return {
      'totalProducts': totalProducts,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'totalValue': totalValue,
    };
  }
}
