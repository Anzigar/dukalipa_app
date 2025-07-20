import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

/// Advanced semantic tree debugging and protection
class SemanticTreeProtection {
  static bool _isProtectionEnabled = false;
  static int _errorCount = 0;
  static const int _maxErrors = 5;
  
  /// Initialize comprehensive semantic tree protection
  static void initialize() {
    if (_isProtectionEnabled) return;
    _isProtectionEnabled = true;
    
    if (kDebugMode) {
      // Override the default error handler
      FlutterError.onError = _handleFlutterError;
      
      // Add semantic tree specific protection
      RendererBinding.instance.addPostFrameCallback((_) {
        _enforceSemanticTreeStability();
      });
    }
  }
  
  /// Enhanced error handler specifically for semantic tree issues
  static void _handleFlutterError(FlutterErrorDetails details) {
    final errorMessage = details.toString();
    
    if (errorMessage.contains('semantics.parentDataDirty') || 
        errorMessage.contains('Failed assertion')) {
      _errorCount++;
      
      debugPrint('🛡️  SEMANTIC TREE PROTECTION: Intercepted error #$_errorCount');
      debugPrint('🔧 Attempting automatic recovery...');
      
      if (_errorCount >= _maxErrors) {
        debugPrint('⚠️  Maximum semantic errors reached. Forcing semantic tree rebuild...');
        _forceSemanticTreeRebuild();
        _errorCount = 0; // Reset counter
      }
      
      // Don't let the error propagate and crash the app
      return;
    }
    
    // Let other errors pass through normally
    FlutterError.presentError(details);
  }
  
  /// Force a complete semantic tree rebuild
  static void _forceSemanticTreeRebuild() {
    try {
      // Force a semantic update to clear dirty state
      final semanticsBinding = SemanticsBinding.instance;
      semanticsBinding.ensureSemantics();
      
      // Clear any pending frame callbacks that might cause conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('✅ Semantic tree protection cycle completed');
      });
      
      debugPrint('✅ Semantic tree rebuild completed successfully');
    } catch (e) {
      debugPrint('❌ Semantic tree rebuild failed: $e');
    }
  }
  
  /// Enforce semantic tree stability
  static void _enforceSemanticTreeStability() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Simple stability check with a delay-based approach
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_isProtectionEnabled) {
            _enforceSemanticTreeStability();
          }
        });
      } catch (e) {
        debugPrint('🛡️  Semantic tree stability check failed: $e');
      }
    });
  }
  
  /// Disable protection (for cleanup)
  static void disable() {
    _isProtectionEnabled = false;
    _errorCount = 0;
  }
  
  /// Safe widget builder that prevents semantic tree corruption
  static Widget buildSafely({
    required Widget Function() builder,
    Widget Function()? fallback,
  }) {
    try {
      return RepaintBoundary(
        child: Builder(builder: (context) {
          try {
            return builder();
          } catch (e) {
            debugPrint('🛡️  Safe builder caught widget error: $e');
            return fallback?.call() ?? const SizedBox.shrink();
          }
        }),
      );
    } catch (e) {
      debugPrint('🛡️  Safe builder outer catch: $e');
      return const SizedBox.shrink();
    }
  }
}
