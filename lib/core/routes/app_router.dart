import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/features/suppliers/screens/supplier_detail_screen.dart';
import '../providers/auth_provider.dart';
import '../../presentation/features/auth/screens/login_screen.dart';
import '../../presentation/features/auth/screens/signup_screen.dart';
import '../../presentation/features/barcode/screens/barcode_history_screen.dart';
import '../../presentation/features/barcode/screens/barcode_scanner_screen.dart';
import '../../presentation/features/business/screens/business_analytics_screen.dart';
import '../../presentation/features/business/screens/business_hub_screen.dart';
import '../../presentation/features/business/screens/storage_management_screen.dart';
import '../../presentation/features/clients/screens/customers_screen.dart';
import '../../presentation/features/clients/screens/add_customer_screen.dart';
import '../../presentation/features/clients/screens/customer_detail_screen.dart';
import '../../presentation/features/clients/models/customer_model.dart';
import '../../presentation/features/damaged/screens/damaged_products_screen.dart';
import '../../presentation/features/deleted/screens/deleted_items_screen.dart';
import '../../presentation/features/expenses/screens/expenses_screen.dart';
import '../../presentation/features/installments/screens/installments_screen.dart';
import '../../presentation/features/installments/screens/add_installment_screen.dart';
import '../../presentation/features/returns/screens/returns_screen.dart';
import '../../presentation/features/home/screens/home_screen.dart';
import '../../presentation/features/home/screens/activity_screen.dart';
import '../../presentation/features/search/screens/search_screen.dart';
import '../../presentation/features/inventory/models/product_model.dart';
import '../../presentation/features/inventory/screens/add_product_screen.dart';
import '../../presentation/features/inventory/screens/inventory_screen.dart';
import '../../presentation/features/inventory/screens/product_details_screen.dart';
import '../../presentation/features/notifications/screens/notifications_screen.dart';
import '../../presentation/features/profile/screens/edit_profile_screen.dart';
import '../../presentation/features/profile/screens/profile_screen.dart';
import '../../presentation/features/profile/screens/change_password_screen.dart';
import '../../presentation/features/profile/screens/language_screen.dart';
import '../../presentation/features/profile/screens/help_screen.dart';
import '../../presentation/features/profile/screens/privacy_screen.dart';
import '../../presentation/features/profile/screens/terms_screen.dart';
import '../../presentation/features/settings/screens/settings_screen.dart';
import '../../presentation/features/sales/screens/add_sale_screen.dart';
import '../../presentation/features/sales/screens/sale_detail_screen.dart';
import '../../presentation/features/sales/screens/sales_screen.dart';
import '../../presentation/features/splash/screens/splash_screen.dart';
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
        path: '/activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      
      GoRoute(
        path: '/search',
        builder: (context, state) {
          debugPrint('✅ Navigating to SearchScreen');
          return const SearchScreen();
        },
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
          return ProductDetailsScreen(productId: productId);
        },
      ),
      
      GoRoute(
        path: '/inventory/product/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailsScreen(productId: productId);
        },
      ),
      
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesScreen(),
      ),
      
      GoRoute(
        path: '/sales/new',
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
      
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) {
          debugPrint('✅ Navigating to ChangePasswordScreen');
          return const ChangePasswordScreen();
        },
      ),
      
      GoRoute(
        path: '/profile/language',
        builder: (context, state) {
          debugPrint('✅ Navigating to LanguageScreen');
          return const LanguageScreen();
        },
      ),
      
      GoRoute(
        path: '/profile/help',
        builder: (context, state) {
          debugPrint('✅ Navigating to HelpScreen');
          return const HelpScreen();
        },
      ),
      
      GoRoute(
        path: '/profile/privacy',
        builder: (context, state) {
          debugPrint('✅ Navigating to PrivacyScreen');
          return const PrivacyScreen();
        },
      ),
      
      GoRoute(
        path: '/profile/terms',
        builder: (context, state) {
          debugPrint('✅ Navigating to TermsScreen');
          return const TermsScreen();
        },
      ),
      
      // Business Management routes - MAKE SURE THESE ARE INCLUDED
      GoRoute(
        path: '/business/hub',
        builder: (context, state) {
          debugPrint('✅ Navigating to BusinessHubScreen');
          return const BusinessHubScreen();
        },
      ),
      
      GoRoute(
        path: '/business/analytics',
        builder: (context, state) {
          debugPrint('✅ Navigating to BusinessAnalyticsScreen');
          return const BusinessAnalyticsScreen();
        },
      ),
      
      GoRoute(
        path: '/business/storage',
        builder: (context, state) {
          debugPrint('✅ Navigating to StorageManagementScreen');
          return const StorageManagementScreen();
        },
      ),
      
      GoRoute(
        path: '/business/damaged',
        builder: (context, state) {
          debugPrint('✅ Navigating to DamagedProductsScreen');
          return const DamagedProductsScreen();
        },
      ),
      
      GoRoute(
        path: '/business/deleted',
        builder: (context, state) {
          debugPrint('✅ Navigating to DeletedItemsScreen');
          return const DeletedItemsScreen();
        },
      ),
      
      GoRoute(
        path: '/business/more',
        builder: (context, state) => const BusinessHubScreen(), // Default to hub for now
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
      
      // Additional routes for floating action button navigation
      GoRoute(
        path: '/customers',
        builder: (context, state) {
          debugPrint('✅ Navigating to CustomersScreen');
          return const CustomersScreen();
        },
      ),
      
      // Add customer route
      GoRoute(
        path: '/customers/add',
        builder: (context, state) {
          debugPrint('✅ Navigating to AddCustomerScreen');
          return const AddCustomerScreen();
        },
      ),
      
      // Customer detail route
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          debugPrint('✅ Navigating to CustomerDetailScreen with ID: $customerId');
          return CustomerDetailScreen(customerId: customerId);
        },
      ),
      
      // Edit customer route - redirect to add customer with edit mode
      GoRoute(
        path: '/customers/edit/:id',
        redirect: (context, state) {
          final customerId = state.pathParameters['id']!;
          return '/customers/$customerId';
        },
      ),
      
      GoRoute(
        path: '/installments',
        builder: (context, state) {
          debugPrint('✅ Navigating to InstallmentsScreen');
          return const InstallmentsScreen();
        },
      ),
      
      // Add the missing route for add installment screen
      GoRoute(
        path: '/installments/add',
        builder: (context, state) {
          debugPrint('✅ Navigating to AddInstallmentScreen');
          return const AddInstallmentScreen();
        },
      ),
      
      GoRoute(
        path: '/returns',
        builder: (context, state) {
          debugPrint('✅ Navigating to ReturnsScreen');
          return const ReturnsScreen();
        },
      ),
      
      GoRoute(
        path: '/expenses',
        builder: (context, state) {
          debugPrint('✅ Navigating to ExpensesScreen');
          return const ExpensesScreen();
        },
      ),
      
      GoRoute(
        path: '/damaged',
        builder: (context, state) {
          debugPrint('✅ Navigating to DamagedProductsScreen');
          return const DamagedProductsScreen();
        },
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
      
      // Allow search route without authentication check (for debugging)
      final isSearchRoute = state.matchedLocation == '/search';
                           
      // If on splash screen, let SplashScreen handle redirection
      if (state.matchedLocation == '/') {
        return null;
      }
      
      // Allow search route to pass through
      if (isSearchRoute) {
        return null;
      }
      
      if (!isLoggedIn && !isInAuthRoute) {
        debugPrint('🔒 Redirecting to login from: ${state.matchedLocation}');
        return '/login';
      }
      
      // If logged in and trying to access auth routes, redirect to home
      if (isLoggedIn && isInAuthRoute) {
        return '/home';
      }
      
      // No redirection needed
      return null;
    },
    
    // Enhanced error builder with more debugging info
    errorBuilder: (context, state) {
      debugPrint('❌ Router Error: ${state.error}');
      debugPrint('❌ Attempted path: ${state.matchedLocation}');
      debugPrint('❌ Full location: ${state.uri}');
      
      // Redirect to home instead of showing error page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
      
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
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