import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventorySummary extends StatelessWidget {
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalValue;

  const InventorySummary({
    super.key,
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildSummaryCard(
                      context: context,
                      icon: Icons.inventory_2_outlined,
                      label: 'Total Products',
                      value: totalProducts.toString(),
                      color: colorScheme.primary,
                      flex: 1,
                    ),
                    const SizedBox(width: 8),
                    _buildSummaryCard(
                      context: context,
                      icon: Icons.attach_money,
                      label: 'Total Value',
                      value: currencyFormat.format(totalValue),
                      color: colorScheme.tertiary,
                      flex: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSummaryCard(
                      context: context,
                      icon: Icons.warning_amber_outlined,
                      label: 'Low Stock',
                      value: lowStockCount.toString(),
                      color: colorScheme.secondary,
                      flex: 1,
                    ),
                    const SizedBox(width: 8),
                    _buildSummaryCard(
                      context: context,
                      icon: Icons.remove_shopping_cart,
                      label: 'Out of Stock',
                      value: outOfStockCount.toString(),
                      color: colorScheme.error,
                      flex: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
