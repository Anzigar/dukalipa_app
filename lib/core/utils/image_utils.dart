import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Utility class for handling image loading with proper error handling throughout the app
class ImageUtils {
  /// A list of verified working Unsplash images to use as fallbacks
  static const List<String> _fallbackImages = [
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e', // headphones
    'https://images.unsplash.com/photo-1546868871-7041f2a55e12', // smartwatch
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9', // phone
    'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f', // camera
    'https://images.unsplash.com/photo-1572635196237-14b3f281503f', // sunglasses
  ];

  /// Get a fallback image URL based on a unique identifier
  static String getFallbackImageUrl(String id) {
    final int hash = id.hashCode.abs();
    final int index = hash % _fallbackImages.length;
    return _fallbackImages[index];
  }

  /// Get a random fallback image URL
  static String getRandomFallbackImageUrl() {
    final int index = DateTime.now().millisecondsSinceEpoch.abs() % _fallbackImages.length;
    return _fallbackImages[index];
  }

  /// Load an image with proper error handling and fallbacks
  static Widget loadImage({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
    String fallbackId = 'default',
  }) {
    // If no valid URL, use placeholder immediately
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderOrErrorWidget(errorWidget, width, height, borderRadius);
    }

    // Create widget to load with error handling
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(width, height),
      errorWidget: (context, url, error) {
        // If the primary image fails, try a fallback image
        return CachedNetworkImage(
          imageUrl: getFallbackImageUrl(fallbackId),
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(width, height),
          errorWidget: (context, url, error) => 
              _buildPlaceholderOrErrorWidget(errorWidget, width, height, borderRadius),
        );
      },
    );

    // Apply border radius if specified
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Build a standard loading placeholder
  static Widget _buildLoadingPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Color(0xFFFF5A60),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  /// Build either a custom error widget or a default placeholder
  static Widget _buildPlaceholderOrErrorWidget(
      Widget? errorWidget, double? width, double? height, BorderRadius? borderRadius) {
    final defaultErrorWidget = Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );

    Widget result = errorWidget ?? defaultErrorWidget;

    // Apply border radius if specified and using default widget
    if (borderRadius != null && errorWidget == null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: result,
      );
    }

    return result;
  }
}
