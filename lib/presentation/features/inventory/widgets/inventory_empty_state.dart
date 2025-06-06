import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../common/widgets/empty_state.dart';

class InventoryEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? svgAsset;

  const InventoryEmptyState({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
    this.svgAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: LucideIcons.package,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      svgAsset: svgAsset,
    );
  }
}
