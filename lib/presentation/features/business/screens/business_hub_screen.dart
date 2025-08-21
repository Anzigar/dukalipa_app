import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';

class BusinessHubScreen extends StatelessWidget {
  const BusinessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Business Hub',
          style: GoogleFonts.poppins(
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
            LucideIcons.arrowLeft,
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
              style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
          icon: LucideIcons.dollarSign,
          color: primaryBlue,
        ),
        _InsightCard(
          title: 'Orders',
          value: '24',
          trend: '+5',
          isPositive: true,
          icon: LucideIcons.shoppingBag,
          color: secondaryBlue,
        ),
        _InsightCard(
          title: 'Low Stock',
          value: '7',
          trend: '-2',
          isPositive: true,
          icon: LucideIcons.package,
          color: tertiaryBlue,
        ),
        _InsightCard(
          title: 'Avg. Order',
          value: '\$52',
          trend: '-3%',
          isPositive: false,
          icon: LucideIcons.receipt,
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
          icon: LucideIcons.package2,
          onTap: () => context.push('/inventory'),
          color: primaryBlue,
        ),
        _FeatureCard(
          title: 'Orders',
          description: 'Track & fulfill orders',
          icon: LucideIcons.receipt,
          onTap: () => context.push('/orders'),
          color: secondaryBlue,
        ),
        _FeatureCard(
          title: 'Storage',
          description: 'Manage locations & stock',
          icon: LucideIcons.warehouse,
          onTap: () => context.push('/business/storage'),
          color: tertiaryBlue,
        ),
        _FeatureCard(
          title: 'Damaged Products',
          description: 'Track damaged inventory',
          icon: LucideIcons.packageX,
          onTap: () => context.push('/business/damaged'),
          color: primaryBlue.withOpacity(0.8),
        ),
        _FeatureCard(
          title: 'Employees',
          description: 'Manage staff & roles',
          icon: LucideIcons.users,
          onTap: () => context.push('/employees'),
          color: secondaryBlue.withOpacity(0.8),
        ),
        _FeatureCard(
          title: 'Deleted Items',
          description: 'Recover deleted products',
          icon: LucideIcons.trash2,
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
          icon: LucideIcons.barChart3,
          onTap: () => context.push('/business/analytics'),
          color: primaryBlue,
        ),
        _FeatureCard(
          title: 'Financial Reports',
          description: 'Revenue & expenses',
          icon: LucideIcons.trendingUp,
          onTap: () => context.push('/reports/financials'),
          color: secondaryBlue,
        ),
        _FeatureCard(
          title: 'Customer Insights',
          description: 'Customer behavior & trends',
          icon: LucideIcons.userCheck,
          onTap: () => context.push('/reports/customers'),
          color: tertiaryBlue,
        ),
        _FeatureCard(
          title: 'Export Data',
          description: 'Download reports as CSV',
          icon: LucideIcons.download,
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
                    style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Electronics & Accessories',
                      style: GoogleFonts.poppins(
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
                  LucideIcons.settings,
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
                    icon: LucideIcons.package2,
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
                    icon: LucideIcons.shoppingBag,
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
                    icon: LucideIcons.creditCard,
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
                      style: GoogleFonts.poppins(
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
                      isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                      color: trendColor,
                      size: 10.sp, // Reduced size
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      trend,
                      style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
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
