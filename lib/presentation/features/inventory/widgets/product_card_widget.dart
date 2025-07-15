import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/product_model.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isGridView;

  const ProductCardWidget({
    Key? key,
    required this.product,
    required this.onTap,
    required this.colorScheme,
    this.isGridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // No shadow
      shadowColor: Colors.transparent, // No shadow
      surfaceTintColor: Colors.transparent, // No surface tint
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isGridView ? 12.0 : 16.0),
          child: isGridView ? _buildGridContent() : _buildListContent(),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 6),
        
        // Show different information based on product type
        if (product.hasSerialNumber && product.metadata != null && product.metadata!.containsKey('storage'))
          Text(
            'Storage: ${product.metadata!['storage']}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        else if (product.hasSerialNumber && product.metadata != null && product.metadata!.containsKey('imei'))
          Text(
            'IMEI: ${product.metadata!['imei']}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        else
          Text(
            'Quantity: ${product.quantity}${product.isAccessory ? ' pcs' : ''}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 4),
        
        // Show category for better product identification
        if (product.category != null)
          Text(
            'Category: ${product.category}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'TSh ${product.sellingPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildStockBadge(),
          ],
        ),
      ],
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          product.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 6),
        
        Text(
          product.hasSerialNumber && product.metadata?.containsKey('storage') == true
              ? 'Storage: ${product.metadata!['storage']}'
              : 'Qty: ${product.quantity}${product.isAccessory ? ' pcs' : ''}',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const Spacer(),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'TSh ${product.sellingPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStockStatusColor(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockBadge() {
    String label;
    Color badgeColor;
    
    if (product.isOutOfStock) {
      label = 'Out of Stock';
      badgeColor = colorScheme.error;
    } else if (product.isLowStock) {
      label = 'Low Stock';
      badgeColor = colorScheme.tertiary;
    } else {
      label = 'In Stock';
      badgeColor = colorScheme.primary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Color _getStockStatusColor() {
    if (product.isOutOfStock) {
      return colorScheme.error;
    } else if (product.isLowStock) {
      return colorScheme.tertiary;
    } else {
      return colorScheme.primary;
    }
  }
}

extension ProductModelProps on ProductModel {
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
  bool get isOutOfStock => quantity <= 0;
  double get inventoryValue => quantity * sellingPrice;
}
