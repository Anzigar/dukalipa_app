import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

/// Enhanced empty state widget with Lottie animation support
/// Uses animations from assets/animations/ folder
class AnimatedEmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? lottieAsset;
  final double? iconSize;
  final bool repeat;
  final Duration? duration;

  const AnimatedEmptyState({
    Key? key,
    this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.lottieAsset,
    this.iconSize,
    this.repeat = true,
    this.duration,
  }) : super(key: key);

  /// Factory constructor for inventory empty state
  factory AnimatedEmptyState.inventory({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return AnimatedEmptyState(
      lottieAsset: 'assets/animations/Empty_box.json',
      title: title ?? 'No Products Found',
      message: message ?? 'Your inventory is empty. Add some products to get started.',
      buttonText: buttonText ?? 'Add Product',
      onButtonPressed: onButtonPressed,
    );
  }

  /// Factory constructor for sales empty state
  factory AnimatedEmptyState.sales({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return AnimatedEmptyState(
      lottieAsset: 'assets/animations/No_Data.json',
      title: title ?? 'No Sales Yet',
      message: message ?? 'Start making sales to see them here.',
      buttonText: buttonText ?? 'Make Sale',
      onButtonPressed: onButtonPressed,
    );
  }

  /// Factory constructor for customers empty state
  factory AnimatedEmptyState.customers({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return AnimatedEmptyState(
      lottieAsset: 'assets/animations/No_Data.json',
      title: title ?? 'No Customers Yet',
      message: message ?? 'Add customers to manage their information and purchases.',
      buttonText: buttonText ?? 'Add Customer',
      onButtonPressed: onButtonPressed,
    );
  }

  /// Factory constructor for expenses empty state
  factory AnimatedEmptyState.expenses({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return AnimatedEmptyState(
      lottieAsset: 'assets/animations/No_Data.json',
      title: title ?? 'No Expenses Recorded',
      message: message ?? 'Track your business expenses to monitor cash flow.',
      buttonText: buttonText ?? 'Add Expense',
      onButtonPressed: onButtonPressed,
    );
  }

  /// Factory constructor for installments empty state
  factory AnimatedEmptyState.installments({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return AnimatedEmptyState(
      lottieAsset: 'assets/animations/Empty_box.json',
      title: title ?? 'No Installment Plans',
      message: message ?? 'Create installment plans to offer flexible payment options.',
      buttonText: buttonText ?? 'Create Plan',
      onButtonPressed: onButtonPressed,
    );
  }

  /// Factory constructor for returns empty state
  factory AnimatedEmptyState.returns({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return AnimatedEmptyState(
      lottieAsset: 'assets/animations/No_Data.json',
      title: title ?? 'No Returns Recorded',
      message: message ?? 'Product returns and refunds will appear here.',
      buttonText: buttonText ?? 'Process Return',
      onButtonPressed: onButtonPressed,
    );
  }

  /// Factory constructor for damaged products empty state
  factory AnimatedEmptyState.damaged({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return AnimatedEmptyState(
      lottieAsset: 'assets/animations/Empty_box.json',
      title: title ?? 'No Damaged Products',
      message: message ?? 'Track damaged products to manage inventory losses.',
      buttonText: buttonText ?? 'Report Damage',
      onButtonPressed: onButtonPressed,
    );
  }

  /// Factory constructor for notifications empty state
  factory AnimatedEmptyState.notifications({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return AnimatedEmptyState(
      lottieAsset: 'assets/animations/Notification_bell.json',
      title: title ?? 'No Notifications',
      message: message ?? 'You\'re all caught up! New notifications will appear here.',
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation or Icon Container
            Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              child: lottieAsset != null
                  ? ClipOval(
                      child: Lottie.asset(
                        lottieAsset!,
                        width: 120.w,
                        height: 120.h,
                        fit: BoxFit.contain,
                        repeat: repeat,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if animation fails to load
                          return Icon(
                            icon ?? LucideIcons.fileX,
                            size: iconSize ?? 60.sp,
                            color: AppTheme.mkbhdRed,
                          );
                        },
                      ),
                    )
                  : Icon(
                      icon ?? LucideIcons.fileX,
                      size: iconSize ?? 60.sp,
                      color: AppTheme.mkbhdRed,
                    ),
            ),
            SizedBox(height: 24.h),
            
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            
            // Action Button
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 32.h),
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onButtonPressed!();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.mkbhdRed,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                  minimumSize: Size(0, 44.h),
                ),
                icon: Icon(LucideIcons.plus, size: 18.sp),
                label: Text(
                  buttonText!,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state widget with Lottie animation
class AnimatedLoadingState extends StatelessWidget {
  final String? message;
  final String? lottieAsset;

  const AnimatedLoadingState({
    Key? key,
    this.message,
    this.lottieAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loading Animation
          Container(
            width: 100.w,
            height: 100.h,
            child: lottieAsset != null
                ? Lottie.asset(
                    lottieAsset!,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                    errorBuilder: (context, error, stackTrace) {
                      return CircularProgressIndicator(
                        color: AppTheme.mkbhdRed,
                        strokeWidth: 3,
                      );
                    },
                  )
                : CircularProgressIndicator(
                    color: AppTheme.mkbhdRed,
                    strokeWidth: 3,
                  ),
          ),
          
          if (message != null) ...[
            SizedBox(height: 20.h),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Factory constructor for general loading
  factory AnimatedLoadingState.general({String? message}) {
    return AnimatedLoadingState(
      lottieAsset: 'assets/animations/loader1.json',
      message: message ?? 'Loading...',
    );
  }

  /// Factory constructor for data processing
  factory AnimatedLoadingState.processing({String? message}) {
    return AnimatedLoadingState(
      lottieAsset: 'assets/animations/loader2.json',
      message: message ?? 'Processing...',
    );
  }
}