import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;
  final dynamic profile;
  
  const ProfileHeader({
    Key? key,
    required this.viewModel,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.mkbhdRed.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.mkbhdRed.withOpacity(0.2),
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    viewModel.getInitials(profile?.name ?? ''),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mkbhdRed,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile?.name ?? 'User',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile?.email ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.mkbhdLightGrey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.mkbhdRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.mkbhdRed.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Text(
              profile?.role ?? 'Shop Owner',
              style: const TextStyle(
                color: AppTheme.mkbhdRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

