import 'package:flutter/material.dart';

/// A widget that improves Column/Row layouts to prevent overflow issues
class FlexSafeArea extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final Axis direction;
  final bool withScrollView;

  const FlexSafeArea({
    Key? key,
    required this.children,
    this.direction = Axis.vertical,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.withScrollView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;
    
    // Create the flex layout (Column or Row)
    if (direction == Axis.vertical) {
      content = Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    } else {
      content = Row(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }
    
    // Wrap with SingleChildScrollView if needed
    if (withScrollView) {
      return SingleChildScrollView(
        scrollDirection: direction,
        physics: const ClampingScrollPhysics(),
        child: content,
      );
    }
    
    return content;
  }
}

/// A shrink-wrapped container that prevents overflow issues
class SafeContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final BoxDecoration? decoration;
  final double? maxWidth;
  final double? maxHeight;

  const SafeContainer({
    Key? key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.color,
    this.decoration,
    this.maxWidth,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      child: child,
    );
  }
}

/// A widget that wraps its child in a flexible container to prevent overflow
extension WidgetExtensions on Widget {
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);
  
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
  
  Widget shrinkWrapped() => this is SingleChildScrollView 
    ? this
    : SingleChildScrollView(
        child: this,
        physics: const ClampingScrollPhysics(),
      );
}
