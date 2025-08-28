import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/theme_provider.dart';

/// Animated Theme Toggle Button with smooth transitions
/// Perfect for switching between light and dark modes
class AnimatedThemeToggle extends StatefulWidget {
  final double size;
  final Duration animationDuration;
  final Color? lightModeColor;
  final Color? darkModeColor;
  final bool showLabel;
  final String? lightLabel;
  final String? darkLabel;

  const AnimatedThemeToggle({
    super.key,
    this.size = 24.0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.lightModeColor,
    this.darkModeColor,
    this.showLabel = false,
    this.lightLabel = 'Light',
    this.darkLabel = 'Dark',
  });

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorAnimation = ColorTween(
      begin: widget.lightModeColor ?? Colors.orange.shade400,
      end: widget.darkModeColor ?? Colors.blue.shade300,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Set initial state based on current theme
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

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentTheme = themeProvider.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine next theme mode
    ThemeMode nextMode;
    if (currentTheme == ThemeMode.system) {
      nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    } else {
      nextMode = currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }

    // Animate the toggle
    if (nextMode == ThemeMode.dark) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    // Change theme with animation
    themeProvider.setThemeModeAnimated(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return GestureDetector(
              onTap: _toggleTheme,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                child: widget.showLabel
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIconWidget(),
                          SizedBox(width: 8.w),
                          Text(
                            isDark ? (widget.darkLabel ?? 'Dark') : (widget.lightLabel ?? 'Light'),
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      )
                    : _buildIconWidget(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconWidget() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Icon(
              _controller.value > 0.5 ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: widget.size,
              color: _colorAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

/// Material Design 3 Style Theme Toggle Switch
/// Resembles a toggle switch for theme switching
class M3ThemeSwitch extends StatefulWidget {
  final ValueChanged<bool>? onChanged;
  final bool value;
  final double width;
  final double height;

  const M3ThemeSwitch({
    super.key,
    this.onChanged,
    this.value = false,
    this.width = 60.0,
    this.height = 32.0,
  });

  @override
  State<M3ThemeSwitch> createState() => _M3ThemeSwitchState();
}

class _M3ThemeSwitchState extends State<M3ThemeSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _trackColorAnimation;
  late Animation<Color?> _thumbColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
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
  }

  @override
  void didUpdateWidget(M3ThemeSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final newValue = !widget.value;
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                color: _trackColorAnimation.value,
              ),
              child: Stack(
                children: [
                  // Thumb
                  Positioned(
                    left: _slideAnimation.value * (widget.width - widget.height),
                    top: 0,
                    child: Container(
                      width: widget.height,
                      height: widget.height,
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
                          widget.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          size: 16.sp,
                          color: widget.value 
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
    );
  }
}

/// Theme Toggle List Tile for Settings Screens
class ThemeToggleListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onTap;

  const ThemeToggleListTile({
    super.key,
    this.title = 'Dark Mode',
    this.subtitle,
    this.leadingIcon = Icons.dark_mode_outlined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return ListTile(
          leading: leadingIcon != null 
              ? Icon(
                  leadingIcon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : null,
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: M3ThemeSwitch(
            value: isDark,
            onChanged: (value) {
              final nextMode = value ? ThemeMode.dark : ThemeMode.light;
              themeProvider.setThemeModeAnimated(nextMode);
              onTap?.call();
            },
          ),
          onTap: () {
            final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
            themeProvider.setThemeModeAnimated(nextMode);
            onTap?.call();
          },
        );
      },
    );
  }
}