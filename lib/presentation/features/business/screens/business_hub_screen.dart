import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BusinessHubScreen extends StatelessWidget {
  const BusinessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Business Hub'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with business overview
            const _BusinessOverview(),
            const SizedBox(height: 32),
            
            // Quick insights
            const Text(
              'Quick Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickInsights(),
            const SizedBox(height: 32),
            
            // Business features section
            const Text(
              'Business Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildBusinessFeatures(context),
            const SizedBox(height: 32),
            
            // Reports and analytics
            const Text(
              'Reports & Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildReportFeatures(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsights() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        _InsightCard(
          title: 'Sales Today',
          value: '\$1,245',
          trend: '+12%',
          isPositive: true,
          icon: Icons.attach_money_rounded,
          color: Colors.green,
        ),
        _InsightCard(
          title: 'Orders',
          value: '24',
          trend: '+5',
          isPositive: true,
          icon: Icons.shopping_bag_outlined,
          color: Colors.blue,
        ),
        _InsightCard(
          title: 'Low Stock',
          value: '7',
          trend: '-2',
          isPositive: true,
          icon: Icons.inventory_2_outlined,
          color: Colors.orange,
        ),
        _InsightCard(
          title: 'Avg. Order',
          value: '\$52',
          trend: '-3%',
          isPositive: false,
          icon: Icons.receipt_long_outlined,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildBusinessFeatures(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _FeatureCard(
          title: 'Inventory',
          description: 'Manage your products',
          icon: Icons.inventory,
          onTap: () => context.push('/inventory'),
        ),
        _FeatureCard(
          title: 'Orders',
          description: 'Track & fulfill orders',
          icon: Icons.receipt_long,
          onTap: () => context.push('/orders'),
        ),
        _FeatureCard(
          title: 'Storage',
          description: 'Manage locations & stock',
          icon: Icons.warehouse,
          onTap: () => context.push('/business/storage'),
          color: Colors.amber,
        ),
        _FeatureCard(
          title: 'Damaged Products',
          description: 'Track damaged inventory',
          icon: Icons.inventory_2,
          onTap: () => context.push('/business/damaged'),
          color: Colors.orange,
        ),
        _FeatureCard(
          title: 'Employees',
          description: 'Manage staff & roles',
          icon: Icons.people,
          onTap: () => context.push('/employees'),
          color: Colors.teal,
        ),
        _FeatureCard(
          title: 'Deleted Items',
          description: 'Recover deleted products',
          icon: Icons.delete_outline,
          onTap: () => context.push('/business/deleted'),
          color: Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildReportFeatures(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _FeatureCard(
          title: 'Sales Analytics',
          description: 'View sales performance',
          icon: Icons.analytics,
          onTap: () => context.push('/business/analytics'),
          color: Colors.blue,
        ),
        _FeatureCard(
          title: 'Financial Reports',
          description: 'Revenue & expenses',
          icon: Icons.bar_chart,
          onTap: () => context.push('/reports/financials'),
          color: Colors.green,
        ),
        _FeatureCard(
          title: 'Customer Insights',
          description: 'Customer behavior & trends',
          icon: Icons.people_alt_outlined,
          onTap: () => context.push('/reports/customers'),
          color: Colors.purple,
        ),
        _FeatureCard(
          title: 'Export Data',
          description: 'Download reports as CSV',
          icon: Icons.download,
          onTap: () => context.push('/reports/export'),
          color: Colors.indigo,
        ),
      ],
    );
  }
}

class _BusinessOverview extends StatelessWidget {
  const _BusinessOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Shop info
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'DS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dukalipa Shop',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Electronics & Accessories',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    // Navigate to shop settings
                  },
                  icon: const Icon(Icons.settings_outlined),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Stats overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    value: '348',
                    label: 'Total Products',
                    icon: Icons.inventory_2_outlined,
                    onTap: () {},
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                Expanded(
                  child: _StatItem(
                    value: '125',
                    label: 'Active Orders',
                    icon: Icons.shopping_bag_outlined,
                    onTap: () {},
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                Expanded(
                  child: _StatItem(
                    value: '\$12.4k',
                    label: 'Monthly Revenue',
                    icon: Icons.payments_outlined,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isPositive 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: cardColor,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
