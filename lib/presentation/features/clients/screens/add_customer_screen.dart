import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;
  
  const AddCustomerScreen({
    Key? key,
    this.customer,
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
  bool _isLoading = false;
  late CustomerRepository _repository;
  
  bool get _isEditMode => widget.customer != null;
  
  @override
  void initState() {
    super.initState();
    
    if (_isEditMode) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phoneNumber;
      _emailController.text = widget.customer!.email ?? '';
      _addressController.text = widget.customer!.address ?? '';
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
    });
  }
  
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<CustomerRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance with default API client
      final apiClient = ApiClient();
      _repository = CustomerRepositoryImpl(apiClient);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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
        id: _isEditMode ? widget.customer!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        totalPurchases: _isEditMode ? widget.customer!.totalPurchases : 0,
        purchaseCount: _isEditMode ? widget.customer!.purchaseCount : 0,
        lastPurchaseDate: _isEditMode ? widget.customer!.lastPurchaseDate : DateTime.now(),
        createdAt: _isEditMode ? widget.customer!.createdAt : DateTime.now(),
      );
      
      if (_isEditMode) {
        await _repository.updateCustomer(customerData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _repository.createCustomer(customerData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isEditMode ? 'update' : 'add'} customer: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en', 'US'));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Customer' : 'Add Customer'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Name field
            CustomTextField(
              controller: _nameController,
              labelText: 'Customer Name*',
              prefixIcon: LucideIcons.user,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Phone field
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number*',
              prefixIcon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email field
            CustomTextField(
              controller: _emailController,
              labelText: 'Email (Optional)',
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  // Simple email validation
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Address field
            CustomTextField(
              controller: _addressController,
              labelText: 'Address (Optional)',
              prefixIcon: LucideIcons.mapPin,
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Save button
            CustomButton(
              text: _isEditMode ? 'Update Customer' : 'Add Customer',
              icon: _isEditMode ? LucideIcons.check : LucideIcons.userPlus,
              isLoading: _isLoading,
              onPressed: _saveCustomer,
            ),
          ],
        ),
      ),
    );
  }
}
