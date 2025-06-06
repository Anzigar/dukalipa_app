import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/installment_model.dart';
import '../repositories/installment_repository.dart';
import '../repositories/installment_repository_impl.dart' as impl;
import '../../../../core/network/api_client.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';

class AddPaymentScreen extends StatefulWidget {
  final String installmentId;
  final InstallmentModel? installment; // Optional model if already available

  const AddPaymentScreen({
    Key? key,
    required this.installmentId,
    this.installment,
  }) : super(key: key);

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _amountController = TextEditingController();
  final _receiptNumberController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _paymentMethod = 'Cash';
  DateTime _paymentDate = DateTime.now();
  
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  
  InstallmentModel? _installment;
  late InstallmentRepository _repository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _loadInstallment();
    });
  }

  void _initRepository() {
    try {
      _repository = Provider.of<InstallmentRepository>(context, listen: false);
    } catch (e) {
      final apiClient = ApiClient();
      _repository = impl.InstallmentRepositoryImpl(apiClient);
    }
  }

  Future<void> _loadInstallment() async {
    if (widget.installment != null) {
      setState(() {
        _installment = widget.installment;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final installment = await _repository.getInstallmentById(widget.installmentId);
      
      if (mounted) {
        setState(() {
          _installment = installment;
          _isLoading = false;
          
          // Set default amount to remaining amount
          _amountController.text = installment.remainingAmount.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _receiptNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_installment == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Installment information not available';
      });
      return;
    }
    
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment amount must be greater than zero')),
      );
      return;
    }
    
    if (amount > _installment!.remainingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment amount cannot exceed the remaining amount')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      await _repository.addInstallmentPayment(
        installmentId: widget.installmentId,
        amount: amount,
        paymentDate: _paymentDate,
        paymentMethod: _paymentMethod,
        receiptNumber: _receiptNumberController.text,
        notes: _notesController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to installment details
        context.pop(true); // Return true to indicate success
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
            content: Text('Failed to add payment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectPaymentDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        _paymentDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent(isDarkMode),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_hasError) {
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
              _errorMessage ?? 'An error occurred while loading the installment',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadInstallment,
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

    if (_installment == null) {
      return const Center(child: Text('Installment not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Installment info card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.user,
                          color: AppTheme.mkbhdRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _installment!.clientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _installment!.clientPhone,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.mkbhdLightGrey,
                              ),
                            ),
                            Text(
                              _installment!.formattedTotalAmount,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Remaining',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.mkbhdLightGrey,
                              ),
                            ),
                            Text(
                              _installment!.formattedRemainingAmount,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _installment!.isOverdue 
                                    ? Colors.red 
                                    : AppTheme.mkbhdRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Payment Progress',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.mkbhdLightGrey,
                              ),
                            ),
                            Text(
                              '${_installment!.percentagePaid.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _installment!.paymentProgress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _installment!.isOverdue ? Colors.orange : AppTheme.mkbhdRed,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment details section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    LucideIcons.wallet,
                    color: AppTheme.mkbhdRed,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.mkbhdRed,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Amount field
            CustomTextField(
              controller: _amountController,
              labelText: 'Payment Amount (TSh)*',
              hintText: 'Enter amount',
              prefixIcon: LucideIcons.dollarSign,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                final amount = double.parse(value);
                if (amount <= 0) {
                  return 'Amount must be greater than zero';
                }
                if (amount > _installment!.remainingAmount) {
                  return 'Amount cannot exceed remaining balance';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Payment method dropdown
            const Text(
              'Payment Method*',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppTheme.mkbhdLightGrey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.mkbhdLightGrey.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _paymentMethod,
                  isExpanded: true,
                  items: [
                    'Cash',
                    'Mobile Money',
                    'Bank Transfer',
                    'Cheque',
                    'Card',
                    'Other',
                  ].map((method) => DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _paymentMethod = value;
                      });
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment date picker
            const Text(
              'Payment Date*',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppTheme.mkbhdLightGrey,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectPaymentDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.mkbhdLightGrey.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      color: AppTheme.mkbhdRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMMM d, yyyy').format(_paymentDate),
                    ),
                    const Spacer(),
                    const Icon(
                      LucideIcons.chevronDown,
                      color: AppTheme.mkbhdLightGrey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Receipt number field
            CustomTextField(
              controller: _receiptNumberController,
              labelText: 'Receipt Number (Optional)',
              hintText: 'Enter receipt or reference number',
              prefixIcon: LucideIcons.fileText,
            ),
            
            const SizedBox(height: 16),
            
            // Notes field
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes (Optional)',
              hintText: 'Add any additional information',
              prefixIcon: LucideIcons.clipboard, // Changed from clipboardText to clipboard
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            CustomButton(
              text: 'Add Payment',
              isLoading: _isLoading,
              onPressed: _addPayment,
              icon: LucideIcons.plus,
              // variant: ButtonVariant.primary, // Removed invalid parameter
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
