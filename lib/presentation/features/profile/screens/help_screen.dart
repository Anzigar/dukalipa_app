import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/meta_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MetaColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        backgroundColor: MetaColors.backgroundColor,
        foregroundColor: MetaColors.primaryText,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
                // Contact Support Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MetaColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: MetaColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: MetaColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ContactTile(
                        icon: Icons.email_outlined,
                        title: 'Email Support',
                        subtitle: 'support@dukalipa.com',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _ContactTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone Support',
                        subtitle: '+1 (555) 123-4567',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _ContactTile(
                        icon: Icons.chat_outlined,
                        title: 'Live Chat',
                        subtitle: 'Available 24/7',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // FAQ Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MetaColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: MetaColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: MetaColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FAQItem(
                        question: 'How do I add a new product?',
                        answer: 'Go to Inventory > Add Product and fill in the required details.',
                      ),
                      _FAQItem(
                        question: 'How can I track my sales?',
                        answer: 'Use the Sales screen to view all transactions and the Analytics for detailed insights.',
                      ),
                      _FAQItem(
                        question: 'How do I manage storage locations?',
                        answer: 'Navigate to Business Hub > Storage Management to add and manage locations.',
                      ),
                      _FAQItem(
                        question: 'Can I export my data?',
                        answer: 'Yes, you can export reports and data from the Analytics section.',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: MetaColors.borderLight,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MetaColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: MetaColors.primaryBlue,
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
                        fontWeight: FontWeight.w600,
                        color: MetaColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: MetaColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: MetaColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: MetaColors.borderLight,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MetaColors.primaryText,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: MetaColors.secondaryText,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.answer,
                    style: const TextStyle(
                      fontSize: 14,
                      color: MetaColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
