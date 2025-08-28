import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/theme_provider.dart';

/// Smooth Theme Toggle Button with visual feedback
class SmoothThemeToggle extends StatefulWidget {
  final double size;
  final bool showLabel;
  final String? lightLabel;
  final String? darkLabel;

  const SmoothThemeToggle({
    super.key,
    this.size = 40.0,
    this.showLabel = false,
    this.lightLabel = 'Light',
    this.darkLabel = 'Dark',
  });

  @override
  State<SmoothThemeToggle> createState() => _SmoothThemeToggleState();
}

class _SmoothThemeToggleState extends State<SmoothThemeToggle>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubicEmphasized,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));

    // Set initial state
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      _rotationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleTheme() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentTheme = themeProvider.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Animate press effect
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // Determine next theme mode
    ThemeMode nextMode;
    if (currentTheme == ThemeMode.system) {
      nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    } else {
      nextMode = currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }

    // Animate the icon rotation
    if (nextMode == ThemeMode.dark) {
      _rotationController.forward();
    } else {
      _rotationController.reverse();
    }

    // Change theme
    await themeProvider.setThemeModeAnimated(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return GestureDetector(
          onTap: _toggleTheme,
          child: AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159, // 180 degrees
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          key: ValueKey(isDark),
                          size: widget.size * 0.6,
                          color: isDark 
                              ? Colors.blue.shade300
                              : Colors.orange.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Smooth Theme Switch for Settings
class SmoothThemeSwitch extends StatefulWidget {
  final ValueChanged<bool>? onChanged;
  final String? title;
  final String? subtitle;

  const SmoothThemeSwitch({
    super.key,
    this.onChanged,
    this.title,
    this.subtitle,
  });

  @override
  State<SmoothThemeSwitch> createState() => _SmoothThemeSwitchState();
}

class _SmoothThemeSwitchState extends State<SmoothThemeSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _trackColorAnimation;
  late Animation<Color?> _thumbColorAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;
    
    _trackColorAnimation = ColorTween(
      begin: colorScheme.surfaceContainerHighest,
      end: colorScheme.primary,
    ).animate(_controller);

    _thumbColorAnimation = ColorTween(
      begin: colorScheme.onSurfaceVariant,
      end: colorScheme.onPrimary,
    ).animate(_controller);

    // Set initial state
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      _controller.value = 1.0;
    } else {
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleToggle() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    
    // Change theme immediately - Flutter will handle the animation
    themeProvider.setThemeModeAnimated(nextMode);
    widget.onChanged?.call(!isDark);
    
    // Animate the switch UI
    if (nextMode == ThemeMode.dark) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return ListTile(
          leading: Icon(
            Icons.palette_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: Text(
            widget.title ?? 'Dark Mode',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: widget.subtitle != null
              ? Text(
                  widget.subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: GestureDetector(
            onTap: _handleToggle,
            child: SizedBox(
              width: 60.w,
              height: 32.h,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.h),
                      color: _trackColorAnimation.value,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: _slideAnimation.value * (60.w - 32.h),
                          child: Container(
                            width: 32.h,
                            height: 32.h,
                            padding: EdgeInsets.all(4.w),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _thumbColorAnimation.value,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                size: 16.sp,
                                color: isDark 
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          onTap: _handleToggle,
        );
      },
    );
  }
}