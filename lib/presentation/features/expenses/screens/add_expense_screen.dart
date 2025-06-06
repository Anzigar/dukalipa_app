import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Changed from phosphor_flutter

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/expense_model.dart';
import '../repositories/expenses_repository.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  
  File? _receiptImage;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = ExpenseCategories.other;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _receiptImage = File(image.path);
      });
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.mkbhdRed,
              onPrimary: Colors.white,
              // Add these two color properties to fix calendar selection colors
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _handleAddExpense() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final repository = context.read<ExpensesRepository>();
        
        await repository.addExpense(
          amount: double.parse(_amountController.text),
          description: _descriptionController.text,
          category: _selectedCategory,
          date: _selectedDate,
          paymentMethod: _paymentMethodController.text.isNotEmpty 
              ? _paymentMethodController.text 
              : null,
          receiptImage: _receiptImage,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add expense: ${e.toString()}'),
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
  }
  
  // Updated helper method to return IconData for Lucide icons
  IconData _getLucideIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & drinks':
        return LucideIcons.coffee;
      case 'transportation':
        return LucideIcons.car;
      case 'utilities':
        return LucideIcons.lightbulb;
      case 'rent':
        return LucideIcons.home;
      case 'salary':
        return LucideIcons.dollarSign;
      case 'shopping':
        return LucideIcons.shoppingBag;
      case 'entertainment':
        return LucideIcons.film;
      case 'healthcare':
        return LucideIcons.stethoscope;
      case 'education':
        return LucideIcons.graduationCap;
      case 'taxes':
        return LucideIcons.building;
      case 'maintenance':
        return LucideIcons.wrench;
      case 'other':
      default:
        return LucideIcons.receipt;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addExpense),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft), // Changed from PhosphorIcon
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Amount field
              CustomTextField(
                controller: _amountController,
                labelText: 'Amount (TSh)',
                keyboardType: TextInputType.number,
                prefixIcon: LucideIcons.dollarSign, // Changed from PhosphorIcons.regular
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                prefixIcon: LucideIcons.text, // Changed from PhosphorIcons.regular
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category dropdown
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppTheme.mkbhdLightGrey 
                      : AppTheme.mkbhdDarkGrey,
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
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: const Text('Select Category'),
                    items: ExpenseCategories.all.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _getLucideIcon(category), // Updated helper method
                              color: AppTheme.mkbhdRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Date picker
              Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppTheme.mkbhdLightGrey 
                      : AppTheme.mkbhdDarkGrey,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
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
                        LucideIcons.calendar, // Changed from PhosphorIcon
                        color: AppTheme.mkbhdRed,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                      ),
                      const Spacer(),
                      const Icon(
                        LucideIcons.chevronDown, // Changed from PhosphorIcon
                        color: AppTheme.mkbhdLightGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Payment method field
              CustomTextField(
                controller: _paymentMethodController,
                labelText: 'Payment Method (Optional)',
                hintText: 'Cash, M-Pesa, Bank Transfer, etc.',
                prefixIcon: LucideIcons.creditCard, // Changed from PhosphorIcons.regular
              ),
              const SizedBox(height: 24),
              
              // Receipt image
              Text(
                'Receipt Image (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppTheme.mkbhdLightGrey 
                      : AppTheme.mkbhdDarkGrey,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.mkbhdLightGrey.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _receiptImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _receiptImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.receipt, // Changed from PhosphorIcon
                                color: AppTheme.mkbhdLightGrey,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add receipt image',
                                style: TextStyle(
                                  color: AppTheme.mkbhdLightGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit button
              CustomButton(
                text: 'Add Expense',
                isLoading: _isLoading,
                onPressed: _handleAddExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
