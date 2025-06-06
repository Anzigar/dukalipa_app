import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  
  const SectionHeader({Key? key, required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  
  const ProfileListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.mkbhdLightGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.mkbhdRed.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: AppTheme.mkbhdRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.mkbhdLightGrey,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  
  const ActionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.mkbhdLightGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.mkbhdRed.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.mkbhdRed,
          size: 20,
        ),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
