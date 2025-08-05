import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find answers to common questions or contact our support team',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Support Section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _HelpActionTile(
                  icon: Icons.email_outlined,
                  iconColor: Colors.blue,
                  title: 'Email Support',
                  subtitle: 'support@dukalipa.com',
                  isFirst: true,
                  isLast: false,
                  onTap: () {
                    // TODO: Open email client
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening email client...')),
                    );
                  },
                ),
                _HelpActionTile(
                  icon: Icons.phone_outlined,
                  iconColor: Colors.green,
                  title: 'Phone Support',
                  subtitle: '+254 700 000 000',
                  isFirst: false,
                  isLast: false,
                  onTap: () {
                    // TODO: Open phone dialer
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening phone dialer...')),
                    );
                  },
                ),
                _HelpActionTile(
                  icon: Icons.chat_bubble_outline,
                  iconColor: Colors.orange,
                  title: 'Live Chat',
                  subtitle: 'Chat with our support team',
                  isFirst: false,
                  isLast: true,
                  onTap: () {
                    // TODO: Open live chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening live chat...')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _HelpActionTile(
                  icon: Icons.quiz_outlined,
                  iconColor: Colors.purple,
                  title: 'Frequently Asked Questions',
                  subtitle: 'Find quick answers',
                  isFirst: true,
                  isLast: false,
                  onTap: () {
                    // TODO: Navigate to FAQ page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening FAQ...')),
                    );
                  },
                ),
                _HelpActionTile(
                  icon: Icons.video_library_outlined,
                  iconColor: Colors.red,
                  title: 'Video Tutorials',
                  subtitle: 'Learn how to use the app',
                  isFirst: false,
                  isLast: false,
                  onTap: () {
                    // TODO: Navigate to tutorials
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening tutorials...')),
                    );
                  },
                ),
                _HelpActionTile(
                  icon: Icons.book_outlined,
                  iconColor: Colors.teal,
                  title: 'User Guide',
                  subtitle: 'Comprehensive documentation',
                  isFirst: false,
                  isLast: true,
                  onTap: () {
                    // TODO: Open user guide
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening user guide...')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _HelpActionTile(
                  icon: Icons.bug_report_outlined,
                  iconColor: Colors.orange,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve the app',
                  isFirst: true,
                  isLast: false,
                  onTap: () {
                    // TODO: Open bug report form
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening bug report...')),
                    );
                  },
                ),
                _HelpActionTile(
                  icon: Icons.lightbulb_outline,
                  iconColor: Colors.amber,
                  title: 'Feature Request',
                  subtitle: 'Suggest new features',
                  isFirst: false,
                  isLast: true,
                  onTap: () {
                    // TODO: Open feature request form
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening feature request...')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Help Action Tile Widget
class _HelpActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  
  const _HelpActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
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
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
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
