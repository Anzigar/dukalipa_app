import 'package:flutter/material.dart';

/// Custom thumb shape for Material 3 expressive sliders
class _M3ExpressiveThumbShape extends SliderComponentShape {
  final bool isInteracting;
  
  const _M3ExpressiveThumbShape({required this.isInteracting});
  
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(PaintingContext context, Offset center, 
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    
    final Canvas canvas = context.canvas;
    
    // Dynamic sizing based on interaction state
    final outerRadius = isInteracting ? 12.0 : 10.0;
    final innerRadius = isInteracting ? 8.0 : 6.0;
    
    // Draw outer circle (border)
    final outerPaint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, outerRadius, outerPaint);
    
    // Draw inner circle
    final innerPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
}

/// Custom range thumb shape for Material 3 expressive range sliders
class _M3ExpressiveRangeThumbShape extends RangeSliderThumbShape {
  final bool isInteracting;
  
  const _M3ExpressiveRangeThumbShape({required this.isInteracting});
  
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
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
    final Canvas canvas = context.canvas;
    
    final pressed = isPressed ?? false;
    // Dynamic sizing based on interaction state
    final outerRadius = (pressed || isInteracting) ? 12.0 : 10.0;
    final innerRadius = (pressed || isInteracting) ? 8.0 : 6.0;
    
    // Draw outer circle (border)
    final outerPaint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, outerRadius, outerPaint);
    
    // Draw inner circle
    final innerPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
}

/// A Material 3 expressive slider that enhances the standard slider with
/// additional visual feedback and animations.
class M3ExpressiveSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;

  const M3ExpressiveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<M3ExpressiveSlider> createState() => _M3ExpressiveSliderState();
}

class _M3ExpressiveSliderState extends State<M3ExpressiveSlider> {
  bool isInteracting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: widget.activeColor ?? colorScheme.primary,
        inactiveTrackColor: widget.inactiveColor ?? colorScheme.surfaceVariant,
        thumbColor: colorScheme.primaryContainer,
        overlayColor: colorScheme.primary.withOpacity(0.12),
        thumbShape: _M3ExpressiveThumbShape(isInteracting: isInteracting),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        trackShape: const RoundedRectSliderTrackShape(),
        showValueIndicator: ShowValueIndicator.always,
        valueIndicatorColor: colorScheme.primaryContainer,
        valueIndicatorTextStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Slider(
        value: widget.value,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        label: widget.label,
        onChanged: widget.onChanged,
        onChangeStart: (value) {
          setState(() {
            isInteracting = true;
          });
          if (widget.onChangeStart != null) {
            widget.onChangeStart!(value);
          }
        },
        onChangeEnd: (value) {
          setState(() {
            isInteracting = false;
          });
          if (widget.onChangeEnd != null) {
            widget.onChangeEnd!(value);
          }
        },
      ),
    );
  }
}

/// A Material 3 expressive range slider that enhances the standard range slider
/// with additional visual feedback and animations.
class M3ExpressiveRangeSlider extends StatefulWidget {
  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  final ValueChanged<RangeValues>? onChangeStart;
  final ValueChanged<RangeValues>? onChangeEnd;
  final int? divisions;
  final RangeLabels? labels;
  final Color? activeColor;
  final Color? inactiveColor;

  const M3ExpressiveRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labels,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<M3ExpressiveRangeSlider> createState() => _M3ExpressiveRangeSliderState();
}

class _M3ExpressiveRangeSliderState extends State<M3ExpressiveRangeSlider> {
  bool isInteracting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: widget.activeColor ?? colorScheme.primary,
        inactiveTrackColor: widget.inactiveColor ?? colorScheme.surfaceVariant,
        thumbColor: colorScheme.primaryContainer,
        overlayColor: colorScheme.primary.withOpacity(0.12),
        rangeThumbShape: _M3ExpressiveRangeThumbShape(isInteracting: isInteracting),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
        showValueIndicator: ShowValueIndicator.always,
        valueIndicatorColor: colorScheme.primaryContainer,
        valueIndicatorTextStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: RangeSlider(
        values: widget.values,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        labels: widget.labels,
        onChanged: widget.onChanged,
        onChangeStart: (values) {
          setState(() {
            isInteracting = true;
          });
          if (widget.onChangeStart != null) {
            widget.onChangeStart!(values);
          }
        },
        onChangeEnd: (values) {
          setState(() {
            isInteracting = false;
          });
          if (widget.onChangeEnd != null) {
            widget.onChangeEnd!(values);
          }
        },
      ),
    );
  }
}
