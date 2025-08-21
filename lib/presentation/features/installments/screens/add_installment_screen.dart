import 'package:dukalipa_app/presentation/common/widgets/custom_button.dart';
import 'package:dukalipa_app/presentation/common/widgets/custom_text_field.dart';
import 'package:dukalipa_app/presentation/common/widgets/custom_snack_bar.dart';
import 'package:dukalipa_app/presentation/features/inventory/repositories/inventory_repository.dart' as inventory_impl;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../repositories/installment_repository.dart'; 
import '../repositories/installment_repository_impl.dart' as impl;
import '../../clients/models/client_model.dart';
import '../../clients/repositories/client_repository.dart';
import '../../clients/repositories/client_repository_impl.dart' as client_impl;
import '../../inventory/models/product_model.dart';
import '../../inventory/repositories/inventory_repository.dart';

class AddInstallmentScreen extends StatefulWidget {
  const AddInstallmentScreen({Key? key}) : super(key: key);

  @override
  State<AddInstallmentScreen> createState() => _AddInstallmentScreenState();
}

class _AddInstallmentScreenState extends State<AddInstallmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSearchingClients = false;
  bool _isSearchingProducts = false;

  // Client information
  ClientModel? _selectedClient;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  List<ClientModel> _searchResults = [];

  // Product selection
  final List<ProductModel> _selectedProducts = [];
  List<ProductModel> _productSearchResults = [];
  final _productSearchController = TextEditingController();

  // Payment information
  final _totalAmountController = TextEditingController();
  final _downPaymentController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  final _notesController = TextEditingController();

  late InstallmentRepository _installmentRepository;
  late ClientRepository _clientRepository;
  late InventoryRepository _inventoryRepository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepositories();
    });
  }

  void _initRepositories() {
    try {
      _installmentRepository = Provider.of<InstallmentRepository>(context, listen: false);
      _clientRepository = Provider.of<ClientRepository>(context, listen: false);
      _inventoryRepository = Provider.of<InventoryRepository>(context, listen: false);
    } catch (e) {
      // If providers not available, create local instances
      _installmentRepository = impl.InstallmentRepositoryImpl();
      _clientRepository = client_impl.ClientRepositoryImpl();
      _inventoryRepository = inventory_impl.InventoryRepositoryImpl();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _productSearchController.dispose();
    _totalAmountController.dispose();
    _downPaymentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _searchClients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchingClients = false;
      });
      return;
    }

    setState(() {
      _isSearchingClients = true;
    });

    try {
      final results = await _clientRepository.searchClients(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearchingClients = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearchingClients = false;
        });
        CustomSnackBar.showError(
          context: context,
          message: 'Error searching clients: ${e.toString()}',
        );
      }
    }
  }

  void _selectClient(ClientModel client) {
    setState(() {
      _selectedClient = client;
      _nameController.text = client.name;
      _phoneController.text = client.phoneNumber;
      _emailController.text = client.email ?? '';
      _addressController.text = client.address ?? '';
      _searchResults = [];
    });
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _productSearchResults = [];
        _isSearchingProducts = false;
      });
      return;
    }

    setState(() {
      _isSearchingProducts = true;
    });

    try {
      final results = await _inventoryRepository.getProducts(search: query);
      if (mounted) {
        setState(() {
          _productSearchResults = results.where((p) => p.quantity > 0).toList();
          _isSearchingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productSearchResults = [];
          _isSearchingProducts = false;
        });
        CustomSnackBar.showError(
          context: context,
          message: 'Error searching products: ${e.toString()}',
        );
      }
    }
  }

  void _addProduct(ProductModel product) {
    // Check if product is already added
    final existingIndex = _selectedProducts.indexWhere((p) => p.id == product.id);
    
    if (existingIndex >= 0) {
      CustomSnackBar.showWarning(
        context: context,
        message: 'Product already added',
      );
      return;
    }
    
    setState(() {
      _selectedProducts.add(product);
      _productSearchResults = [];
      _productSearchController.clear();
      _recalculateTotalAmount();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
      _recalculateTotalAmount();
    });
  }

  void _recalculateTotalAmount() {
    final total = _selectedProducts.fold<double>(
      0, (sum, product) => sum + product.sellingPrice
    );
    
    _totalAmountController.text = total.toStringAsFixed(2);
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.mkbhdRed,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black87,
              surface: AppTheme.mkbhdRed.withOpacity(0.1),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.mkbhdRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mkbhdRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
        // Update due date to maintain the same duration
        final duration = _dueDate.difference(_startDate);
        _dueDate = pickedDate.add(duration);
      });
    }
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: _startDate.add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.mkbhdRed,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black87,
              surface: AppTheme.mkbhdRed.withOpacity(0.1),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.mkbhdRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mkbhdRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }
  
  Future<ClientModel> _createTemporaryClient() async {
    // In a real app, you would save this client to the backend
    // Here we just create a temporary client for the installment
    return ClientModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      totalPurchases: 0,
      purchaseCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _createInstallment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedProducts.isEmpty) {
      CustomSnackBar.showError(
        context: context,
        message: 'Please add at least one product',
      );
      return;
    }
    
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
    final downPayment = double.tryParse(_downPaymentController.text) ?? 0;
    
    if (downPayment <= 0) {
      CustomSnackBar.showError(
        context: context,
        message: 'Down payment must be greater than zero',
      );
      return;
    }
    
    if (downPayment >= totalAmount) {
      CustomSnackBar.showError(
        context: context,
        message: 'Down payment cannot be equal to or greater than total amount',
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get the client (use existing or create temporary)
      final client = _selectedClient ?? await _createTemporaryClient();
      
      // Create installment
      await _installmentRepository.createInstallment(
        client: client,
        totalAmount: totalAmount,
        downPayment: downPayment,
        startDate: _startDate,
        dueDate: _dueDate,
        productIds: _selectedProducts.map((p) => p.id).toList(),
        productNames: _selectedProducts.map((p) => p.name).toList(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      if (mounted) {
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Installment created successfully',
        );
        // Navigate back to installments list
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Failed to create installment: ${e.toString()}',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Installment Plan'),
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
            // Client Information Section
            _buildSectionHeader('Client Information'),
            const SizedBox(height: 16),
            
            // Client Search Field
            Stack(
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Client Name*',
                  prefixIcon: LucideIcons.user,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter client name';
                    }
                    return null;
                  },
                  onChanged: _searchClients,
                ),
                if (_isSearchingClients)
                  const Positioned(
                    right: 12,
                    top: 12,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.mkbhdRed,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Client search results
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final client = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                        child: Text(
                          client.initials,
                          style: const TextStyle(color: AppTheme.mkbhdRed),
                        ),
                      ),
                      title: Text(client.name),
                      subtitle: Text(client.phoneNumber),
                      onTap: () => _selectClient(client),
                    );
                  },
                ),
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
            ),
            
            const SizedBox(height: 16),
            
            // Address field
            CustomTextField(
              controller: _addressController,
              labelText: 'Address (Optional)',
              prefixIcon: LucideIcons.mapPin,
            ),
            
            const SizedBox(height: 24),
            
            // Product Selection Section
            _buildSectionHeader('Product Selection'),
            const SizedBox(height: 16),
            
            // Product search field
            Stack(
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24), // Fully rounded Material3
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _productSearchController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Search Products',
                      hintText: 'Search by name or code',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: _productSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              LucideIcons.x,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 18,
                            ),
                            onPressed: () {
                              _productSearchController.clear();
                              setState(() {
                                _productSearchResults = [];
                              });
                            },
                          )
                        : null,
                    ),
                    onChanged: _searchProducts,
                  ),
                ),
                if (_isSearchingProducts)
                  const Positioned(
                    right: 12,
                    top: 12,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.mkbhdRed,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Product search results
            if (_productSearchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _productSearchResults.length,
                  itemBuilder: (context, index) {
                    final product = _productSearchResults[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.mkbhdRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          LucideIcons.package,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text('In stock: ${product.quantity}'),
                      trailing: Text(
                        'TSh ${NumberFormat('#,###').format(product.sellingPrice)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                      onTap: () => _addProduct(product),
                    );
                  },
                ),
              ),
            
            // Selected products
            if (_selectedProducts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Selected Products',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _selectedProducts.length,
                (index) => _buildProductItem(index),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Payment Information Section
            _buildSectionHeader('Payment Information'),
            const SizedBox(height: 16),
            
            // Total amount field
            CustomTextField(
              controller: _totalAmountController,
              labelText: 'Total Amount (TSh)*',
              prefixIcon: LucideIcons.dollarSign,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Down payment field
            CustomTextField(
              controller: _downPaymentController,
              labelText: 'Down Payment (TSh)*',
              prefixIcon: LucideIcons.wallet,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter down payment';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                final downPayment = double.parse(value);
                if (downPayment <= 0) {
                  return 'Down payment must be greater than zero';
                }
                
                final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
                if (downPayment >= totalAmount) {
                  return 'Down payment cannot be equal to or greater than total amount';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Start date field
            InkWell(
              onTap: _selectStartDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  prefixIcon: const Icon(LucideIcons.calendar),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  DateFormat('MMMM d, yyyy').format(_startDate),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Due date field
            InkWell(
              onTap: _selectDueDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  prefixIcon: const Icon(LucideIcons.calendarClock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  DateFormat('MMMM d, yyyy').format(_dueDate),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Notes field
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes (Optional)',
              prefixIcon: LucideIcons.fileText,
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            CustomButton(
              text: 'Create Installment Plan',
              isLoading: _isLoading,
              onPressed: _createInstallment,
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.mkbhdRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            title.contains('Client') 
                ? LucideIcons.users 
                : title.contains('Product') 
                    ? LucideIcons.shoppingBag 
                    : LucideIcons.wallet,
            color: AppTheme.mkbhdRed,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.mkbhdRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(int index) {
    final product = _selectedProducts[index];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.package,
              color: AppTheme.mkbhdRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Price: TSh ${NumberFormat('#,###').format(product.sellingPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.trash2,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () => _removeProduct(index),
          ),
        ],
      ),
    );
  }
}