import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_header.dart';
import '../../../common/widgets/shimmer_loading.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(Provider.of<AuthProvider>(context, listen: false));
    // Load user profile data
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      await _viewModel.loadUserProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _viewModel.logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }
  
  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature is under development and will be available in a future update.'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final profile = viewModel.userProfile;
          
          return Scaffold(
            backgroundColor: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF000000)
                : const Color(0xFFF2F2F7),
            appBar: AppBar(
              title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
            ),
            body: viewModel.isLoading 
                ? const ProfileShimmer()
                : RefreshIndicator(
                    onRefresh: _loadUserProfile,
                    color: Theme.of(context).colorScheme.primary,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // iOS-style Profile Header Section
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                          child: Row(
                            children: [
                              // Profile Avatar
                              Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 30.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              // Profile Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile?.name ?? 'User Name',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      profile?.email ?? 'user@email.com',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit arrow
                              Icon(
                                Icons.chevron_right,
                                size: 20.sp,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Business Information Section
                        if (profile?.shopName != null) ...[
                          _IOSSectionHeader(title: 'BUSINESS'),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                _IOSListTile(
                                  icon: Icons.store_outlined,
                                  title: 'Shop Name',
                                  subtitle: profile!.shopName!,
                                  isFirst: true,
                                  isLast: profile.shopAddress == null && profile.shopPhone == null,
                                ),
                                if (profile.shopAddress != null)
                                  _IOSListTile(
                                    icon: Icons.location_on_outlined,
                                    title: 'Address',
                                    subtitle: profile.shopAddress!,
                                    isFirst: false,
                                    isLast: profile.shopPhone == null,
                                  ),
                                if (profile.shopPhone != null)
                                  _IOSListTile(
                                    icon: Icons.phone_outlined,
                                    title: 'Phone',
                                    subtitle: profile.shopPhone!,
                                    isFirst: false,
                                    isLast: true,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.h),
                        ],

                        // Business Management Section
                        _IOSSectionHeader(title: 'BUSINESS MANAGEMENT'),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              _IOSActionTile(
                                icon: Icons.business_center_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Business Hub',
                                isFirst: true,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Business Hub');
                                  context.push('/business/hub');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.analytics_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Analytics',
                                isFirst: false,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Analytics');
                                  context.push('/business/analytics');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.inventory_2_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Storage',
                                isFirst: false,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Storage');
                                  context.push('/business/storage');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.healing_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Damaged Items',
                                isFirst: false,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Damaged');
                                  context.push('/business/damaged');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.delete_outline,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Deleted Items',
                                isFirst: false,
                                isLast: true,
                                onTap: () {
                                  debugPrint('🔍 Tapping Deleted');
                                  context.push('/business/deleted');
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Account Settings Section
                        _IOSSectionHeader(title: 'ACCOUNT'),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              _IOSActionTile(
                                icon: Icons.edit_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Edit Profile',
                                isFirst: true,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Edit Profile');
                                  context.push('/profile/edit');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.lock_outline,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Change Password',
                                isFirst: false,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Change Password');
                                  context.push('/profile/change-password');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.settings_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: l10n.settings,
                                isFirst: false,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Settings');
                                  context.push('/settings');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.language_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: l10n.language,
                                isFirst: false,
                                isLast: true,
                                onTap: () {
                                  debugPrint('🔍 Tapping Language');
                                  context.push('/profile/language');
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Support Section
                        _IOSSectionHeader(title: 'SUPPORT'),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              _IOSActionTile(
                                icon: Icons.help_outline,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Help & Support',
                                isFirst: true,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Help');
                                  context.push('/profile/help');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.info_outline,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'About',
                                isFirst: false,
                                isLast: false,
                                onTap: () {
                                  showAboutDialog(
                                    context: context,
                                    applicationName: 'Dukalipa',
                                    applicationVersion: 'v1.0.0',
                                    applicationIcon: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppTheme.mkbhdRed,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_cart,
                                        color: Colors.white,
                                      ),
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                        child: Text(
                                          'Dukalipa is a comprehensive POS and inventory management system for retail businesses.',
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.privacy_tip_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Privacy Policy',
                                isFirst: false,
                                isLast: false,
                                onTap: () {
                                  debugPrint('🔍 Tapping Privacy');
                                  context.push('/profile/privacy');
                                },
                              ),
                              _IOSActionTile(
                                icon: Icons.description_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: 'Terms of Service',
                                isFirst: false,
                                isLast: true,
                                onTap: () {
                                  debugPrint('🔍 Tapping Terms');
                                  context.push('/profile/terms');
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Sign Out Section
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: _IOSActionTile(
                            icon: Icons.logout,
                            iconColor: Colors.red,
                            title: 'Sign Out',
                            isFirst: true,
                            isLast: true,
                            onTap: _logout,
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Version Info
                        Center(
                          child: Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

// iOS-style Section Header
class _IOSSectionHeader extends StatelessWidget {
  final String title;
  
  const _IOSSectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// iOS-style List Tile for Information Display
class _IOSListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;
  
  const _IOSListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isFirst,
    required this.isLast,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                icon,
                size: 16.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
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
}

// iOS-style Action Tile
class _IOSActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  
  const _IOSActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(12.r) : Radius.zero,
          bottom: isLast ? Radius.circular(12.r) : Radius.zero,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast ? BorderSide.none : BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    icon,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
