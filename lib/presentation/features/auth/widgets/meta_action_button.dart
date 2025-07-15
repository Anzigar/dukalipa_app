import 'package:flutter/material.dart';
import '../../../../core/theme/dukalipa_colors.dart';

class MetaActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  
  const MetaActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: TextButton.styleFrom(
        foregroundColor: AirbnbColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
