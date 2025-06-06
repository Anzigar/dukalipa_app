import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A Material 3 styled expressive range slider with animated price chips and fluid animations
class M3ExpressiveRangeSlider extends StatefulWidget {
  /// The currently selected values for the slider.
  final RangeValues values;
  
  /// Minimum value the slider can represent.
  final double min;
  
  /// Maximum value the slider can represent.
  final double max;
  
  /// Callback for when the values change.
  final ValueChanged<RangeValues> onChanged;
  
  /// Optional callback for when the user starts changing the slider.
  final ValueChanged<RangeValues>? onChangeStart;
  
  /// Optional callback for when the user finishes changing the slider.
  final ValueChanged<RangeValues>? onChangeEnd;
  
  /// Number of discrete divisions for the slider.
  final int? divisions;
  
  /// Format string for the currency symbol and values.
  final String currencyFormat;
  
  /// Show label texts at min, middle and max values
  final bool showLabels;
  
  /// Optional middle point label (defaults to halfway between min and max)
  final String? middleLabel;
  
  /// Option to enable value indicators that appear above thumbs while sliding
  final bool showValueIndicator;
  
  /// Option to enable haptic feedback when sliding
  final bool enableHapticFeedback;

  const M3ExpressiveRangeSlider({
    Key? key,
    required this.values,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.onChangeStart,
    this.onChangeEnd,
    this.divisions,
    this.currencyFormat = 'TSh %s',
    this.showLabels = true,
    this.middleLabel,
    this.showValueIndicator = true,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<M3ExpressiveRangeSlider> createState() => _M3ExpressiveRangeSliderState();
}

class _M3ExpressiveRangeSliderState extends State<M3ExpressiveRangeSlider> 
    with SingleTickerProviderStateMixin {
  bool _isInteracting = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup pulse animation for interactive feedback
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      )
    )..addListener(() {
      setState(() {});
    });
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    final formatted = value.round().toString();
    return widget.currencyFormat.replaceAll('%s', formatted);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price values display with M3 expressive styling
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Start price chip with Material 3 animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isInteracting 
                      ? colorScheme.primaryContainer 
                      : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isInteracting ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ] : null,
                ),
                child: Text(
                  _formatValue(widget.values.start),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: _isInteracting ? 14 : 13,
                    color: _isInteracting 
                        ? colorScheme.onPrimaryContainer 
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              
              // Price range indicator line with gradient
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background track
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      
                      // Active track with gradient
                      if (_isInteracting)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withOpacity(0.7),
                                colorScheme.primary,
                                colorScheme.primary.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // End price chip with Material 3 animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isInteracting 
                      ? colorScheme.primaryContainer 
                      : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isInteracting ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ] : null,
                ),
                child: Text(
                  _formatValue(widget.values.end),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: _isInteracting ? 14 : 13,
                    color: _isInteracting 
                        ? colorScheme.onPrimaryContainer 
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Material 3 Expressive RangeSlider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.surfaceVariant,
            thumbColor: colorScheme.primaryContainer,
            activeTickMarkColor: colorScheme.onPrimary.withOpacity(0.3),
            inactiveTickMarkColor: colorScheme.onSurfaceVariant.withOpacity(0.3),
            overlayColor: colorScheme.primary.withOpacity(0.12),
            // Use custom thumb shapes with expressive design
            thumbShape: _ExpressiveSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: _isInteracting ? 4 : 2,
              pressedElevation: 6,
              isInteracting: _isInteracting,
              colorScheme: colorScheme,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            rangeThumbShape: _ExpressiveRangeSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: _isInteracting ? 4 : 2,
              pressedElevation: 6,
              isInteracting: _isInteracting,
              colorScheme: colorScheme,
            ),
            rangeTrackShape: _ExpressiveRangeSliderTrackShape(
              isInteracting: _isInteracting,
              colorScheme: colorScheme,
            ),
            showValueIndicator: widget.showValueIndicator 
                ? ShowValueIndicator.always 
                : ShowValueIndicator.never,
            valueIndicatorColor: colorScheme.primaryContainer,
            valueIndicatorTextStyle: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            tickMarkShape: _ExpressiveSliderTickMarkShape(
              isInteracting: _isInteracting,
              colorScheme: colorScheme,
            ),
          ),
          child: RangeSlider(
            values: widget.values,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            labels: RangeLabels(
              _formatValue(widget.values.start),
              _formatValue(widget.values.end),
            ),
            onChanged: widget.onChanged,
            onChangeStart: (values) {
              setState(() {
                _isInteracting = true;
              });
              if (widget.onChangeStart != null) {
                widget.onChangeStart!(values);
              }
            },
            onChangeEnd: (values) {
              setState(() {
                _isInteracting = false;
              });
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(values);
              }
            },
          ),
        ),
        
        if (widget.showLabels) ...[
          const SizedBox(height: 12),
          
          // Range labels with Material 3 styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatValue(widget.min),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                // Middle value
                Text(
                  widget.middleLabel ?? _formatValue((widget.min + widget.max) / 2),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatValue(widget.max),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// Custom thumb shape for expressive slider with Material 3 styling
class _ExpressiveSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final double elevation;
  final double pressedElevation;
  final bool isInteracting;
  final ColorScheme colorScheme;
  
  const _ExpressiveSliderThumbShape({
    required this.enabledThumbRadius,
    this.elevation = 2.0,
    this.pressedElevation = 6.0,
    required this.isInteracting,
    required this.colorScheme,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final radius = enabledThumbRadius * (isInteracting ? 1.1 : 1.0);
    
    // Draw shadow
    final shadowPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(0, 1),
          radius: radius,
        ),
      );
      
    canvas.drawShadow(
      shadowPath,
      Colors.black,
      isInteracting ? pressedElevation : elevation,
      true,
    );
    
    // Draw main thumb
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, radius, paint);

    // Draw inner highlight when interacting
    if (isInteracting) {
      final highlightPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius * 0.7,
          [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0),
          ],
          [0.0, 1.0],
        );
      
      canvas.drawCircle(center, radius * 0.7, highlightPaint);
      
      // Draw outer glow
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = ui.Gradient.radial(
          center,
          radius + 4,
          [
            colorScheme.primary.withOpacity(0.3),
            colorScheme.primary.withOpacity(0.0),
          ],
          [0.7, 1.0],
        );
      
      canvas.drawCircle(center, radius + 4, glowPaint);
    }
  }
}

// Custom range thumb shape with Material 3 expressive styling
class _ExpressiveRangeSliderThumbShape extends RangeSliderThumbShape {
  final double enabledThumbRadius;
  final double elevation;
  final double pressedElevation;
  final bool isInteracting;
  final ColorScheme colorScheme;
  
  const _ExpressiveRangeSliderThumbShape({
    required this.enabledThumbRadius,
    this.elevation = 2.0,
    this.pressedElevation = 6.0,
    required this.isInteracting,
    required this.colorScheme,
  });
  
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }
  
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;
    final isThumbPressed = isPressed == true;
    final radius = enabledThumbRadius * ((isThumbPressed || isInteracting) ? 1.1 : 1.0);
    
    // Draw shadow
    final shadowPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(0, 1),
          radius: radius,
        ),
      );
      
    canvas.drawShadow(
      shadowPath,
      Colors.black,
      (isThumbPressed || isInteracting) ? pressedElevation : elevation,
      true,
    );
    
    // Draw main thumb
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, radius, paint);
    
    // Draw inner highlight when interacting or pressed
    if (isThumbPressed || isInteracting) {
      final highlightPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius * 0.7,
          [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0),
          ],
          [0.0, 1.0],
        );
      
      canvas.drawCircle(center, radius * 0.7, highlightPaint);
      
      // Draw outer glow
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = ui.Gradient.radial(
          center,
          radius + 4,
          [
            colorScheme.primary.withOpacity(0.3),
            colorScheme.primary.withOpacity(0.0),
          ],
          [0.7, 1.0],
        );
      
      canvas.drawCircle(center, radius + 4, glowPaint);
    }
  }
}

// Custom track shape for expressive range slider
class _ExpressiveRangeSliderTrackShape extends RoundedRectRangeSliderTrackShape {
  final bool isInteracting;
  final ColorScheme colorScheme;
  
  const _ExpressiveRangeSliderTrackShape({
    required this.isInteracting,
    required this.colorScheme,
  });
  
  @override
  void paint(
    PaintingContext context, 
    Offset offset, {
    required RenderBox parentBox, 
    required SliderThemeData sliderTheme, 
    required Animation<double> enableAnimation, 
    required Offset startThumbCenter, 
    required Offset endThumbCenter, 
    bool isEnabled = false, 
    bool isDiscrete = false, 
    required TextDirection textDirection, 
    double additionalActiveTrackHeight = 0,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 6;
    final trackLeft = startThumbCenter.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackRight = endThumbCenter.dx;
    final trackBottom = trackTop + trackHeight;
    final activeTrackRadius = Radius.circular(trackHeight / 2);
    final inactiveTrackRadius = Radius.circular(trackHeight / 2);
    
    final Canvas canvas = context.canvas;
    
    // Inactive track
    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;
    
    final inactiveTrackRect = Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveTrackRect, inactiveTrackRadius),
      inactivePaint,
    );
    
    // Active track
    final activeTrackRect = Rect.fromLTRB(
      trackLeft, 
      trackTop - (isInteracting ? 1 : 0),
      trackRight, 
      trackBottom + (isInteracting ? 1 : 0)
    );
    
    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor!;
      
    if (isInteracting) {
      // Add gradient and glow when interacting
      activePaint.shader = ui.Gradient.linear(
        Offset(trackLeft, trackTop),
        Offset(trackRight, trackTop),
        [
          colorScheme.primary.withOpacity(0.9),
          colorScheme.primary,
          colorScheme.primary.withOpacity(0.9),
        ],
        [0.0, 0.5, 1.0],
      );
      
      // Draw glow underneath the track
      final glowPaint = Paint()
        ..color = colorScheme.primary.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          activeTrackRect.inflate(1),
          activeTrackRadius,
        ),
        glowPaint,
      );
    }
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeTrackRect, activeTrackRadius),
      activePaint,
    );
  }
}

// Custom tick mark shape for expressive slider
class _ExpressiveSliderTickMarkShape extends RoundSliderTickMarkShape {
  final bool isInteracting;
  final ColorScheme colorScheme;
  
  const _ExpressiveSliderTickMarkShape({
    required this.isInteracting,
    required this.colorScheme,
  });
  
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> enableAnimation,
    required bool isEnabled,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required Offset thumbCenter,
  }) {
    // Determine if tick mark is active by comparing its position with thumb position
    final bool isActive = (thumbCenter.dx - center.dx).abs() <= 1.0;

    // Only paint if divisions are enabled
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }
    
    final Canvas canvas = context.canvas;
    final tickMarkRadius = isActive ? 3.0 : 2.5;
    
    final paint = Paint()
      ..color = isActive 
          ? sliderTheme.activeTickMarkColor!
          : sliderTheme.inactiveTickMarkColor!;
    
    if (isInteracting && isActive) {
      // Add glow for active tick marks when interacting
      final glowPaint = Paint()
        ..color = colorScheme.primary.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(center, tickMarkRadius + 1, glowPaint);
    }
    
    canvas.drawCircle(center, tickMarkRadius, paint);
  }
}
