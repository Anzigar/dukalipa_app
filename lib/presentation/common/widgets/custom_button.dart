import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

enum ButtonSize { small, medium, large }
enum ButtonVariant { primary, secondary, text, outlined }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final Color? foregroundColor; // For text/icon color
  final Color? borderColor; // For border color

  const CustomButton({
    Key? key, // Use unique keys for each button
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 50.0, // Increased to 50.0 for fully rounded button appearance
    this.fullWidth = true,
    this.padding,
    this.foregroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Use theme colors for better consistency
    final colorScheme = Theme.of(context).colorScheme;
    final defaultPrimaryColor = colorScheme.primary;

    // Determine effective colors based on provided props or defaults
    final defaultBackgroundColor =
        widget.isOutlined ? Colors.transparent : defaultPrimaryColor;
    final defaultTextColor =
        widget.isOutlined ? defaultPrimaryColor : colorScheme.onPrimary;

    // Use the most specific color provided, falling back to defaults
    final effectiveTextColor =
        widget.textColor ?? widget.foregroundColor ?? defaultTextColor;
    final effectiveBorderColor = widget.borderColor ?? defaultPrimaryColor;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? defaultBackgroundColor;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.fullWidth ? double.infinity : null,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: InkWell(
                  onTap: widget.isLoading
                      ? null
                      : () {
                          try {
                            HapticFeedback.lightImpact();
                          } catch (_) {
                            // Ignore haptic errors
                          }
                          widget.onPressed();
                        },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: effectiveBackgroundColor,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: widget.isOutlined
                          ? Border.all(color: effectiveBorderColor, width: 1.5)
                          : null,
                      // Removed boxShadow for flat design consistency
                    ),
                    child: Padding(
                      padding: widget.padding ??
                          EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: widget.fullWidth ? 16 : 24),
                      child: Row(
                        mainAxisSize:
                            widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: effectiveTextColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (widget.isLoading)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    effectiveTextColor),
                              ),
                            )
                          else
                            Text(
                              widget.text,
                              style: GoogleFonts.poppins(
                                color: effectiveTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MetaActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const MetaActionButton({
    Key? key, // Important: Ensure unique keys
    required this.text,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: AppTheme.mkbhdRed,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style:  GoogleFonts.poppins(
                  color: AppTheme.mkbhdRed,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


