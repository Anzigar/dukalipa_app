import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Add this import
import 'package:dukalipa_app/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../providers/analytics_provider.dart';


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
  int _currentChartPage = 0;
  bool _showCompactActions = false;
  
  // Animation controller for loading animation
  late AnimationController _loadingController;

  // Track the current page for product image carousel
  final PageController _pageController = PageController();

  // Added fields for loading action state
  String? _loadingActionLabel;
  bool _isLoading = false;

  // Replace categories with business metrics
  final List<Map<String, dynamic>> _businessMetrics = [
    {'name': 'Matumizi', 'icon': LucideIcons.wallet, 'isSelected': true, 'route': '/expenses'},
    {'name': 'Returns', 'icon': LucideIcons.packageMinus, 'isSelected': false, 'route': '/returns'},
    {'name': 'Debts', 'icon': LucideIcons.banknote, 'isSelected': false, 'route': '/debts'},
    {'name': 'Clients', 'icon': LucideIcons.users, 'isSelected': false, 'route': '/clients'},
    {'name': 'Notes', 'icon': LucideIcons.clipboardList, 'isSelected': false, 'route': '/notes'},
  ];

  // User customizable cards that can be reordered
  List<Map<String, dynamic>> _getCustomizableCards(BuildContext context) => [
    {
      'title': 'Matumizi',
      'value': 'TSh 450,000',
      'icon': LucideIcons.wallet,
      'color': Theme.of(context).colorScheme.tertiary,
      'route': '/expenses',
    },
    {
      'title': 'Returns',
      'value': '5 Items',
      'icon': LucideIcons.packageMinus,
      'color': Theme.of(context).colorScheme.error,
      'route': '/returns',
    },
    {
      'title': 'Debts',
      'value': 'TSh 120,000',
      'icon': LucideIcons.banknote,
      'color': Theme.of(context).colorScheme.secondary,
      'route': '/debts',
    },
    {
      'title': 'Active Clients',
      'value': '24',
      'icon': LucideIcons.users,
      'color': Theme.of(context).colorScheme.primary,
      'route': '/clients',
    },
    {
      'title': 'Notebook',
      'value': '8 Notes',
      'icon': LucideIcons.clipboardList,
      'color': Theme.of(context).colorScheme.primaryContainer,
      'route': '/notes',
    },
  ];

  // Track if edit mode is active for customizable cards
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initialize loading animation controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Load analytics data including inventory
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
  }

  void _loadAnalyticsData() async {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    await analyticsProvider.loadInventorySummary();
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
    context.push('/search');
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<AuthProvider>(context, listen: false).userProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading 
          ? const DashboardShimmer()
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Modern SliverAppBar with animated effects
                SliverAppBar(
                  expandedHeight: 200,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.primary.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Profile header
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        profile?.name ?? 'Shop Owner',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _buildActionButton(
                                        icon: LucideIcons.bell,
                                        onPressed: () => context.push('/notifications'),
                                        hasNotification: true,
                                      ),
                                      const SizedBox(width: 12),
                                      _buildProfileAvatar(profile),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Search bar integrated in app bar
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: _buildSearchBar(),
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
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // New Material 3 expressive loading indicator with M3 icons
  Widget _buildMaterial3LoadingIndicator(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primary loading indicator with pulse animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated outer circle
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primaryContainer.withOpacity(0.2 + 0.1 * _loadingController.value),
                          colorScheme.primaryContainer.withOpacity(0),
                        ],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  );
                },
              ),
              
              // Main circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.primaryContainer.withOpacity(0.2),
                ),
              ),
              
              // Material 3 expressive central icon
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  // Use scaling animation for the icon
                  final scale = 0.8 + 0.2 * ((_loadingController.value - 0.5).abs() * 2);
                  
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.store_rounded, // Material 3 expressive icon
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Loading label with fade animation and icon
          AnimatedOpacity(
            opacity: 0.7 + 0.3 * ((_loadingController.value - 0.5).abs() * 2),
            duration: const Duration(milliseconds: 150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Material 3 expressive loading icon
                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, _) {
                    final angle = _loadingController.value * 2 * 3.14159;
                    return Transform.rotate(
                      angle: angle,
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: colorScheme.secondary,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  _loadingActionLabel ?? 'Loading your store...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Animated dots using Material 3 expressive design
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final delay = index / 5;
                return AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, _) {
                    final value = (((_loadingController.value + delay) % 1) < 0.5)
                        ? ((_loadingController.value + delay) % 1) * 2
                        : (1 - ((_loadingController.value + delay) % 1)) * 2;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: value > 0.5 
                              ? colorScheme.tertiary
                              : colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Additional status indicator with M3 icon
          AnimatedOpacity(
            opacity: (_loadingController.value > 0.5) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.support_agent_rounded, // Material 3 expressive icon
                  size: 16,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preparing your dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool hasNotification = false,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 22.sp),
            onPressed: onPressed,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        if (hasNotification)
          Positioned(
            right: 8.w,
            top: 8.h,
            child: Container(
              width: 10.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).cardColor, 
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileAvatar(profile) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        width: 48,
        height: 48,
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
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            profile?.name?.isNotEmpty == true 
                ? profile!.name![0].toUpperCase() 
                : 'U',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search area
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
                onTap: _navigateToSearch,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.search,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        size: 22.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Search products...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 24.h,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          // Barcode scanner button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(16.r)),
              onTap: _openBarcodeScanner,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Icon(
                  LucideIcons.scanLine,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
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
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          // Main revenue card - Meta style: clean, minimal, no icons
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row - Meta style: simple text hierarchy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Revenue',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                    // Minimal growth indicator - just text, no icon
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '+15%',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Main revenue amount - prominent but clean
                Text(
                  'TSh 245,000',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                // Subtitle - Meta style: helpful context without clutter
                Text(
                  'vs TSh 213,000 yesterday',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Quick stats row - Meta style: minimal, text-focused
          Row(
            children: [
              Expanded(
                child: _buildMetaStyleStatCard('Orders', '32', 'today'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMetaStyleStatCard('Products', '148', 'in stock'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMetaStyleStatCard('Customers', '24', 'active'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Meta-style stat card: minimal, clean, text-focused
  Widget _buildMetaStyleStatCard(String label, String value, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main value - prominent and clean
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.1,
            ),
          ),
          SizedBox(height: 3.h),
          // Label - clean and minimal
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          SizedBox(height: 1.h),
          // Subtitle - helpful context
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              height: 1.1,
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
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate appropriate childAspectRatio based on available width
                  double cardWidth = (constraints.maxWidth - 16.w) / 2;
                  double cardHeight = cardWidth * 0.65; // Better ratio for content fit
                  double aspectRatio = cardWidth / cardHeight;
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: aspectRatio.clamp(1.3, 1.6), // Tighter ratio range
                    children: [
                      _buildMetricCard(
                        title: 'Total Stock',
                        value: analyticsProvider.getFormattedCurrency(analyticsProvider.totalStockValue),
                        icon: LucideIcons.package,
                        color: Theme.of(context).colorScheme.primary,
                        trend: '${analyticsProvider.totalProductsCount} items',
                        isPositive: null,
                        onTap: () => context.push('/inventory'),
                      ),
                      _buildMetricCard(
                        title: 'Low Stock',
                        value: '${analyticsProvider.inventorySummary['low_stock_count'] ?? 0} Items',
                        icon: LucideIcons.alertCircle,
                        color: Theme.of(context).colorScheme.error,
                        trend: 'need attention',
                        isPositive: false,
                        onTap: () => context.push('/inventory/low-stock'),
                      ),
                      _buildMetricCard(
                        title: 'Active Debts',
                        value: 'TSh 120,000',
                        icon: LucideIcons.banknote,
                        color: Theme.of(context).colorScheme.secondary,
                        trend: '2 pending',
                        isPositive: null,
                        onTap: () => context.push('/debts'),
                      ),
                      _buildMetricCard(
                        title: 'Total Customers',
                        value: '156',
                        icon: LucideIcons.users,
                        color: Theme.of(context).colorScheme.tertiary,
                        trend: '+8',
                        isPositive: true,
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    bool? isPositive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w), // Further reduced padding
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row with indicator and trend
                SizedBox(
                  height: 20.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Small subtle indicator
                      Container(
                        width: 3.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      // Trend indicator on the right
                      if (trend.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isPositive == null 
                                ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)
                                : isPositive 
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                                    : Theme.of(context).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            trend,
                            style: TextStyle(
                              color: isPositive == null 
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                  : isPositive 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).colorScheme.error,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Main content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value text
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 2.h),
                      
                      // Title text
                      Flexible(
                        flex: 1,
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
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
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/activity'),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.shopping_cart,
                  title: 'New sale completed',
                  subtitle: 'iPhone 13 Pro - TSh 2,500,000',
                  time: '2 min ago',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildActivityDivider(),
                _buildActivityItem(
                  icon: Icons.inventory_2,
                  title: 'Low stock alert',
                  subtitle: 'Samsung Galaxy S21 - 2 units left',
                  time: '1 hour ago',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                _buildActivityDivider(),
                _buildActivityItem(
                  icon: Icons.person_add,
                  title: 'New customer added',
                  subtitle: 'John Doe - Premium customer',
                  time: '3 hours ago',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDivider() {
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
      onPressed: () => _showQuickActionsMenu(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 4,
      child: Icon(LucideIcons.plus, size: 28.sp),
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      mainAxisSpacing: 16.h, // Reduced spacing
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 0.9, // Better aspect ratio
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildQuickActionItem(
                          icon: LucideIcons.shoppingCart,
                          label: 'New Sale',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/sales/new');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.scanLine,
                          label: 'Scan',
                          color: Theme.of(context).colorScheme.error,
                          onTap: () {
                            Navigator.pop(context);
                            _openBarcodeScanner();
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.package,
                          label: 'Add Product',
                          color: Theme.of(context).colorScheme.secondary,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/inventory/add');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.users,
                          label: 'Clients',
                          color: Theme.of(context).colorScheme.tertiary,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/clients');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.receipt,
                          label: 'Orders',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/orders');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.clipboardList,
                          label: 'Notes',
                          color: Theme.of(context).colorScheme.secondary,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/notes');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.barChart,
                          label: 'Reports',
                          color: Theme.of(context).colorScheme.tertiary,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/reports');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.settings,
                          label: 'Settings',
                          color: Theme.of(context).colorScheme.outline,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/settings');
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

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 80.h, // Fixed height to prevent overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w, // Slightly smaller container
              height: 52.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp, // Smaller icon
              ),
            ),
            SizedBox(height: 6.h),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
