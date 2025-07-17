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
            _buildQuickInsights(context),
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

  Widget _buildQuickInsights(BuildContext context) {
    final primaryBlue = Theme.of(context).colorScheme.primary;
    final secondaryBlue = Theme.of(context).colorScheme.secondary;
    final tertiaryBlue = Theme.of(context).colorScheme.tertiary;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2, // Adjusted for better proportions
      children: [
        _InsightCard(
          title: 'Sales Today',
          value: '\$1,245',
          trend: '+12%',
          isPositive: true,
          icon: Icons.attach_money_rounded,
          color: primaryBlue,
        ),
        _InsightCard(
          title: 'Orders',
          value: '24',
          trend: '+5',
          isPositive: true,
          icon: Icons.shopping_bag_outlined,
          color: secondaryBlue,
        ),
        _InsightCard(
          title: 'Low Stock',
          value: '7',
          trend: '-2',
          isPositive: true,
          icon: Icons.inventory_2_outlined,
          color: tertiaryBlue,
        ),
        _InsightCard(
          title: 'Avg. Order',
          value: '\$52',
          trend: '-3%',
          isPositive: false,
          icon: Icons.receipt_long_outlined,
          color: primaryBlue.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildBusinessFeatures(BuildContext context) {
    final primaryBlue = Theme.of(context).colorScheme.primary;
    final secondaryBlue = Theme.of(context).colorScheme.secondary;
    final tertiaryBlue = Theme.of(context).colorScheme.tertiary;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2, // Increased ratio to prevent overflow
      children: [
        _FeatureCard(
          title: 'Inventory',
          description: 'Manage your products',
          icon: Icons.inventory,
          onTap: () => context.push('/inventory'),
          color: primaryBlue,
        ),
        _FeatureCard(
          title: 'Orders',
          description: 'Track & fulfill orders',
          icon: Icons.receipt_long,
          onTap: () => context.push('/orders'),
          color: secondaryBlue,
        ),
        _FeatureCard(
          title: 'Storage',
          description: 'Manage locations & stock',
          icon: Icons.warehouse,
          onTap: () => context.push('/business/storage'),
          color: tertiaryBlue,
        ),
        _FeatureCard(
          title: 'Damaged Products',
          description: 'Track damaged inventory',
          icon: Icons.inventory_2,
          onTap: () => context.push('/business/damaged'),
          color: primaryBlue.withOpacity(0.8),
        ),
        _FeatureCard(
          title: 'Employees',
          description: 'Manage staff & roles',
          icon: Icons.people,
          onTap: () => context.push('/employees'),
          color: secondaryBlue.withOpacity(0.8),
        ),
        _FeatureCard(
          title: 'Deleted Items',
          description: 'Recover deleted products',
          icon: Icons.delete_outline,
          onTap: () => context.push('/business/deleted'),
          color: tertiaryBlue.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildReportFeatures(BuildContext context) {
    final primaryBlue = Theme.of(context).colorScheme.primary;
    final secondaryBlue = Theme.of(context).colorScheme.secondary;
    final tertiaryBlue = Theme.of(context).colorScheme.tertiary;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2, // Increased ratio to prevent overflow
      children: [
        _FeatureCard(
          title: 'Sales Analytics',
          description: 'View sales performance',
          icon: Icons.analytics,
          onTap: () => context.push('/business/analytics'),
          color: primaryBlue,
        ),
        _FeatureCard(
          title: 'Financial Reports',
          description: 'Revenue & expenses',
          icon: Icons.bar_chart,
          onTap: () => context.push('/reports/financials'),
          color: secondaryBlue,
        ),
        _FeatureCard(
          title: 'Customer Insights',
          description: 'Customer behavior & trends',
          icon: Icons.people_alt_outlined,
          onTap: () => context.push('/reports/customers'),
          color: tertiaryBlue,
        ),
        _FeatureCard(
          title: 'Export Data',
          description: 'Download reports as CSV',
          icon: Icons.download,
          onTap: () => context.push('/reports/export'),
          color: primaryBlue.withOpacity(0.8),
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
    final trendColor = isPositive 
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary.withOpacity(0.8);
        
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
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
        mainAxisSize: MainAxisSize.min, // Prevent overflow
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20, // Reduced icon size
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4, // Reduced padding
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: trendColor,
                      size: 12, // Reduced icon size
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 11, // Reduced font size
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced spacing
          Flexible( // Use Flexible to prevent overflow
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13, // Reduced font size
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible( // Use Flexible to prevent overflow
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20, // Reduced font size
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsets.all(16), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Reduced padding
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: cardColor,
                    size: 22, // Reduced icon size
                  ),
                ),
                const SizedBox(height: 12), // Reduced spacing
                Flexible( // Use Flexible to prevent overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15, // Slightly reduced font size
                          height: 1.2, // Reduced line height
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12, // Reduced font size
                          height: 1.3, // Better line height
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
