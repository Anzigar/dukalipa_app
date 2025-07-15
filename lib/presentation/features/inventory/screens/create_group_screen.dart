import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              height: 4.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.group != null ? 'Edit Group' : 'Create Group',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1.h, color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
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
                            color: Theme.of(context).colorScheme.primary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Categories*',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _availableCategories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            labelStyle: TextStyle(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                            side: BorderSide(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
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
