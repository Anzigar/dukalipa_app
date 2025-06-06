import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../models/product_group_model.dart';

// Create a simple implementation to avoid import errors
class ProductGroupRepositoryImpl {
  Future<ProductGroupModel> createGroup(ProductGroupModel group, {File? imageFile}) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return group;
  }
  
  Future<ProductGroupModel> updateGroup(ProductGroupModel group, {File? imageFile}) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return group;
  }
}

class CreateGroupScreen extends StatefulWidget {
  final ProductGroupModel? group; // For editing existing groups

  const CreateGroupScreen({Key? key, this.group}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final List<String> _availableCategories = [
    'Smartphones', 'Laptops', 'Tablets', 'Accessories',
    'Men\'s Wear', 'Women\'s Wear', 'Kids Wear', 'Shoes',
    'Snacks', 'Beverages', 'Dairy', 'Fruits',
    'Books', 'Stationery', 'Office Supplies',
  ];
  
  List<String> _selectedCategories = [];
  File? _groupImage;
  bool _isLoading = false;
  
  final ProductGroupRepositoryImpl _repository = ProductGroupRepositoryImpl();

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _descriptionController.text = widget.group!.description;
      _selectedCategories = List.from(widget.group!.categories);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _groupImage = File(image.path);
      });
    }
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one category'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final group = ProductGroupModel(
        id: widget.group?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        color: null, // Remove color - will use default theme colors
        categories: _selectedCategories,
        productCount: widget.group?.productCount ?? 0,
        createdAt: widget.group?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ProductGroupModel savedGroup;
      if (widget.group != null) {
        savedGroup = await _repository.updateGroup(group, imageFile: _groupImage);
      } else {
        savedGroup = await _repository.createGroup(group, imageFile: _groupImage);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.group != null ? 'Updated' : 'Created'} group successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop(savedGroup);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.group != null ? 'update' : 'create'} group: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.group != null ? 'Edit Group' : 'Create Group',
                    style: TextStyle(
                      fontSize: 20,
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
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group Name
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Group Name*',
                        prefixIcon: LucideIcons.folder,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter group name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description*',
                        prefixIcon: LucideIcons.alignLeft,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Categories
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Categories*',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableCategories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Save Button
                      CustomButton(
                        text: widget.group != null ? 'Update Group' : 'Create Group',
                        isLoading: _isLoading,
                        onPressed: _saveGroup,
                        icon: widget.group != null ? LucideIcons.save : LucideIcons.plus,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
