import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import '../../../common/widgets/custom_snack_bar.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/widgets/custom_button.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;
  final String? initialPhone; // For pre-filling from sales
  final String? initialName; // For pre-filling from sales
  final bool fromSales; // To indicate if coming from sales flow
  
  const AddCustomerScreen({
    Key? key,
    this.customer,
    this.initialPhone,
    this.initialName,
    this.fromSales = false,
  }) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditMode = false;
  CustomerModel? _customerToEdit; // Store the customer being edited
  late CustomerRepository _repository;
  
  // Customer preferences
  String _preferredPaymentMethod = 'Cash';
  String _customerType = 'Regular';
  bool _isVIP = false;
  
  final List<String> _paymentMethods = ['Cash', 'Mobile Money', 'Bank Transfer', 'Card', 'Installment'];
  final List<String> _customerTypes = ['Regular', 'Wholesale', 'Corporate', 'VIP'];
  
  @override
  void initState() {
    super.initState();
    
    // Check if we're in edit mode from widget.customer or from extra parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _checkEditMode();
    });
  }
  
  void _checkEditMode() {
    // Check if we have a customer from widget or from extra parameter
    CustomerModel? customerToEdit;
    
    if (widget.customer != null) {
      customerToEdit = widget.customer;
    } else {
      // Check if we have extra data from navigation
      final extra = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (extra != null && extra['customer'] != null) {
        customerToEdit = extra['customer'] as CustomerModel;
      }
    }
    
    if (customerToEdit != null) {
      setState(() {
        _isEditMode = true;
        _customerToEdit = customerToEdit;
        _nameController.text = customerToEdit!.name;
        _phoneController.text = customerToEdit!.phoneNumber;
        _emailController.text = customerToEdit!.email ?? '';
        _addressController.text = customerToEdit!.address ?? '';
      });
    }
    
    // Check for extra parameters from navigation
    final extra = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (extra != null) {
      if (extra['fromSales'] == true) {
        // Handle fromSales parameter
      }
      if (extra['initialPhone'] != null) {
        _phoneController.text = extra['initialPhone'];
      }
      if (extra['initialName'] != null) {
        _nameController.text = extra['initialName'];
      }
    }
    
    // Pre-fill data if provided from widget
    if (widget.initialPhone != null) {
      _phoneController.text = widget.initialPhone!;
    }
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
  }
  
  void _initRepository() {
    try {
      _repository = Provider.of<CustomerRepository>(context, listen: false);
    } catch (e) {
      _repository = CustomerRepositoryImpl();
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final customerData = CustomerModel(
        id: _isEditMode ? _customerToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        totalPurchases: _isEditMode ? _customerToEdit!.totalPurchases : 0.0,
        purchaseCount: _isEditMode ? _customerToEdit!.purchaseCount : 0,
        lastPurchaseDate: _isEditMode ? _customerToEdit!.lastPurchaseDate : DateTime.now(),
        createdAt: _isEditMode ? _customerToEdit!.createdAt : DateTime.now(),
      );
      
      if (_isEditMode) {
        await _repository.updateCustomer(customerData);
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Customer updated successfully',
        );
      } else {
        await _repository.createCustomer(customerData);
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Customer added successfully',
        );
      }
      
      if (mounted) {
        // Check if coming from sales from extra parameters
        final extra = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isFromSales = widget.fromSales || (extra != null && extra['fromSales'] == true);
        
        // If coming from sales, go back to sales
        if (isFromSales) {
          context.pop(customerData);
        } else {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Failed to ${_isEditMode ? 'update' : 'add'} customer: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _checkExistingCustomer() async {
    if (_phoneController.text.trim().isEmpty) {
      CustomSnackBar.showWarning(
        context: context,
        message: 'Please enter a phone number first',
      );
      return;
    }
    
    try {
      final customers = await _repository.getCustomers(search: _phoneController.text.trim());
      if (customers.isNotEmpty) {
        final existingCustomer = customers.first;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Customer Already Exists'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${existingCustomer.name}'),
                Text('Phone: ${existingCustomer.phoneNumber}'),
                if (existingCustomer.email != null) Text('Email: ${existingCustomer.email}'),
                Text('Total Purchases: ${existingCustomer.formattedTotalPurchases}'),
                Text('Purchase Count: ${existingCustomer.purchaseCount}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.fromSales) {
                    context.pop(existingCustomer);
                  } else {
                    context.push('/customers/${existingCustomer.id}');
                  }
                },
                child: const Text('View Customer'),
              ),
            ],
          ),
        );
      } else {
        CustomSnackBar.showInfo(
          context: context,
          message: 'No existing customer found with this phone number',
        );
      }
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Error checking customer: ${e.toString()}',
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Customer' : 'Add Customer',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditMode && _phoneController.text.isNotEmpty)
            IconButton(
              icon: Icon(LucideIcons.search, size: 20.sp),
              onPressed: _checkExistingCustomer,
              tooltip: 'Check existing customer',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          children: [
            // Header section - iOS style
            if (widget.fromSales)
              Container(
                padding: EdgeInsets.all(20.w),
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.shoppingCart,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adding customer for new sale',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Fill in customer details below',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Basic Information Section
            _buildSectionHeader('Basic Information', LucideIcons.user),
            
            // Name field
            _buildTextField(
              controller: _nameController,
              label: 'Full Name*',
              hint: 'Enter customer full name',
              icon: LucideIcons.user,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter customer name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Phone field
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number*',
              hint: 'Enter phone number',
              icon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.trim().length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Email field
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter email address (optional)',
              icon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Address field
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter customer address (optional)',
              icon: LucideIcons.mapPin,
              maxLines: 3,
            ),
            
            SizedBox(height: 24.h),
            
            // Customer Preferences Section
            _buildSectionHeader('Customer Preferences', LucideIcons.settings),
            
            // Customer Type
            _buildDropdownField(
              label: 'Customer Type',
              value: _customerType,
              items: _customerTypes,
              onChanged: (value) {
                setState(() {
                  _customerType = value!;
                  _isVIP = value == 'VIP';
                });
              },
              icon: LucideIcons.users,
            ),
            
            SizedBox(height: 16.h),
            
            // Preferred Payment Method
            _buildDropdownField(
              label: 'Preferred Payment Method',
              value: _preferredPaymentMethod,
              items: _paymentMethods,
              onChanged: (value) {
                setState(() {
                  _preferredPaymentMethod = value!;
                });
              },
              icon: LucideIcons.creditCard,
            ),
            
            SizedBox(height: 16.h),
            
            // VIP Status
            if (_isVIP)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.crown,
                      color: Colors.amber[700],
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'VIP Customer - Eligible for special discounts and priority service',
                        style: GoogleFonts.poppins(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 24.h),
            
            // Additional Information Section
            _buildSectionHeader('Additional Information', LucideIcons.fileText),
            
            // Notes field
            _buildTextField(
              controller: _notesController,
              label: 'Notes',
              hint: 'Add any additional notes about the customer',
              icon: LucideIcons.fileText,
              maxLines: 3,
            ),
            
            SizedBox(height: 32.h),
            
            // Save button using CustomButton
            CustomButton(
              text: _isLoading 
                  ? 'Saving...' 
                  : (_isEditMode ? 'Update Customer' : 'Add Customer'),
              onPressed: _saveCustomer,
              isLoading: _isLoading,
              icon: _isEditMode ? LucideIcons.check : LucideIcons.userPlus,
              fullWidth: true,
            ),
            
            SizedBox(height: 16.h),
            
            // Quick Actions with proper sizing
            if (!_isEditMode)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface.withOpacity(0.7),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.5),
                          width: 1,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // More rounded, no icon
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _checkExistingCustomer,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(
                          color: colorScheme.primary,
                          width: 1,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // More rounded, no icon
                        ),
                      ),
                      child: Text(
                        'Check Existing',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h, top: 8.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: controller,
          hintText: hint,
          prefixIcon: icon,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          borderRadius: 16.0,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant, size: 18.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            isDense: true,
          ),
          dropdownColor: colorScheme.surface,
          style: GoogleFonts.poppins(
            color: colorScheme.onSurface,
            fontSize: 14.sp,
          ),
          iconSize: 20.sp,
        ),
      ],
    );
  }
}
