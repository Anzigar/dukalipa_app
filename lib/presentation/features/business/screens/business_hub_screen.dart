import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BusinessHubScreen extends StatelessWidget {
  const BusinessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Business Hub',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            // Header with business overview
            const _BusinessOverview(),
            SizedBox(height: 24.h),
            
            // Quick insights
            Text(
              'Quick Insights',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            _buildQuickInsights(context),
            SizedBox(height: 24.h),
            
            // Business features section
            Text(
              'Business Management',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            _buildBusinessFeatures(context),
            SizedBox(height: 24.h),
            
            // Reports and analytics
            Text(
              'Reports & Analytics',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            _buildReportFeatures(context),
            SizedBox(height: 32.h),
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
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.3, // Increased for more space
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
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.4, // Increased ratio to prevent overflow
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
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.4, // Increased ratio to prevent overflow
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Shop info
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
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
                child: Center(
                  child: Text(
                    'DS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dukalipa Shop',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Electronics & Accessories',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Stats overview
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    value: '348',
                    label: 'Total Products',
                    icon: Icons.inventory_2_rounded,
                    onTap: () {},
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 40.h,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                ),
                Expanded(
                  child: _StatItem(
                    value: '125',
                    label: 'Active Orders',
                    icon: Icons.shopping_bag_rounded,
                    onTap: () {},
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 40.h,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                ),
                Expanded(
                  child: _StatItem(
                    value: '\$12.4k',
                    label: 'Monthly Revenue',
                    icon: Icons.payments_rounded,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
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
        ? Colors.green
        : Colors.red;
        
    return Container(
      padding: EdgeInsets.all(12.w), // Reduced padding
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6.w), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18.sp, // Reduced size
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 2.h, // Reduced padding
                  horizontal: 6.w,
                ),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: trendColor,
                      size: 10.sp, // Reduced size
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10.sp, // Reduced size
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h), // Reduced spacing
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12.sp, // Reduced size
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2.h), // Reduced spacing
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18.sp, // Reduced size
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w), // Reduced padding
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    color: cardColor,
                    size: 20.sp, // Reduced size
                  ),
                ),
                SizedBox(height: 8.h), // Reduced spacing
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp, // Reduced size
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 2.h), // Reduced spacing
                Flexible(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 11.sp, // Reduced size
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
