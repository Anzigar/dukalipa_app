import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section_widgets.dart';
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

  void _navigateToRoute(String route) {
    try {
      context.push(route);
    } catch (e) {
      // If route doesn't exist, show coming soon dialog
      final featureName = route.split('/').last.replaceAll('-', ' ').toLowerCase();
      _showComingSoonDialog(featureName.isNotEmpty ? featureName : 'This feature');
    }
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: viewModel.isLoading 
                ? const ProfileShimmer()
                : RefreshIndicator(
                    onRefresh: _loadUserProfile,
                    color: Theme.of(context).colorScheme.primary,
                    child: CustomScrollView(
                      slivers: [
                        // Profile header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ProfileHeader(viewModel: viewModel, profile: profile),
                          ),
                        ),
                        
                        // Shop information
                        if (profile?.shopName != null) ...[
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding:  EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child:  SectionHeader(title: 'Shop Information'),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  ProfileListTile(
                                    icon: Icons.store_outlined,
                                    title: 'Shop Name',
                                    value: profile!.shopName!,
                                  ),
                                  if (profile.shopAddress != null)
                                    ProfileListTile(
                                      icon: Icons.location_on_outlined,
                                      title: 'Address',
                                      value: profile.shopAddress!,
                                    ),
                                  if (profile.shopPhone != null)
                                    ProfileListTile(
                                      icon: Icons.phone_outlined,
                                      title: 'Shop Phone',
                                      value: profile.shopPhone!,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        
                        // Business Management Section
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
                            child: SectionHeader(title: 'Business Management'),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.3,
                            ),
                            delegate: SliverChildListDelegate([
                              _GridActionTile(
                                icon: Icons.business_center,
                                title: 'Business Hub',
                                onTap: () {
                                  debugPrint('🔍 Tapping Business Hub');
                                  context.push('/business/hub');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.analytics_outlined,
                                title: 'Analytics',
                                onTap: () {
                                  debugPrint('🔍 Tapping Analytics');
                                  context.push('/business/analytics');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.inventory_2_outlined,
                                title: 'Storage',
                                onTap: () {
                                  debugPrint('🔍 Tapping Storage');
                                  context.push('/business/storage');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.healing_outlined,
                                title: 'Damaged',
                                onTap: () {
                                  debugPrint('🔍 Tapping Damaged');
                                  context.push('/business/damaged');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.delete_outline,
                                title: 'Deleted',
                                onTap: () {
                                  debugPrint('🔍 Tapping Deleted');
                                  context.push('/business/deleted');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.more_horiz,
                                title: 'More',
                                onTap: () => _showComingSoonDialog('More Options'),
                              ),
                            ]),
                          ),
                        ),
                        
                        // Account settings
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
                            child: SectionHeader(title: 'Account Settings'),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.3,
                            ),
                            delegate: SliverChildListDelegate([
                              _GridActionTile(
                                icon: Icons.edit_outlined,
                                title: 'Edit Profile',
                                onTap: () {
                                  debugPrint('🔍 Tapping Edit Profile');
                                  context.push('/profile/edit');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.lock_outline,
                                title: 'Password',
                                onTap: () {
                                  debugPrint('🔍 Tapping Change Password');
                                  context.push('/profile/change-password');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.settings_outlined,
                                title: l10n.settings,
                                onTap: () {
                                  debugPrint('🔍 Tapping Settings');
                                  context.push('/settings');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.language_outlined,
                                title: l10n.language,
                                onTap: () {
                                  debugPrint('🔍 Tapping Language');
                                  context.push('/profile/language');
                                },
                              ),
                            ]),
                          ),
                        ),
                        
                        // App information
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
                            child: SectionHeader(title: 'App Information'),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.3,
                            ),
                            delegate: SliverChildListDelegate([
                              _GridActionTile(
                                icon: Icons.info_outline,
                                title: 'About',
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
                              _GridActionTile(
                                icon: Icons.help_outline,
                                title: 'Help',
                                onTap: () {
                                  debugPrint('🔍 Tapping Help');
                                  context.push('/profile/help');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy',
                                onTap: () {
                                  debugPrint('🔍 Tapping Privacy');
                                  context.push('/profile/privacy');
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.description_outlined,
                                title: 'Terms',
                                onTap: () {
                                  debugPrint('🔍 Tapping Terms');
                                  context.push('/profile/terms');
                                },
                              ),
                            ]),
                          ),
                        ),
                        
                        // Logout button and version
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                SizedBox(height: 24.h),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.r),
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.error.withOpacity(0.9),
                                        Theme.of(context).colorScheme.error,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _logout,
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 18,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.logout,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Logout',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Center(
                                  child: Text(
                                    'Version 1.0.0',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _GridActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  
  const _GridActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
