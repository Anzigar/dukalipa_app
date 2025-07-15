import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';
import '../providers/expenses_provider.dart';
import '../../../common/widgets/shimmer_loading.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final String expenseId;
  
  const ExpenseDetailsScreen({
    Key? key,
    required this.expenseId,
  }) : super(key: key);

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  ExpenseModel? _expense;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchExpense();
    });
  }
  
  Future<void> _fetchExpense() async {
    final provider = Provider.of<ExpensesProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Try to find the expense in the provider's list first
      final expenses = provider.expenses;
      final foundExpenseIndex = expenses.indexWhere(
        (expense) => expense.id == widget.expenseId,
      );
      
      if (foundExpenseIndex == -1) {
        throw Exception('Expense not found');
      }
      
      final foundExpense = expenses[foundExpenseIndex];
      
      setState(() {
        _expense = foundExpense as ExpenseModel?;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load expense details: ${e.toString()}';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const TransactionCardShimmer();
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load expense details',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchExpense,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_expense == null) {
      return const Center(
        child: Text('Expense not found'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpenseCard(),
          const SizedBox(height: 24),
          _buildDetailsSection(),
        ],
      ),
    );
  }
  
  Widget _buildExpenseCard() {
    final expense = _expense!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    expense.description,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    expense.category,
                    style: TextStyle(
                      color: _getCategoryColor(expense.category),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  LucideIcons.banknote,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'TSh ${expense.formattedAmount}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (expense.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                expense.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailsSection() {
    final expense = _expense!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: LucideIcons.calendar,
              label: 'Date',
              value: expense.formattedDate,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: LucideIcons.user,
              label: 'Category',
              value: expense.category,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: LucideIcons.clock,
              label: 'Created At',
              value: DateFormat('MMM d, yyyy h:mm a').format(expense.createdAt),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Colors.blue;
      case 'utilities':
        return Colors.orange;
      case 'supplies':
        return Colors.green;
      case 'transport':
        return Colors.purple;
      case 'marketing':
        return Colors.red;
      case 'maintenance':
        return Colors.brown;
      case 'insurance':
        return Colors.indigo;
      case 'miscellaneous':
        return Colors.grey;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
