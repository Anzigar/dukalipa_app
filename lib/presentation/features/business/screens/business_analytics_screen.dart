import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../home/providers/analytics_provider.dart';
import '../../../common/widgets/shimmer_loading.dart';

class BusinessAnalyticsScreen extends StatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  State<BusinessAnalyticsScreen> createState() => _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends State<BusinessAnalyticsScreen> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year'];
  Set<String> _selectedMetrics = {'revenue'}; // For segmented button

  @override
  void initState() {
    super.initState();
    // Load analytics data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
      analyticsProvider.loadAnalytics();
      analyticsProvider.loadInventorySummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Material 3 styled period selector
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: MenuAnchor(
              builder: (context, controller, child) {
                return FilledButton.tonalIcon(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Text(_selectedPeriod),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
                    foregroundColor: AppTheme.mkbhdRed,
                  ),
                );
              },
              menuChildren: _periods.map((period) => 
                MenuItemButton(
                  onPressed: () => setState(() => _selectedPeriod = period),
                  child: Text(period),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Material 3 Segmented Button for metric selection
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'revenue',
                      label: Text('Revenue'),
                      icon: Icon(Icons.attach_money_rounded),
                    ),
                    ButtonSegment<String>(
                      value: 'orders',
                      label: Text('Orders'),
                      icon: Icon(Icons.shopping_cart_outlined),
                    ),
                    ButtonSegment<String>(
                      value: 'customers',
                      label: Text('Customers'),
                      icon: Icon(Icons.people_outline),
                    ),
                  ],
                  selected: _selectedMetrics,
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedMetrics = newSelection;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    selectedBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    selectedForegroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Key Metrics Row - Updated to consume analytics data
                Consumer<AnalyticsProvider>(
                  builder: (context, analyticsProvider, _) {
                    if (analyticsProvider.isLoadingAnalytics || analyticsProvider.isLoadingDashboard) {
                      return const DashboardShimmer();
                    }
                    
                    if (analyticsProvider.hasError) {
                      return Card(
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                              const SizedBox(height: 8),
                              Text('Failed to load analytics', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => analyticsProvider.loadAnalytics(forceRefresh: true),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    final metrics = analyticsProvider.dashboardMetrics;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Revenue',
                                value: analyticsProvider.getFormattedCurrency(metrics?.totalRevenue ?? 0),
                                change: '+12.5%', // Could be calculated from historical data
                                isPositive: true,
                                icon: Icons.trending_up,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MetricCard(
                                title: 'Orders',
                                value: '${metrics?.totalSales ?? 0}',
                                change: '+8.2%',
                                isPositive: true,
                                icon: Icons.shopping_cart_outlined,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Profit',
                                value: analyticsProvider.getFormattedCurrency(metrics?.totalProfit ?? 0),
                                change: '+15.3%',
                                isPositive: true,
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MetricCard(
                                title: 'Products',
                                value: '${analyticsProvider.totalProductsCount}',
                                change: analyticsProvider.inventorySummary['low_stock_count'] != null 
                                    ? '${analyticsProvider.inventorySummary['low_stock_count']} low stock'
                                    : 'No issues',
                                isPositive: (analyticsProvider.inventorySummary['low_stock_count'] ?? 0) == 0,
                                icon: Icons.inventory_2_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Sales Chart Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.mkbhdLightGrey.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sales Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.mkbhdLightGrey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Chart Placeholder\n(Sales data visualization)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.mkbhdLightGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Top Products Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.mkbhdLightGrey.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child:  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'Top Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20),
                      _ProductRankItem(rank: 1, name: 'Product A', sales: 145, revenue: '\$2,340'),
                      _ProductRankItem(rank: 2, name: 'Product B', sales: 128, revenue: '\$1,920'),
                      _ProductRankItem(rank: 3, name: 'Product C', sales: 97, revenue: '\$1,455'),
                      _ProductRankItem(rank: 4, name: 'Product D', sales: 84, revenue: '\$1,260'),
                      _ProductRankItem(rank: 5, name: 'Product E', sales: 72, revenue: '\$1,080'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.mkbhdLightGrey.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mkbhdRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.secondary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isPositive 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.secondary).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.mkbhdLightGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRankItem extends StatelessWidget {
  final int rank;
  final String name;
  final int sales;
  final String revenue;

  const _ProductRankItem({
    required this.rank,
    required this.name,
    required this.sales,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppTheme.mkbhdRed.withOpacity(0.1) : AppTheme.mkbhdLightGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: rank <= 3 ? AppTheme.mkbhdRed : AppTheme.mkbhdLightGrey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$sales sales',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mkbhdLightGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            revenue,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
