import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Official Material 3 Expressive Search Bar Component
/// Follows Google's Material Design 3 SearchBar specifications
class Material3SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final List<Widget>? suggestions;
  final bool showSuggestions;

  const Material3SearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onTap,
    this.leading,
    this.trailing,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
    this.borderRadius,
    this.suggestions,
    this.showSuggestions = false,
  });

  @override
  State<Material3SearchBar> createState() => _Material3SearchBarState();
}

class _Material3SearchBarState extends State<Material3SearchBar> {
  bool _isFocused = false;
  bool _hasText = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText && mounted) {
      setState(() {
        _hasText = hasText;
      });
    }
  }


  void _onTap() {
    if (widget.readOnly && widget.onTap != null) {
      widget.onTap!();
    } else {
      setState(() {
        _isExpanded = true;
        _isFocused = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Material 3 Search Bar Specifications
    final effectiveHeight = widget.height ?? 56.h; // M3 standard height
    final effectiveWidth = widget.width ?? double.infinity;
    final effectiveElevation = _isFocused ? widget.elevation : 6.0;
    
    final effectiveBackgroundColor = widget.backgroundColor ?? 
        colorScheme.surfaceContainerHigh;
    final effectiveForegroundColor = widget.foregroundColor ?? 
        colorScheme.onSurface;
    
    // Material 3 uses full-width rounded rectangle with specific shape
    final shape = RoundedRectangleBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(28.r),
    );

    return Hero(
      tag: 'search_bar_${widget.controller.hashCode}',
      child: Material(
        type: MaterialType.transparency,
        child: _isExpanded && !widget.readOnly
            ? _buildExpandedSearchBar(context, colorScheme, textTheme)
            : _buildCompactSearchBar(
                context, 
                colorScheme, 
                textTheme, 
                effectiveWidth, 
                effectiveHeight, 
                effectiveElevation, 
                effectiveBackgroundColor, 
                effectiveForegroundColor, 
                shape
              ),
      ),
    );
  }

  Widget _buildCompactSearchBar(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    double width,
    double height,
    double elevation,
    Color backgroundColor,
    Color foregroundColor,
    RoundedRectangleBorder shape,
  ) {
    return Container(
      width: width,
      height: height,
      padding: widget.padding,
      child: Material(
        elevation: elevation,
        color: backgroundColor,
        shape: shape,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        child: InkWell(
          onTap: _onTap,
          borderRadius: shape.borderRadius as BorderRadius?,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                // Leading Icon
                widget.leading ?? Icon(
                  LucideIcons.search,
                  size: 24.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 16.w),
                
                // Search Text / Hint
                Expanded(
                  child: widget.controller.text.isNotEmpty
                      ? Text(
                          widget.controller.text,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: foregroundColor,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          widget.hintText,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                
                // Trailing Actions
                if (_hasText) ...[
                  SizedBox(width: 8.w),
                  _buildClearButton(colorScheme),
                ],
                if (widget.trailing != null) ...[
                  SizedBox(width: 8.w),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedSearchBar(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Input Field
        Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 56.h,
          padding: widget.padding,
          child: Material(
            elevation: widget.elevation,
            color: widget.backgroundColor ?? colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(28.r),
            ),
            shadowColor: colorScheme.shadow,
            surfaceTintColor: colorScheme.surfaceTint,
            child: Focus(
              onFocusChange: (focused) {
                if (!focused) {
                  // Delay collapse to allow for other interactions
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (mounted && !_hasText) {
                      setState(() {
                        _isExpanded = false;
                        _isFocused = false;
                      });
                    }
                  });
                } else {
                  setState(() {
                    _isFocused = true;
                  });
                }
              },
              child: TextField(
                controller: widget.controller,
                readOnly: false, // Always editable in expanded mode
                autofocus: true, // Auto-focus when expanded
                enabled: widget.enabled,
                onChanged: widget.onChanged,
                onSubmitted: (value) {
                  // Keep expanded if there's text, collapse if empty
                  if (value.isEmpty) {
                    setState(() {
                      _isExpanded = false;
                      _isFocused = false;
                    });
                  }
                },
                textInputAction: TextInputAction.search,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: widget.foregroundColor ?? colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                  prefixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = false;
                        _isFocused = false;
                      });
                      // Unfocus the text field
                      FocusScope.of(context).unfocus();
                    },
                    icon: Icon(
                      LucideIcons.arrowLeft,
                      size: 24.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Back',
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hasText) _buildClearButton(colorScheme),
                      if (widget.trailing != null) widget.trailing!,
                    ],
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  isDense: false,
                ),
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),
        ),
        
        // Suggestions List (if provided and shown)
        if (widget.showSuggestions && widget.suggestions != null && _isFocused)
          _buildSuggestionsList(colorScheme),
      ],
    );
  }

  Widget _buildSuggestionsList(ColorScheme colorScheme) {
    return Material(
      elevation: 3.0,
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        constraints: BoxConstraints(maxHeight: 200.h),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.suggestions!.length,
          itemBuilder: (context, index) {
            return widget.suggestions![index];
          },
        ),
      ),
    );
  }

  Widget _buildClearButton(ColorScheme colorScheme) {
    return IconButton(
      onPressed: () {
        widget.controller.clear();
        widget.onChanged?.call('');
      },
      icon: Icon(
        LucideIcons.x,
        size: 20.sp,
        color: colorScheme.onSurfaceVariant,
      ),
      tooltip: 'Clear search',
      constraints: BoxConstraints(
        minWidth: 48.w,
        minHeight: 48.h,
      ),
    );
  }
}

/// Google Material 3 Search Bar Theme Extension
class M3SearchBarTheme {
  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28.r),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2.0,
        ),
      ),
      hintStyle: GoogleFonts.poppins(
        color: colorScheme.onSurfaceVariant,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
    );
  }
}

/// Legacy CustomSearchBar - kept for backward compatibility
/// Use Material3SearchBar for new implementations
class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onSearch;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final double borderRadius;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSearch,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.borderRadius = 28.0, // M3 default
  });

  @override
  Widget build(BuildContext context) {
    return Material3SearchBar(
      controller: controller,
      hintText: hintText,
      onChanged: onSearch,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}