import 'package:flutter/foundation.dart';
import '../../data/services/appwrite_inventory_service.dart';

/// Simple utility to test Appwrite connection
class AppwriteConnectionTest {
  static Future<bool> testConnection() async {
    try {
      final service = AppwriteInventoryService();
      
      // Try to fetch products to test the connection
      await service.getProducts(pageSize: 1);
      
      if (kDebugMode) {
        print('✅ Appwrite connection successful');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Appwrite connection failed: $e');
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>> getConnectionInfo() async {
    try {
      final service = AppwriteInventoryService();
      
      // Get basic inventory summary to test connection
      final summary = await service.getInventorySummary();
      
      return {
        'status': 'connected',
        'database': 'shop_management_db',
        'summary': summary,
      };
    } catch (e) {
      return {
        'status': 'failed',
        'error': e.toString(),
      };
    }
  }
}