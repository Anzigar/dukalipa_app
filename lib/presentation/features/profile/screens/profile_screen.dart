import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../common/widgets/custom_button.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section_widgets.dart';

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
            backgroundColor: Colors.red,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
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
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUserProfile,
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
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: const SectionHeader(title: 'Shop Information'),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppTheme.mkbhdLightGrey.withOpacity(0.08),
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
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                            child: const SectionHeader(title: 'Business Management'),
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
                                onTap: () => context.push('/business/hub'),
                              ),
                              _GridActionTile(
                                icon: Icons.analytics_outlined,
                                title: 'Analytics',
                                onTap: () => context.push('/business/analytics'),
                              ),
                              _GridActionTile(
                                icon: Icons.inventory_2_outlined,
                                title: 'Storage',
                                onTap: () => context.push('/business/storage'),
                              ),
                              _GridActionTile(
                                icon: Icons.healing_outlined,
                                title: 'Damaged',
                                onTap: () => context.push('/business/damaged'),
                              ),
                              _GridActionTile(
                                icon: Icons.delete_outline,
                                title: 'Deleted',
                                onTap: () => context.push('/business/deleted'),
                              ),
                              _GridActionTile(
                                icon: Icons.more_horiz,
                                title: 'More',
                                onTap: () => context.push('/business/more'),
                              ),
                            ]),
                          ),
                        ),
                        
                        // Account settings
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                            child: const SectionHeader(title: 'Account Settings'),
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
                                onTap: () => context.push('/profile/edit'),
                              ),
                              _GridActionTile(
                                icon: Icons.lock_outline,
                                title: 'Password',
                                onTap: () => context.push('/profile/change-password'),
                              ),
                              _GridActionTile(
                                icon: Icons.settings_outlined,
                                title: l10n.settings,
                                onTap: () => context.push('/settings'),
                              ),
                              _GridActionTile(
                                icon: Icons.language_outlined,
                                title: l10n.language,
                                onTap: () => context.push('/profile/language'),
                              ),
                            ]),
                          ),
                        ),
                        
                        // App information
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                            child: const SectionHeader(title: 'App Information'),
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
                                  // Navigate to help & support screen
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy',
                                onTap: () {
                                  // Show privacy policy
                                },
                              ),
                              _GridActionTile(
                                icon: Icons.description_outlined,
                                title: 'Terms',
                                onTap: () {
                                  // Show terms of service
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
                                const SizedBox(height: 24),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.mkbhdRed.withOpacity(0.9),
                                        AppTheme.mkbhdRed,
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
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
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
                                const SizedBox(height: 24),
                                const Center(
                                  child: Text(
                                    'Version 1.0.0',
                                    style: TextStyle(
                                      color: AppTheme.mkbhdLightGrey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.mkbhdLightGrey.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.mkbhdRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: AppTheme.mkbhdRed,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
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
