import 'package:flutter/material.dart';

/// Animated Theme Switcher Widget that provides smooth transitions
/// between light and dark themes using Material 3 design principles
class AnimatedThemeSwitcher extends StatefulWidget {
  final Widget child;
  final ThemeData theme;
  final Duration duration;
  final Curve curve;

  const AnimatedThemeSwitcher({
    super.key,
    required this.child,
    required this.theme,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCubicEmphasized, // Material 3 preferred curve
  });

  @override
  State<AnimatedThemeSwitcher> createState() => _AnimatedThemeSwitcherState();
}

class _AnimatedThemeSwitcherState extends State<AnimatedThemeSwitcher>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ThemeData _previousTheme;
  late ThemeData _currentTheme;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _currentTheme = widget.theme;
    _previousTheme = widget.theme;
  }

  @override
  void didUpdateWidget(AnimatedThemeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.theme != widget.theme) {
      _previousTheme = oldWidget.theme;
      _currentTheme = widget.theme;
      
      if (!_isAnimating) {
        _startAnimation();
      }
    }
    
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  void _startAnimation() {
    setState(() {
      _isAnimating = true;
    });
    
    _controller.reset();
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _previousTheme = _currentTheme;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimating) {
      return Theme(
        data: _currentTheme,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Previous theme (underneath)
            Theme(
              data: _previousTheme,
              child: widget.child,
            ),
            // Current theme (on top with opacity animation)
            Opacity(
              opacity: _animation.value,
              child: Theme(
                data: _currentTheme,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Enhanced Animated Theme Switcher with circular reveal animation
/// Perfect for dark mode toggle buttons
class CircularRevealThemeSwitcher extends StatefulWidget {
  final Widget child;
  final ThemeData theme;
  final Duration duration;
  final Alignment? revealAlignment;
  final double? revealRadius;

  const CircularRevealThemeSwitcher({
    super.key,
    required this.child,
    required this.theme,
    this.duration = const Duration(milliseconds: 600),
    this.revealAlignment,
    this.revealRadius,
  });

  @override
  State<CircularRevealThemeSwitcher> createState() => _CircularRevealThemeSwitcherState();
}

class _CircularRevealThemeSwitcherState extends State<CircularRevealThemeSwitcher>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late ThemeData _previousTheme;
  late ThemeData _currentTheme;
  bool _isAnimating = false;
  Alignment? _revealCenter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _radiusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    ));
    
    _currentTheme = widget.theme;
    _previousTheme = widget.theme;
  }

  @override
  void didUpdateWidget(CircularRevealThemeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.theme != widget.theme) {
      _previousTheme = oldWidget.theme;
      _currentTheme = widget.theme;
      _revealCenter = widget.revealAlignment;
      
      if (!_isAnimating) {
        _startAnimation();
      }
    }
  }

  void _startAnimation() {
    setState(() {
      _isAnimating = true;
    });
    
    _controller.reset();
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _previousTheme = _currentTheme;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimating) {
      return Theme(
        data: _currentTheme,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _radiusAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Previous theme (background)
            Theme(
              data: _previousTheme,
              child: widget.child,
            ),
            // Current theme with circular reveal
            ClipPath(
              clipper: CircularRevealClipper(
                fraction: _radiusAnimation.value,
                centerAlignment: _revealCenter ?? Alignment.center,
              ),
              child: Theme(
                data: _currentTheme,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom clipper for circular reveal animation
class CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Alignment centerAlignment;

  CircularRevealClipper({
    required this.fraction,
    required this.centerAlignment,
  });

  @override
  Path getClip(Size size) {
    final center = centerAlignment.resolve(TextDirection.ltr).withinRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    
    // Calculate the maximum possible radius
    final maxRadius = _getMaxRadius(size, center);
    final currentRadius = fraction * maxRadius;
    
    final path = Path();
    path.addOval(
      Rect.fromCircle(center: center, radius: currentRadius),
    );
    
    return path;
  }

  double _getMaxRadius(Size size, Offset center) {
    final topLeft = center.distance;
    final topRight = (Offset(size.width, 0) - center).distance;
    final bottomLeft = (Offset(0, size.height) - center).distance;
    final bottomRight = (Offset(size.width, size.height) - center).distance;
    
    return [topLeft, topRight, bottomLeft, bottomRight].reduce(
      (a, b) => a > b ? a : b,
    );
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) {
    return oldClipper.fraction != fraction ||
        oldClipper.centerAlignment != centerAlignment;
  }
}

/// Slide Transition Theme Switcher
/// Creates a smooth slide effect when switching themes
class SlideThemeSwitcher extends StatefulWidget {
  final Widget child;
  final ThemeData theme;
  final Duration duration;
  final SlideDirection direction;

  const SlideThemeSwitcher({
    super.key,
    required this.child,
    required this.theme,
    this.duration = const Duration(milliseconds: 400),
    this.direction = SlideDirection.leftToRight,
  });

  @override
  State<SlideThemeSwitcher> createState() => _SlideThemeSwitcherState();
}

enum SlideDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }

class _SlideThemeSwitcherState extends State<SlideThemeSwitcher>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late ThemeData _previousTheme;
  late ThemeData _currentTheme;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: _getSlideBegin(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    
    _currentTheme = widget.theme;
    _previousTheme = widget.theme;
  }

  Offset _getSlideBegin() {
    switch (widget.direction) {
      case SlideDirection.leftToRight:
        return const Offset(-1.0, 0.0);
      case SlideDirection.rightToLeft:
        return const Offset(1.0, 0.0);
      case SlideDirection.topToBottom:
        return const Offset(0.0, -1.0);
      case SlideDirection.bottomToTop:
        return const Offset(0.0, 1.0);
    }
  }

  @override
  void didUpdateWidget(SlideThemeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.theme != widget.theme) {
      _previousTheme = oldWidget.theme;
      _currentTheme = widget.theme;
      
      if (!_isAnimating) {
        _startAnimation();
      }
    }
  }

  void _startAnimation() {
    setState(() {
      _isAnimating = true;
    });
    
    _controller.reset();
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _previousTheme = _currentTheme;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimating) {
      return Theme(
        data: _currentTheme,
        child: widget.child,
      );
    }

    return Stack(
      children: [
        // Previous theme (static background)
        Theme(
          data: _previousTheme,
          child: widget.child,
        ),
        // Current theme (sliding in)
        SlideTransition(
          position: _slideAnimation,
          child: Theme(
            data: _currentTheme,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}