import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../common/widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Settings'),
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  SizedBox(height: 20.h),
                  _buildSection(
                    title: 'Preferences',
                    children: [
                      _buildThemeSelector(themeProvider, isDark),
                      _buildSwitchTile(
                        title: 'Notifications',
                        subtitle: 'Receive push notifications',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                        isDark: isDark,
                      ),
                      _buildSwitchTile(
                        title: 'Biometric Authentication',
                        subtitle: 'Use fingerprint or face ID',
                        value: _biometricEnabled,
                        onChanged: (value) {
                          setState(() => _biometricEnabled = value);
                        },
                        isDark: isDark,
                      ),
                      _buildSwitchTile(
                        title: 'Auto Backup',
                        subtitle: 'Automatically backup data',
                        value: _autoBackup,
                        onChanged: (value) {
                          setState(() => _autoBackup = value);
                        },
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    title: 'Account',
                    children: [
                      _buildActionTile(
                        title: 'Profile',
                        subtitle: 'Manage your profile information',
                        icon: Icons.person_outline,
                        onTap: () => _showComingSoon(context),
                        isDark: isDark,
                      ),
                      _buildActionTile(
                        title: 'Security',
                        subtitle: 'Password and security settings',
                        icon: Icons.security_outlined,
                        onTap: () => _showComingSoon(context),
                        isDark: isDark,
                      ),
                      _buildActionTile(
                        title: 'Privacy',
                        subtitle: 'Control your data privacy',
                        icon: Icons.privacy_tip_outlined,
                        onTap: () => _showComingSoon(context),
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    title: 'Support',
                    children: [
                      _buildActionTile(
                        title: 'Help Center',
                        subtitle: 'Get help and support',
                        icon: Icons.help_outline,
                        onTap: () => _showComingSoon(context),
                        isDark: isDark,
                      ),
                      _buildActionTile(
                        title: 'Contact Us',
                        subtitle: 'Get in touch with our team',
                        icon: Icons.contact_support_outlined,
                        onTap: () => _showComingSoon(context),
                        isDark: isDark,
                      ),
                      _buildActionTile(
                        title: 'Rate App',
                        subtitle: 'Rate us on the App Store',
                        icon: Icons.star_outline,
                        onTap: () => _showComingSoon(context),
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    title: 'About',
                    children: [
                      _buildActionTile(
                        title: 'Version',
                        subtitle: '1.0.0 (Build 1)',
                        icon: Icons.info_outline,
                        onTap: null,
                        isDark: isDark,
                        showArrow: false,
                      ),
                      _buildActionTile(
                        title: 'Terms of Service',
                        subtitle: 'Read our terms and conditions',
                        icon: Icons.description_outlined,
                        onTap: () => _showComingSoon(context),
                        isDark: isDark,
                      ),
                      _buildActionTile(
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        icon: Icons.policy_outlined,
                        onTap: () => _showComingSoon(context),
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),
                  _buildSignOutButton(isDark),
                  SizedBox(height: 40.h),
                ],
        ),
      ),
    );
  }


  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D70),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.palette_outlined,
              size: 18.sp,
              color: const Color(0xFF007AFF),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                                      ),
                ),
                Text(
                  _getThemeDisplayName(themeProvider.themeMode),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D70),
                                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark ? const Color(0xFF8E8E93) : const Color(0xFFC7C7CC),
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                                      ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D70),
                                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: const Color(0xFF007AFF),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                                          ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D70),
                                          ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFFC7C7CC),
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: CustomButton(
        text: 'Sign Out',
        onPressed: () => _showSignOutDialog(context, isDark),
        icon: LucideIcons.logOut,
        backgroundColor: Colors.transparent,
        textColor: const Color(0xFFFF3B30),
        borderColor: const Color(0xFFFF3B30),
        isOutlined: true,
        fullWidth: true,
      ),
    );
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'This feature is coming soon!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF007AFF),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          title: Text(
            'Sign Out',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
                          ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D70),
                          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: const Color(0xFF007AFF),
                                  ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement sign out logic
                _showComingSoon(context);
              },
              child: Text(
                'Sign Out',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF3B30),
                                  ),
              ),
            ),
          ],
        );
      },
    );
  }
}
