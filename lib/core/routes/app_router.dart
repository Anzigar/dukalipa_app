import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/presentation/features/inventory/models/product_model.dart';
import 'package:provider/provider.dart';
import '../../presentation/features/inventory/screens/product_details_screen.dart';
import '../providers/auth_provider.dart';
import '../../presentation/features/splash/screens/splash_screen.dart';
import '../../presentation/features/auth/screens/login_screen.dart';
import '../../presentation/features/auth/screens/signup_screen.dart';
import '../../presentation/features/home/screens/home_screen.dart';
import '../../presentation/features/sales/screens/sales_screen.dart';
import '../../presentation/features/sales/screens/add_sale_screen.dart';
import '../../presentation/features/sales/screens/sale_detail_screen.dart';
import '../../presentation/features/inventory/screens/inventory_screen_updated.dart';
import '../../presentation/features/inventory/screens/add_product_screen.dart';
import '../../presentation/features/profile/screens/profile_screen.dart';
import '../../presentation/features/suppliers/screens/supplier_detail_screen.dart';
import '../../presentation/features/settings/screens/settings_screen.dart';
import '../../presentation/features/notifications/screens/notifications_screen.dart';
import '../../presentation/features/barcode/screens/barcode_scanner_screen.dart';
import '../../presentation/features/barcode/screens/barcode_history_screen.dart';

// Define a router class to consolidate app routing logic
class AppRouter {
  static GoRouter get router => _router;
  
  // Private router definition
  static final _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      // Splash screen is the initial route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      
      GoRoute(
        path: '/inventory/add',
        builder: (context, state) => const AddProductScreen(),
      ),
      
      GoRoute(
        path: '/inventory/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          // Use the correct class name if ProductDetailScreen is not defined.
          return ProductDetailsScreen(productId: productId); // <-- update to actual class name
        },
      ),
      
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesScreen(),
      ),
      
      GoRoute(
        path: '/sales/add',
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>?;
          ProductModel? preSelectedProduct;
          Map<String, dynamic>? customerData;
          
          if (extraData != null) {
            if (extraData.containsKey('product')) {
              preSelectedProduct = extraData['product'] as ProductModel?;
            }
            if (extraData.containsKey('customer')) {
              customerData = {'customer': extraData['customer']};
            }
          }
          
          return AddSaleScreen(
            preSelectedProduct: preSelectedProduct,
            extraData: customerData ?? extraData,
          );
        },
      ),
      
      GoRoute(
        path: '/sales/:id',
        builder: (context, state) {
          final saleId = state.pathParameters['id']!;
          return SaleDetailScreen(saleId: saleId);
        },
      ),
      
      // Uncomment if needed and implement the screen
      // GoRoute(
      //   path: '/customers/:id/purchases',
      //   builder: (context, state) {
      //     final id = state.pathParameters['id']!;
      //     return CustomerPurchasesScreen(customerId: id);
      //   },
      // ),
      
      // Suppliers routes
      GoRoute(
        path: '/suppliers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SupplierDetailScreen(supplierId: id);
        },
      ),
      
      // Profile routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Settings
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      // Add these routes to your GoRouter configuration
      GoRoute(
        path: '/barcode-scanner',
        builder: (context, state) => const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: '/barcode/history',
        builder: (context, state) => const BarcodeHistoryScreen(),
      ),
    ],
    
    // Redirect logic for auth state
    redirect: (BuildContext context, GoRouterState state) {
      // Check if user is logged in
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bool isLoggedIn = authProvider.isLoggedIn;
      
      // If not logged in, redirect to login except for login/signup pages
      final isInAuthRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/signup';
                           
      // If on splash screen, let SplashScreen handle redirection
      if (state.matchedLocation == '/') {
        return null;
      }
      
      if (!isLoggedIn && !isInAuthRoute) {
        return '/login';
      }
      
      // If logged in and trying to access auth routes, redirect to home
      if (isLoggedIn && isInAuthRoute) {
        return '/home';
      }
      
      // No redirection needed
      return null;
    },
    
    // Error page for routes that don't exist
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oops! The page you are looking for does not exist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => GoRouter.of(context).go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
  
    
    
    // DEVELOPMENT MODE: Bypass authentication
    // If trying to access the root, redirect straight to home
  
    
    // PRODUCTION MODE (uncomment when ready to connect backend):
    /*
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isLoggedIn = authProvider.isLoggedIn;
    
    // Splash screen is accessible to all
    final isSplash = state.matchedLocation == '/';
    
    // These routes don't require authentication
    final noAuthRequired = isSplash || 
                         state.matchedLocation == '/login' || 
                         state.matchedLocation == '/signup';
    
    // If user is not logged in and trying to access protected route, redirect to login
    if (!isLoggedIn && !noAuthRequired) {
      return '/login';
    }
    
    // If user is logged in and trying to access auth routes, redirect to home
    if (isLoggedIn && noAuthRequired) {
      return '/home';
    }
    
    // No redirection needed
    return null;
    */
