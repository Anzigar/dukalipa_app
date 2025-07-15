import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText; // Added missing parameter
  final IconData? prefixIcon;
  final Widget? suffix;
  final Widget? suffixIcon; // Add this missing parameter
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final bool autofocus;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius; // Added border radius parameter

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText, // Added missing parameter to constructor
    this.prefixIcon,
    this.suffix,
    this.suffixIcon, // Add this to constructor params
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.contentPadding,
    this.borderRadius = 16.0, // Increased default from 8.0 to 16.0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText, // Use helperText in decoration
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              )
            : null,
        suffix: suffix,
        suffixIcon: suffixIcon, // Use the suffixIcon parameter
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // Using the border radius parameter
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // Using the border radius parameter
          borderSide: const BorderSide(
            color: AppTheme.mkbhdRed,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // Using the border radius parameter
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // Using the border radius parameter
          borderSide: const BorderSide(
            color: AppTheme.mkbhdRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // Using the border radius parameter
          borderSide: const BorderSide(
            color: AppTheme.mkbhdRed,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // Using the border radius parameter
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        filled: true,
        fillColor: isDarkMode 
            ? Colors.grey.shade900 
            : (enabled ? Colors.white : Colors.grey.shade100),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: autofocus,
      enabled: enabled,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }
}
