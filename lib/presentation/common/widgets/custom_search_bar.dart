import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onSearch;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final double borderRadius;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.borderRadius = 50.0, // Airbnb uses highly rounded search bars
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _clearButtonAnimation;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for clear button
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _clearButtonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Set initial visibility based on text
    _updateClearButtonVisibility();
    
    // Add listener to track text changes
    widget.controller.addListener(_updateClearButtonVisibility);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_updateClearButtonVisibility);
    _animationController.dispose();
    super.dispose();
  }
  
  void _updateClearButtonVisibility() {
    final shouldShow = widget.controller.text.isNotEmpty;
    
    if (shouldShow != _showClearButton) {
      setState(() {
        _showClearButton = shouldShow;
      });
      
      if (shouldShow) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Hero(
      tag: 'searchBar',
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 48, // Material3 standard height
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24), // Fully rounded Material3 style
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            onTap: widget.onTap,
            onChanged: widget.onSearch,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
              prefixIcon: Icon(
                LucideIcons.search, 
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: AnimatedBuilder(
                animation: _clearButtonAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _clearButtonAnimation.value,
                    child: _clearButtonAnimation.value > 0 ? IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          LucideIcons.x, 
                          size: 14, 
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onSearch('');
                      },
                    ) : null,
                  );
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center,
          ),
        ),
      ),
    );
  }
}
