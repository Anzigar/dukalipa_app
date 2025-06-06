import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Add this import
import 'package:lumina/core/providers/auth_provider.dart';
import 'package:lumina/core/theme/airbnb_colors.dart';
import 'package:provider/provider.dart';


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
  final List<Map<String, dynamic>> _customizableCards = [
    {
      'title': 'Matumizi',
      'value': 'TSh 450,000',
      'icon': LucideIcons.wallet,
      'color': Colors.orange,
      'route': '/expenses',
    },
    {
      'title': 'Returns',
      'value': '5 Items',
      'icon': LucideIcons.packageMinus,
      'color': Colors.red,
      'route': '/returns',
    },
    {
      'title': 'Debts',
      'value': 'TSh 120,000',
      'icon': LucideIcons.banknote,
      'color': Colors.purple,
      'route': '/debts',
    },
    {
      'title': 'Active Clients',
      'value': '24',
      'icon': LucideIcons.users,
      'color': Colors.blue,
      'route': '/clients',
    },
    {
      'title': 'Notebook',
      'value': '8 Notes',
      'icon': LucideIcons.clipboardList,
      'color': Colors.green,
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
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: _isLoading 
          ? _buildMaterial3LoadingIndicator(colorScheme)
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Modern SliverAppBar with animated effects
                SliverAppBar(
                  expandedHeight: 200,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: isDark ? Colors.black : Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AirbnbColors.primary.withOpacity(0.1),
                            AirbnbColors.primary.withOpacity(0.05),
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
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                      
                      // Quick Actions - Horizontal scroll
                      _buildQuickActionsSection(),
                      
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
      selectedItemColor: AirbnbColors.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
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
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 22),
            onPressed: onPressed,
            color: Colors.grey[700],
          ),
        ),
        if (hasNotification)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
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
              AirbnbColors.primary.withOpacity(0.8),
              AirbnbColors.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AirbnbColors.primary.withOpacity(0.3),
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
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                onTap: _navigateToSearch,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.search,
                        color: Colors.grey[600],
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Search products...',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
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
            height: 24,
            color: Colors.grey[300],
          ),
          // Barcode scanner button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              onTap: _openBarcodeScanner,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  LucideIcons.scanLine,
                  color: AirbnbColors.primary,
                  size: 24,
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
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AirbnbColors.primary,
            AirbnbColors.primary.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AirbnbColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Revenue',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TSh 245,000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+15%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Orders', '32', Icons.shopping_bag_outlined),
                _buildVerticalDivider(),
                _buildMiniStat('Products', '148', Icons.inventory_2_outlined),
                _buildVerticalDivider(),
                _buildMiniStat('Customers', '24', Icons.people_outline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        SizedBox(
          height: 95, // Increased from 100 to accommodate content
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildQuickActionCard(
                icon: LucideIcons.shoppingCart,
                label: 'New Sale',
                color: Colors.green,
                onTap: () => context.push('/sales/new'),
              ),
              _buildQuickActionCard(
                icon: LucideIcons.packagePlus,
                label: 'Add Product',
                color: Colors.blue,
                onTap: () => context.push('/inventory/add'),
              ),
              _buildQuickActionCard(
                icon: LucideIcons.users,
                label: 'Customers',
                color: Colors.purple,
                onTap: () => context.push('/customers'),
              ),
              _buildQuickActionCard(
                icon: LucideIcons.fileText,
                label: 'Reports',
                color: Colors.orange,
                onTap: () => context.push('/reports'),
              ),
              _buildQuickActionCard(
                icon: LucideIcons.scan,
                label: 'Scan',
                color: Colors.red,
                onTap: _openBarcodeScanner,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88, // Slightly reduced width
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9), // Reduced from 10
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20), // Reduced from 22
              ),
              const SizedBox(height: 5), // Reduced from 6
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10.5, // Reduced from 11
                      fontWeight: FontWeight.w600,
                      height: 1.1, // Tighter line height
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                title: 'Expenses',
                value: 'TSh 450,000',
                icon: LucideIcons.wallet,
                color: Colors.orange,
                trend: '-5%',
                isPositive: false,
                onTap: () => context.push('/expenses'),
              ),
              _buildMetricCard(
                title: 'Low Stock',
                value: '12 Items',
                icon: LucideIcons.alertCircle,
                color: Colors.red,
                trend: '3',
                isPositive: false,
                onTap: () => context.push('/inventory/low-stock'),
              ),
              _buildMetricCard(
                title: 'Active Debts',
                value: 'TSh 120,000',
                icon: LucideIcons.banknote,
                color: Colors.purple,
                trend: '2 pending',
                isPositive: null,
                onTap: () => context.push('/debts'),
              ),
              _buildMetricCard(
                title: 'Total Customers',
                value: '156',
                icon: LucideIcons.users,
                color: Colors.blue,
                trend: '+8',
                isPositive: true,
                onTap: () => context.push('/customers'),
              ),
            ],
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(16), // Reduced from 20
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8), // Reduced from 10
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 18), // Reduced from 20
                ),
              ],
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16, // Reduced from 18
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced from 4
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12, // Reduced from 13
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trend.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, // Reduced from 8
                            vertical: 1,    // Reduced from 2
                          ),
                          decoration: BoxDecoration(
                            color: isPositive == null 
                                ? Colors.grey[100]
                                : isPositive 
                                    ? Colors.green.withOpacity(0.1) 
                                    : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            trend,
                            style: TextStyle(
                              color: isPositive == null 
                                  ? Colors.grey[600]
                                  : isPositive ? Colors.green : Colors.red,
                              fontSize: 10,  // Reduced from 11
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/activity'),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  color: Colors.green,
                ),
                _buildActivityDivider(),
                _buildActivityItem(
                  icon: Icons.inventory_2,
                  title: 'Low stock alert',
                  subtitle: 'Samsung Galaxy S21 - 2 units left',
                  time: '1 hour ago',
                  color: Colors.orange,
                ),
                _buildActivityDivider(),
                _buildActivityItem(
                  icon: Icons.person_add,
                  title: 'New customer added',
                  subtitle: 'John Doe - Premium customer',
                  time: '3 hours ago',
                  color: Colors.blue,
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
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
      color: Colors.grey[100],
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showQuickActionsMenu(context),
      backgroundColor: AirbnbColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(LucideIcons.plus, size: 28),
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildQuickActionItem(
                          icon: LucideIcons.shoppingCart,
                          label: 'New Sale',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/sales/new');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.scanLine,
                          label: 'Scan',
                          color: AirbnbColors.primary,
                          onTap: () {
                            Navigator.pop(context);
                            _openBarcodeScanner();
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.package,
                          label: 'Add Product',
                          color: Colors.green,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/inventory/add');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.users,
                          label: 'Clients',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/clients');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.receipt,
                          label: 'Orders',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/orders');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.clipboardList,
                          label: 'Notes',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/notes');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.barChart,
                          label: 'Reports',
                          color: Colors.indigo,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/reports');
                          },
                        ),
                        _buildQuickActionItem(
                          icon: LucideIcons.settings,
                          label: 'Settings',
                          color: Colors.grey,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/settings');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Stock status options
    final List<String> stockOptions = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];
    String selectedStock = 'All';
    
    // Price range with default values
    RangeValues priceRange = const RangeValues(0, 1000000);
    bool isInteracting = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Filter title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Filter Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setStateModal(() {
                          selectedStock = 'All';
                          priceRange = const RangeValues(0, 1000000);
                        });
                      },
                      child: Text('Reset', style: TextStyle(color: colorScheme.primary)),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1, thickness: 1),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stock status filter
                      Text(
                        'Stock Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Stock status options with Material 3 styling
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: stockOptions.map((option) => 
                          FilterChip(
                            label: Text(option),
                            selected: selectedStock == option,
                            showCheckmark: false,
                            onSelected: (_) => setStateModal(() => selectedStock = option),
                            selectedColor: colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: selectedStock == option 
                                  ? colorScheme.onPrimaryContainer 
                                  : colorScheme.onSurfaceVariant,
                            ),
                          )
                        ).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Price range filter - Material 3 Expressive style
                      Text(
                        'Price Range',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Price values display with M3 styling
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Start price chip
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isInteracting 
                                    ? colorScheme.primaryContainer 
                                    : colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'TSh ${priceRange.start.round()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isInteracting 
                                      ? colorScheme.onPrimaryContainer 
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            
                            // Price range indicator
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: colorScheme.outlineVariant,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ),
                            
                            // End price chip
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isInteracting 
                                    ? colorScheme.primaryContainer 
                                    : colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'TSh ${priceRange.end.round()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isInteracting 
                                      ? colorScheme.onPrimaryContainer 
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Material 3 improved RangeSlider
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6,
                          activeTrackColor: colorScheme.primary,
                          inactiveTrackColor: colorScheme.surfaceVariant,
                          thumbColor: colorScheme.primaryContainer,
                          overlayColor: colorScheme.primary.withOpacity(0.12),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                            elevation: 2,
                            pressedElevation: 4,
                          ),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                          trackShape: const RoundedRectSliderTrackShape(),
                          rangeThumbShape: const RoundRangeSliderThumbShape(
                            enabledThumbRadius: 10,
                            elevation: 2,
                            pressedElevation: 4,
                          ),
                          rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                          showValueIndicator: ShowValueIndicator.always,
                          valueIndicatorColor: colorScheme.primaryContainer,
                          valueIndicatorTextStyle: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: RangeSlider(
                          values: priceRange,
                          min: 0,
                          max: 1000000,
                          divisions: 100,
                          labels: RangeLabels(
                            'TSh ${priceRange.start.round()}',
                            'TSh ${priceRange.end.round()}',
                          ),
                          onChanged: (values) {
                            setStateModal(() {
                              priceRange = values;
                              isInteracting = true;
                            });
                          },
                          onChangeEnd: (values) {
                            setStateModal(() {
                              isInteracting = false;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // M3 expressive price range labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TSh 0',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'TSh 500,000',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'TSh 1,000,000',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Apply button
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          // Apply the filters
                          Navigator.of(context).pop();
                          
                          // Here you would typically update your fetch criteria
                          // and call fetchInventory with the new filters
                        },
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
