import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/loading_widget.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final String? customerId;
  
  const AddEditCustomerScreen({
    Key? key,
    this.customerId,
  }) : super(key: key);

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFetchingCustomer = false;
  bool _hasError = false;
  String? _errorMessage;
  late CustomerRepository _repository;
  
  bool get _isEditMode => widget.customerId != null;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      if (_isEditMode) {
        _fetchCustomer();
      }
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<CustomerRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance
      _repository = CustomerRepositoryImpl();
    }
  }
  
  Future<void> _fetchCustomer() async {
    setState(() {
      _isFetchingCustomer = true;
      _hasError = false;
    });
    
    try {
      final customer = await _repository.getCustomerById(widget.customerId!);
      
      if (mounted) {
        setState(() {
          _nameController.text = customer.name;
          _phoneController.text = customer.phoneNumber;
          if (customer.email != null) {
            _emailController.text = customer.email!;
          }
          if (customer.address != null) {
            _addressController.text = customer.address!;
          }
          _isFetchingCustomer = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingCustomer = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }
  
  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final customer = CustomerModel(
        id: _isEditMode ? widget.customerId! : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        totalPurchases: 0,
        purchaseCount: 0,
        lastPurchaseDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      if (_isEditMode) {
        await _repository.updateCustomer(customer);
      } else {
        await _repository.createCustomer(customer);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer ${_isEditMode ? 'updated' : 'created'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isEditMode ? 'update' : 'create'} customer: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Customer' : 'Add Customer'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isFetchingCustomer
          ? const Center(child: LoadingWidget())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_hasError && _isEditMode) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred while loading customer details',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchCustomer,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.mkbhdRed,
              ),
            ),
          ],
        ),
      );
    }
    
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Name field
          CustomTextField(
            controller: _nameController,
            labelText: 'Full Name',
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
            labelText: 'Phone Number',
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
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
                if (!emailRegex.hasMatch(value)) {
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
          
          if (_hasError) ...[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage ?? 'An error occurred',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Submit button
          CustomButton(
            text: _isEditMode ? 'Update Customer' : 'Add Customer',
            isLoading: _isLoading,
            onPressed: _saveCustomer,
          ),
        ],
      ),
    );
  }
}
