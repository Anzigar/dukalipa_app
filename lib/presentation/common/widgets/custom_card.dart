import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


enum CardElevation { none, low, medium, high }

class CustomCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final bool enableHaptic;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CustomCard({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.color,
    this.onTap,
    this.enableHaptic = true,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 6),
            child: Material(
              color: widget.color ?? Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap != null
                    ? () {
                        if (widget.enableHaptic) {
                          HapticFeedback.lightImpact();
                        }
                        widget.onTap!();
                      }
                    : null,
                onTapDown: (_) {
                  if (widget.onTap != null) {
                    _controller.forward();
                  }
                },
                onTapUp: (_) {
                  if (widget.onTap != null) {
                    _controller.reverse();
                  }
                },
                onTapCancel: () {
                  if (widget.onTap != null) {
                    _controller.reverse();
                  }
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
