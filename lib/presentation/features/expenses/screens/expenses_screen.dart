import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart'; 
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/expenses_service.dart';
import '../providers/expenses_provider.dart';
import '../../../common/widgets/animated_empty_state.dart';
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
      _provider = Provider.of<ExpensesProvider>(context, listen: false);
    } catch (e) {
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
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
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
    
    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
      _fetchExpenses();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasExpenses = _expenses.isNotEmpty;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Expenses',
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
        actions: [
          IconButton(
            icon: Icon(LucideIcons.calendarDays, size: 20.sp),
            onPressed: _showDateRangeDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: Icon(LucideIcons.plus, size: 20.sp),
            onPressed: () => context.push('/expenses/add'),
            tooltip: 'Add expense',
          ),
        ],
        // Only show search and filter when there are expenses
        bottom: hasExpenses ? PreferredSize(
          preferredSize: Size.fromHeight(100.h),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              SizedBox(height: 10.h),
            ],
          ),
        ) : null,
      ),
      body: _isLoading 
          ? _buildLoadingState()
          : _hasError 
              ? _buildErrorState()
              : hasExpenses 
                  ? _buildExpensesList()
                  : _buildEmptyState(),
      floatingActionButton: hasExpenses ? FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/add'),
        backgroundColor: AppTheme.mkbhdRed,
        foregroundColor: Colors.white,
        icon: Icon(LucideIcons.plus, size: 20.sp),
        label: Text(
          'Add Expense',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ) : null,
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          hintStyle: GoogleFonts.poppins(
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            size: 20.sp,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    size: 20.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = ['All', 'Office', 'Marketing', 'Transport', 'Utilities', 'Other'];
    
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category || (_selectedCategory == null && category == 'All');
          
          return Container(
            margin: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                _onCategorySelected(category == 'All' ? null : category);
              },
              backgroundColor: colorScheme.surface,
              selectedColor: AppTheme.mkbhdRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: AnimatedLoadingState.general(
        message: 'Loading expenses...',
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 48.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error loading expenses',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please try again later',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: _fetchExpenses,
            icon: Icon(LucideIcons.refreshCw, size: 20.sp),
            label: Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.mkbhdRed,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedEmptyState.expenses(
      title: 'No Expenses Recorded',
      message: 'Track your business expenses to monitor cash flow and manage budgets effectively.',
      buttonText: 'Add Expense',
      onButtonPressed: () => context.push('/expenses/add'),
    );
  }

  Widget _buildExpensesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        return _buildExpenseCard(_expenses[index]);
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/expenses/${expense.id}'),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(expense.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        _getCategoryIcon(expense.category),
                        color: _getCategoryColor(expense.category),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            expense.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TZS ${NumberFormat('#,###').format(expense.amount)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          DateFormat('MMM d, yyyy').format(expense.date),
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (expense.description != null && expense.description!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    expense.description!,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'office':
        return Colors.blue;
      case 'marketing':
        return Colors.green;
      case 'transport':
        return Colors.orange;
      case 'utilities':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'office':
        return LucideIcons.building;
      case 'marketing':
        return LucideIcons.megaphone;
      case 'transport':
        return LucideIcons.car;
      case 'utilities':
        return LucideIcons.zap;
      default:
        return LucideIcons.receipt;
    }
  }
}
