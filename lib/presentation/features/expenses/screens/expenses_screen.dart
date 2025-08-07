import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart'; 
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/expenses_service.dart';
import '../providers/expenses_provider.dart';
import '../../../common/widgets/custom_search_bar.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../../core/di/service_locator.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  
  late ExpensesProvider _provider;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProvider();
      _fetchExpenses();
    });
  }
  
  void _initProvider() {
    try {
      // Try to get the provider from the context first
      _provider = Provider.of<ExpensesProvider>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance
      _provider = locator<ExpensesProvider>();
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Use the provider to load expenses
      await _provider.loadExpenses(
        refresh: true,
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      if (mounted) {
        setState(() {
          _expenses = _provider.expenses;
          _isLoading = false;
          _hasError = _provider.error != null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }
  
  void _onSearch(String query) {
    if (query.isEmpty) {
      _fetchExpenses();
    } else {
      _provider.searchExpenses(query);
      setState(() {
        _expenses = _provider.expenses;
      });
    }
  }
  
  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchExpenses();
  }
  
  Future<void> _showDateRangeDialog() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      end: _endDate ?? DateTime.now(),
    );
    
    final dateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
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
    
    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
      _fetchExpenses();
    }
  }
  
  double get _totalExpenses => 
    _expenses.fold(0, (total, expense) => total + expense.amount);
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenses),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarDays), // Changed from PhosphorIcon
            onPressed: _showDateRangeDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: const Icon(LucideIcons.barChart2), // Changed from PhosphorIcon
            onPressed: () {
              // Show expense analytics
            },
            tooltip: 'Analytics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date filter chip
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(
                      LucideIcons.x, // Changed from PhosphorIcon
                      size: 16,
                    ),
                    onDeleted: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _fetchExpenses();
                    },
                    backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                    deleteIconColor: AppTheme.mkbhdRed,
                    labelStyle: const TextStyle(color: AppTheme.mkbhdRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: l10n.search,
              onSearch: _onSearch,
            ),
          ),
          
          // Category filters
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                FilterChip(
                  label: Text(l10n.all),
                  selected: _selectedCategory == null,
                  selectedColor: AppTheme.mkbhdRed,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedCategory == null ? Colors.white : null,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _onCategorySelected(null);
                    }
                  },
                ),
                ...ExpenseCategories.all.map((category) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    selectedColor: AppTheme.mkbhdRed,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.white : null,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _onCategorySelected(category);
                      } else {
                        _onCategorySelected(null);
                      }
                    },
                  ),
                )),
              ],
            ),
          ),
          
          // Expenses summary
          if (!_isLoading && !_hasError && _expenses.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.mkbhdRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Expenses',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TSh ${_totalExpenses.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Number of Expenses',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_expenses.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Expenses list
          Expanded(
            child: _buildExpensesList(l10n),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/expenses/add'),
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.addExpense),
      ),
    );
  }
  
  Widget _buildExpensesList(AppLocalizations l10n) {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => const ExpenseCardShimmer(),
      );
    }
    
    if (_hasError) {
      return RefreshIndicator(
        onRefresh: _fetchExpenses,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.alertTriangle, // Changed from PhosphorIcon
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchExpenses,
                    icon: const Icon(LucideIcons.refreshCw), // Changed from PhosphorIcon
                    label: Text(l10n.retry),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    if (_expenses.isEmpty) {
      return EmptyState(
        icon: LucideIcons.receipt, // Changed from PhosphorIcons.regular.receipt
        title: 'No Expenses Found',
        message: 'Add your first expense to get started',
        buttonText: l10n.addExpense,
        onButtonPressed: () => context.push('/expenses/add'),
      );
    }
    
    // Group expenses by date
    final groupedExpenses = <String, List<ExpenseModel>>{};
    for (final expense in _expenses) {
      final key = expense.monthYear;
      if (groupedExpenses.containsKey(key)) {
        groupedExpenses[key]!.add(expense);
      } else {
        groupedExpenses[key] = [expense];
      }
    }
    
    return RefreshIndicator(
      onRefresh: _fetchExpenses,
      child: ListView.builder(
        controller: _scrollController, // Add scroll controller
        key: const PageStorageKey<String>('expenses_list'), // Add key to preserve state
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: groupedExpenses.length,
        itemBuilder: (context, index) {
          final monthYear = groupedExpenses.keys.elementAt(index);
          final expenses = groupedExpenses[monthYear]!;
          final totalForMonth = expenses.fold<double>(
            0, (sum, expense) => sum + expense.amount
          );
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      monthYear,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total: TSh ${totalForMonth.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.mkbhdRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...expenses.map((expense) => ExpenseCard(
                expense: expense,
                onTap: () => context.push('/expenses/${expense.id}'),
              )),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
  
  // Add this override to maintain widget state
  @override
  bool get wantKeepAlive => true;
}

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;
  
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode 
              ? Colors.grey.shade700
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.mkbhdRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getLucideIcon(expense.category),
                  color: AppTheme.mkbhdRed,
                ),
              ),
              const SizedBox(width: 16),
              // Expense details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description ?? expense.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expense.category,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          expense.formattedDate,
                          style: const TextStyle(
                            color: AppTheme.mkbhdLightGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                expense.formattedAmount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.mkbhdRed,
                ),
              ),
              // Edit button
              IconButton(
                icon: const Icon(LucideIcons.pencil), // Changed from PhosphorIcon
                onPressed: onTap,
                color: AppTheme.mkbhdLightGrey,
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Updated to return IconData instead of PhosphorIconData
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
}
