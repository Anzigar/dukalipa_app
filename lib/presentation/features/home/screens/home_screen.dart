import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Add this import
import 'package:lottie/lottie.dart';
import 'package:dukalipa_app/core/providers/auth_provider.dart';
import 'package:dukalipa_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../providers/analytics_provider.dart';
import '../providers/recent_activity_provider.dart';


// Define ActionItem class for menu items
class ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final String? badge;

  ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconColor,
    this.badge,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _chartPageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showCompactActions = false;
  
  // Animation controller for loading animation
  late AnimationController _loadingController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initialize loading animation controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Start loading data
    _startLoading();
    
    // Load analytics data including inventory
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
    _loadingController.repeat();
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
    _loadingController.stop();
  }

  void _loadAnalyticsData() async {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    final activityProvider = Provider.of<RecentActivityProvider>(context, listen: false);
    
    try {
      await Future.wait([
        analyticsProvider.loadInventorySummary(),
        activityProvider.loadRecentActivities(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      // Stop loading animation when data is loaded
      _stopLoading();
    }
  }

  Future<void> _refreshData() async {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    final activityProvider = Provider.of<RecentActivityProvider>(context, listen: false);
    
    await Future.wait([
      analyticsProvider.loadInventorySummary(),
      activityProvider.loadRecentActivities(),
    ]);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final isScrollingDown = _scrollController.position.userScrollDirection == ScrollDirection.reverse;
    final isScrollingUp = _scrollController.position.userScrollDirection == ScrollDirection.forward;
    
    if ((offset > 120 && isScrollingUp && !_showCompactActions) || 
        (offset < 80 && isScrollingDown && _showCompactActions)) {
      setState(() {
        _showCompactActions = offset > 80 && isScrollingUp;
      });
    }
  }

  void _openBarcodeScanner() {
    context.push('/barcode-scanner');
  }

  @override
  void dispose() {
    _chartPageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _loadingController.dispose(); // Dispose animation controller
    super.dispose();
  }

  void _navigateToSearch() {
    // Navigate to search screen with proper functionality
    debugPrint('🔍 Navigating to search screen...');
    debugPrint('🔍 Current route: ${GoRouter.of(context).routerDelegate.currentConfiguration}');
    try {
      context.push('/search');
      debugPrint('✅ Navigation to search screen successful');
    } catch (e) {
      debugPrint('❌ Navigation to search screen failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<AuthProvider>(context, listen: false).userProfile;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading 
          ? const DashboardShimmer()
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                // iOS-style SliverAppBar with clean, minimal design
                SliverAppBar(
                  expandedHeight: 180,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SafeArea(
                        child: Column(
                          children: [
                            // iOS-style header with clean typography
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getGreeting(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        profile?.name ?? 'Shop Owner',
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).colorScheme.onSurface,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _buildIOSActionButton(
                                        icon: LucideIcons.bell,
                                        onPressed: () => context.push('/notifications'),
                                        hasNotification: true,
                                      ),
                                      const SizedBox(width: 12),
                                      _buildIOSProfileAvatar(profile),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // iOS-style search bar
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: _buildIOSSearchBar(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Main content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Today's Summary Card - Meta style
                      _buildTodaySummaryCard(context, profile),
                      
                      // Business Metrics - Grid layout
                      _buildMetricsGrid(),
                      
                      // Recent Activity
                      _buildRecentActivitySection(),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        // Handle navigation tap
        switch (index) {
          case 0:
            // Already on home, do nothing
            break;
          case 1:
            context.push('/sales');
            break;
          case 2:
            context.push('/inventory');
            break;
          case 3:
            context.push('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.shoppingCart),
          label: 'Sales',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.package),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.user),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      elevation: 8,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildIOSActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool hasNotification = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, size: 20.sp),
            onPressed: onPressed,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            padding: EdgeInsets.zero,
          ),
        ),
        if (hasNotification)
          Positioned(
            right: 6.w,
            top: 6.h,
            child: Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIOSProfileAvatar(profile) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            profile?.name?.isNotEmpty == true 
                ? profile!.name![0].toUpperCase() 
                : 'U',
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSSearchBar() {
    return Container(
      height: 48.h, // Increased height for Material3 design
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r), // Fully rounded like Material3
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Search area with Material3 style
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24.r),
                onTap: _navigateToSearch,
                splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Search products, sales, customers...',
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Barcode scanner button with Material3 style
          Container(
            width: 44.w,
            height: 44.h,
            margin: EdgeInsets.only(right: 2.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(22.r), // Circular for Material3
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22.r),
                onTap: _openBarcodeScanner,
                splashColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                child: Icon(
                  LucideIcons.scanLine,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummaryCard(BuildContext context, profile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: [
          // iOS-style main revenue card - clean and minimal
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // iOS-style header - clean text hierarchy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Revenue',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Simple percentage indicator
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '+15%',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Main amount - iOS typography
                Text(
                  'TSh 245,000',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                // Comparison text
                Text(
                  'vs TSh 213,000 yesterday',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // iOS-style metrics row
          Row(
            children: [
              Expanded(
                child: _buildIOSStatCard('Orders', '32', 'today'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Consumer<AnalyticsProvider>(
                  builder: (context, analyticsProvider, _) {
                    return _buildIOSStatCard(
                      'Products', 
                      '${analyticsProvider.totalStockQuantity}', 
                      'total stock'
                    );
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildIOSStatCard('Customers', '24', 'active'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // iOS-style stat card: clean, minimal design
  Widget _buildIOSStatCard(String label, String value, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main value - clean and prominent
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 2.h),
          // Label
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMetricsGrid() {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Business Overview',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth = (constraints.maxWidth - 12.w) / 2;
                  double cardHeight = 92.h; // Increased height slightly
                  double aspectRatio = cardWidth / cardHeight;
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: aspectRatio,
                    children: [
                      _buildIOSMetricCard(
                        title: 'Total Stock',
                        value: analyticsProvider.getFormattedCurrency(analyticsProvider.totalStockValue),
                        icon: LucideIcons.package,
                        color: Theme.of(context).colorScheme.primary,
                        subtitle: '${analyticsProvider.totalProductsCount} items',
                        onTap: () => context.push('/inventory'),
                      ),
                      _buildIOSMetricCard(
                        title: 'Low Stock',
                        value: '${analyticsProvider.inventorySummary['low_stock_count'] ?? 0}',
                        icon: LucideIcons.alertCircle,
                        color: Theme.of(context).colorScheme.error,
                        subtitle: 'need attention',
                        onTap: () => context.push('/inventory/low-stock'),
                      ),
                      _buildIOSMetricCard(
                        title: 'Active Debts',
                        value: 'TSh 120K',
                        icon: LucideIcons.banknote,
                        color: Theme.of(context).colorScheme.secondary,
                        subtitle: '2 pending',
                        onTap: () => context.push('/debts'),
                      ),
                      _buildIOSMetricCard(
                        title: 'Customers',
                        value: '156',
                        icon: LucideIcons.users,
                        color: Theme.of(context).colorScheme.tertiary,
                        subtitle: '+8 this week',
                        onTap: () => context.push('/customers'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIOSMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w), // Reduced padding
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 28.w, // Slightly smaller icon container
              height: 28.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16.sp, // Smaller icon
              ),
            ),
            SizedBox(width: 10.w), // Reduced spacing
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Consumer<RecentActivityProvider>(
      builder: (context, activityProvider, child) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/activity'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'See all',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: activityProvider.isLoadingActivities
                    ? _buildLoadingActivities()
                    : activityProvider.recentActivities.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: _buildEmptyActivities(),
                          )
                        : _buildActivitiesList(activityProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingActivities() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: List.generate(3, (index) {
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 120.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (index < 2) ...[
                SizedBox(height: 16.h),
                _buildIOSActivityDivider(),
                SizedBox(height: 16.h),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyActivities() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100.w,
            height: 100.w,
            child: Lottie.asset(
              'assets/animations/No_Data.json',
              width: 100.w,
              height: 100.w,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
              errorBuilder: (context, error, stackTrace) {
                print('Lottie loading error: $error');
                return Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    Icons.history,
                    size: 50.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Recent Activity',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Activities will appear here\nonce you start using the app',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(RecentActivityProvider activityProvider) {
    final activitiesToShow = activityProvider.recentActivities.take(3).toList();
    
    return Column(
      children: [
        ...activitiesToShow.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          
          return Column(
            children: [
              _buildIOSActivityItem(
                icon: _getActivityIcon(activity['type'] as String? ?? 'default'),
                title: activity['title'] as String? ?? 'No title',
                subtitle: (activity['description'] as String? ?? '').isNotEmpty 
                    ? activity['description'] as String? ?? '' 
                    : _formatTimestamp(DateTime.tryParse(activity['timestamp']?.toString() ?? '') ?? DateTime.now()),
                time: _formatTimestamp(DateTime.tryParse(activity['timestamp']?.toString() ?? '') ?? DateTime.now()),
                color: _getActivityColor(activity['type'] as String? ?? 'default'),
                isFirst: index == 0,
                isLast: index == activitiesToShow.length - 1,
              ),
              if (index < activitiesToShow.length - 1) _buildIOSActivityDivider(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'sale':
        return Colors.green;
      case 'inventory':
      case 'stock':
        return Theme.of(context).colorScheme.primary;
      case 'alert':
      case 'low_stock':
        return Theme.of(context).colorScheme.error;
      case 'return':
        return Colors.red;
      case 'expense':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sale':
        return Icons.shopping_cart;
      case 'inventory':
      case 'stock':
        return Icons.inventory_2;
      case 'alert':
      case 'low_stock':
        return Icons.warning;
      case 'return':
        return Icons.keyboard_return;
      case 'expense':
        return Icons.money_off;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  Widget _buildIOSActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSActivityDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showIOSQuickActionsMenu(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(LucideIcons.plus, size: 24.sp),
    );
  }

  void _showIOSQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 0.85,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildIOSQuickActionItem(
                          icon: LucideIcons.calendar,
                          label: 'Installments',
                          color: AppTheme.mkbhdRed,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/installments');
                          },
                        ),
                        _buildIOSQuickActionItem(
                          icon: LucideIcons.undo2,
                          label: 'Returns',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/returns');
                          },
                        ),
                        _buildIOSQuickActionItem(
                          icon: LucideIcons.users,
                          label: 'Customers',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/customers');
                          },
                        ),
                        _buildIOSQuickActionItem(
                          icon: LucideIcons.creditCard,
                          label: 'Expenses',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/expenses');
                          },
                        ),
                        _buildIOSQuickActionItem(
                          icon: LucideIcons.alertTriangle,
                          label: 'Damaged',
                          color: Colors.redAccent,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/damaged');
                          },
                        ),
                        _buildIOSQuickActionItem(
                          icon: LucideIcons.scanLine,
                          label: 'Barcode',
                          color: Colors.green,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/barcode-scanner');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIOSQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
