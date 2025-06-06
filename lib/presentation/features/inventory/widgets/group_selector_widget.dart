import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/product_group_model.dart';

class GroupSelectorWidget extends StatelessWidget {
  final ProductGroupModel? selectedGroup;
  final Function(ProductGroupModel?) onGroupSelected;
  final VoidCallback onCreateGroup;

  const GroupSelectorWidget({
    Key? key,
    required this.selectedGroup,
    required this.onGroupSelected,
    required this.onCreateGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Icon(
              Icons.folder_outlined,
              color: colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Product Group (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Group selector container - Material 3 clean design
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedGroup != null 
                  ? colorScheme.primary.withOpacity(0.5)
                  : colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showGroupSelection(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: selectedGroup != null 
                    ? _buildSelectedGroup(colorScheme)
                    : _buildEmptyState(colorScheme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedGroup(ColorScheme colorScheme) {
    return Row(
      children: [
        // Group icon with background
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.folder_rounded,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Group details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedGroup!.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${selectedGroup!.categories.length} categories',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Remove button
            InkWell(
              onTap: () => onGroupSelected(null),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            const SizedBox(width: 4),
            
            // Change button
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Row(
      children: [
        // Plus icon with dashed border
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.add_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select or create group',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Organize products by category',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        // Arrow icon
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ],
    );
  }

  void _showGroupSelection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Product Group',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Create new group option
                  _buildGroupOption(
                    context: context,
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Create New Group',
                    subtitle: 'Add a custom product group',
                    onTap: () {
                      Navigator.pop(context);
                      onCreateGroup();
                    },
                    colorScheme: colorScheme,
                    isCreateOption: true,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Divider with "or" text
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or choose existing',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.outlineVariant)),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Sample groups
                  ..._getSampleGroups().map((group) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildGroupOption(
                      context: context,
                      icon: Icons.folder_rounded,
                      title: group['name'],
                      subtitle: '${group['categories'].length} categories',
                      onTap: () {
                        Navigator.pop(context);
                        onGroupSelected(ProductGroupModel(
                          id: group['id'],
                          name: group['name'],
                          description: group['description'],
                          categories: List<String>.from(group['categories']),
                          productCount: group['productCount'],
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ));
                      },
                      colorScheme: colorScheme,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    bool isCreateOption = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isCreateOption 
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCreateOption 
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCreateOption 
                        ? colorScheme.primary.withOpacity(0.1)
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCreateOption 
                          ? colorScheme.primary.withOpacity(0.2)
                          : colorScheme.outlineVariant.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isCreateOption 
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                
                const SizedBox(width: 14),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleGroups() {
    return [
      {
        'id': '1',
        'name': 'Electronics',
        'description': 'Electronic devices and accessories',
        'categories': ['Smartphones', 'Laptops', 'Tablets', 'Accessories'],
        'productCount': 12,
      },
      {
        'id': '2',
        'name': 'Fashion',
        'description': 'Clothing and fashion items',
        'categories': ['Men\'s Wear', 'Women\'s Wear', 'Kids Wear', 'Shoes'],
        'productCount': 8,
      },
      {
        'id': '3',
        'name': 'Food & Beverages',
        'description': 'Food items and drinks',
        'categories': ['Snacks', 'Beverages', 'Dairy', 'Fruits'],
        'productCount': 15,
      },
    ];
  }
}
