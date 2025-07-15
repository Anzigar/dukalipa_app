import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../common/widgets/theme_toggle_widget.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Preferences Section
                _SettingsSection(
                  title: 'Preferences',
                  children: [
                    _SettingsSwitchTile(
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Receive alerts and updates',
                      value: _notificationsEnabled,
                      onChanged: (value) => setState(() => _notificationsEnabled = value),
                    ),
                    // Updated Theme Setting with ThemeToggleWidget
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.mkbhdRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.palette_outlined,
                                  size: 20,
                                  color: AppTheme.mkbhdRed,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Theme',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getThemeModeName(themeProvider.themeMode),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.mkbhdLightGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const ThemeToggleWidget(
                                showLabel: false,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: 'English (US)',
                      onTap: () => context.push('/profile/language'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Security Section
                _SettingsSection(
                  title: 'Security',
                  children: [
                    _SettingsSwitchTile(
                      icon: Icons.fingerprint_outlined,
                      title: 'Biometric Login',
                      subtitle: 'Use fingerprint or face ID',
                      value: _biometricEnabled,
                      onChanged: (value) => setState(() => _biometricEnabled = value),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      onTap: () => context.push('/profile/change-password'),
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Settings',
                      subtitle: 'Manage your privacy',
                      onTap: () {
                        // Navigate to privacy settings
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Data & Storage Section
                _SettingsSection(
                  title: 'Data & Storage',
                  children: [
                    _SettingsSwitchTile(
                      icon: Icons.backup_outlined,
                      title: 'Auto Backup',
                      subtitle: 'Automatically backup data',
                      value: _autoBackup,
                      onChanged: (value) => setState(() => _autoBackup = value),
                    ),
                    _SettingsTile(
                      icon: Icons.storage_outlined,
                      title: 'Storage Usage',
                      subtitle: '1.2 GB used',
                      onTap: () {
                        // Show storage details
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.cloud_sync_outlined,
                      title: 'Sync Settings',
                      subtitle: 'Manage data synchronization',
                      onTap: () {
                        // Navigate to sync settings
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Support Section
                _SettingsSection(
                  title: 'Support',
                  children: [
                    _SettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: () {
                        // Navigate to help
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.bug_report_outlined,
                      title: 'Report a Bug',
                      subtitle: 'Help us improve the app',
                      onTap: () {
                        // Report bug
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      subtitle: 'Share your thoughts',
                      onTap: () {
                        // Send feedback
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'Follow system';
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.mkbhdLightGrey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.mkbhdLightGrey.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mkbhdRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppTheme.mkbhdRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.mkbhdLightGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.mkbhdRed,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.mkbhdLightGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.mkbhdRed,
          ),
        ],
      ),
    );
  }
}
