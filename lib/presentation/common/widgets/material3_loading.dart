import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 Loading Widget with Circular and Linear Indicators
class Material3Loading extends StatelessWidget {
  final String? message;
  final bool showLinearProgress;
  final bool showCircularProgress;
  final Color? primaryColor;
  final EdgeInsetsGeometry? padding;

  const Material3Loading({
    super.key,
    this.message,
    this.showLinearProgress = false,
    this.showCircularProgress = true,
    this.primaryColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectivePrimaryColor = primaryColor ?? colorScheme.primary;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: padding ?? EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Material 3 Circular Progress Indicator
              if (showCircularProgress) ...[
                SizedBox(
                  width: 48.w,
                  height: 48.w,
                  child: CircularProgressIndicator(
                    color: effectivePrimaryColor,
                    strokeWidth: 4.0,
                    backgroundColor: effectivePrimaryColor.withValues(alpha: 0.1),
                  ),
                ),
                if (showLinearProgress || message != null) SizedBox(height: 32.h),
              ],
              
              // Material 3 Linear Progress Indicator
              if (showLinearProgress) ...[
                Container(
                  width: 200.w,
                  height: 4.h,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  child: LinearProgressIndicator(
                    color: effectivePrimaryColor,
                    backgroundColor: effectivePrimaryColor.withValues(alpha: 0.1),
                    minHeight: 4.h,
                  ),
                ),
                if (message != null) SizedBox(height: 24.h),
              ],
              
              // Loading Message
              if (message != null) ...[
                Text(
                  message!,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Material 3 Home Loading Widget specifically for the home page
class Material3HomeLoading extends StatelessWidget {
  const Material3HomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header area placeholder
            Container(
              height: 180.h,
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // Greeting and profile row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            width: 140.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Search bar placeholder
                  Container(
                    height: 52.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main loading content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Material 3 Circular Progress Indicator
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 4.0,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  SizedBox(height: 24.h),
                  
                  // Loading message
                  Text(
                    'Loading your dashboard...',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  
                  // Linear Progress Indicator
                  Container(
                    width: 200.w,
                    height: 4.h,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.h),
                    ),
                    child: LinearProgressIndicator(
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      minHeight: 4.h,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom navigation placeholder
            Container(
              height: 80.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: index == 0 
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 40.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: index == 0 
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact Material 3 Loading Widget for inline usage
class Material3LoadingCompact extends StatelessWidget {
  final String? message;
  final double? size;

  const Material3LoadingCompact({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveSize = size ?? 24.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: CircularProgressIndicator(
            color: colorScheme.primary,
            strokeWidth: 3.0,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        if (message != null) ...[
          SizedBox(height: 12.h),
          Text(
            message!,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Material 3 Button Loading State
class Material3ButtonLoading extends StatelessWidget {
  final String? text;
  final Color? color;

  const Material3ButtonLoading({
    super.key,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.onPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18.w,
          height: 18.h,
          child: CircularProgressIndicator(
            color: effectiveColor,
            strokeWidth: 2.5,
          ),
        ),
        if (text != null) ...[
          SizedBox(width: 12.w),
          Text(
            text!,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: effectiveColor,
            ),
          ),
        ],
      ],
    );
  }
}