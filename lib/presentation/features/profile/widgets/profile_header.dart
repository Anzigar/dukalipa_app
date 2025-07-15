import 'package:flutter/material.dart';
import '../../../../core/theme/meta_colors.dart';
import '../../../../data/models/user_profile.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;
  final UserProfile? profile;

  const ProfileHeader({
    super.key,
    required this.viewModel,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MetaColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: MetaColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MetaColors.darkGrey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: MetaColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: MetaColors.primaryBlue.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(profile?.name ?? 'User'),
                style: TextStyle(
                  color: MetaColors.primaryBlue,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User Name
          Text(
            profile?.name ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: MetaColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // User Email
          Text(
            profile?.email ?? 'No email provided',
            style: const TextStyle(
              fontSize: 16,
              color: MetaColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (profile?.phone != null) ...[
            const SizedBox(height: 4),
            Text(
              profile!.phone!,
              style: const TextStyle(
                fontSize: 14,
                color: MetaColors.tertiaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Profile Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                icon: Icons.access_time,
                label: 'Member Since',
                value: _formatDate(profile?.createdAt),
              ),
              Container(
                width: 1,
                height: 40,
                color: MetaColors.borderLight,
              ),
              _buildStatCard(
                icon: Icons.update,
                label: 'Last Updated',
                value: _formatDate(profile?.updatedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: MetaColors.primaryBlue,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: MetaColors.tertiaryText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: MetaColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

