import 'package:flutter/material.dart';

/// Helper class to generate unique GlobalKeys
class KeyGenerator {
  // Private constructor to prevent instantiation
  KeyGenerator._();
  
  // Counter to ensure uniqueness
  static int _counter = 0;
  
  /// Generate a unique GlobalKey for FormState
  static GlobalKey<FormState> formKey() {
    return GlobalKey<FormState>(debugLabel: 'form_key_${_counter++}');
  }
  
  /// Generate a unique GlobalKey for any widget
  static GlobalKey<T> key<T extends State<StatefulWidget>>() {
    return GlobalKey<T>(debugLabel: 'widget_key_${_counter++}');
  }
  
  /// Generate a unique GlobalKey
  static GlobalKey uniqueKey() {
    return GlobalKey(debugLabel: 'unique_key_${_counter++}');
  }
}
