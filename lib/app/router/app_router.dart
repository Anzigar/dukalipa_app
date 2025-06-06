import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/shop_types.dart';
import 'package:lumina/presentation/features/inventory/screens/inventory_screen_updated.dart';

// Import all required screens
import '../../presentation/features/splash/screens/splash_screen.dart';
import '../../presentation/features/auth/screens/login_screen.dart';
import '../../presentation/features/auth/screens/signup_screen.dart';
import '../../presentation/features/home/screens/home_screen.dart';
import '../../presentation/features/sales/screens/sales_screen.dart';
import '../../presentation/features/sales/screens/add_sale_screen.dart';
import '../../presentation/features/sales/screens/sale_detail_screen.dart';
import '../../presentation/features/inventory/screens/add_product_screen.dart';
import '../../presentation/features/inventory/screens/product_detail_screen.dart';
import '../../presentation/features/expenses/screens/expenses_screen.dart';
import '../../presentation/features/expenses/screens/add_expense_screen.dart';
import '../../presentation/features/expenses/screens/expense_details_screen.dart';
import '../../presentation/features/installments/screens/installments_screen.dart';
import '../../presentation/features/installments/screens/add_installment_screen.dart';
import '../../presentation/features/profile/screens/profile_screen.dart';
import '../../presentation/features/notifications/screens/notifications_screen.dart';
import '../../presentation/features/settings/screens/settings_screen.dart';
import '../../presentation/features/clients/screens/customers_screen.dart';
import '../../presentation/features/clients/screens/customer_detail_screen.dart';
import '../../presentation/features/clients/screens/add_customer_screen.dart';

// A simpler, alternative export of the router configuration
// This redirects to core/routes/app_router.dart for the actual implementation
export '../../core/routes/app_router.dart';

// Alternatively, you can define your own router here
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
    
    // Home route
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    
    // Sales routes
    GoRoute(
      path: '/sales',
      builder: (context, state) => const SalesScreen(),
    ),
    GoRoute(
      path: '/sales/add',
      builder: (context, state) {
        final extraData = state.extra as Map<String, dynamic>?;
        final preSelectedProduct = extraData != null ? extraData['product'] : null;
        return AddSaleScreen(
          preSelectedProduct: preSelectedProduct,
          extraData: extraData,
        );
      },
    ),
    GoRoute(
      path: '/sales/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return SaleDetailScreen(saleId: id);
      },
    ),
    
    // Inventory routes
    GoRoute(
      path: '/inventory',
      pageBuilder: (context, state) {
        final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
        final String shopType = extra != null && extra.containsKey('shopType') 
            ? extra['shopType'] as String 
            : ShopTypes.general;
            
        return CustomTransitionPage(
          key: state.pageKey,
          child: InventoryScreen(shopType: shopType),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/inventory/add',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const AddProductScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/inventory/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      },
    ),
    
    // Expenses routes
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpensesScreen(),
    ),
    GoRoute(
      path: '/expenses/add',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/expenses/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ExpenseDetailsScreen(expenseId: id);
      },
    ),
    
    // Installment routes
    GoRoute(
      path: '/installments',
      builder: (context, state) => const InstallmentsScreen(),
    ),
    GoRoute(
      path: '/installments/add',
      builder: (context, state) => const AddInstallmentScreen(),
    ),
    // GoRoute(
    //   path: '/installments/:id',
    //   builder: (context, state) {
    //     final id = state.pathParameters['id']!;
    //     return InstallmentDetailScreen(installmentId: id);
    //   },
    // ),
    
    // Profile route
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    
    // Notifications route
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    
    // Settings route
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    
    // Client/Customer routes
    GoRoute(
      path: '/clients',
      builder: (context, state) => const CustomersScreen(),
    ),
    GoRoute(
      path: '/clients/add',
      builder: (context, state) => const AddCustomerScreen(),
    ),
    GoRoute(
      path: '/clients/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomerDetailScreen(customerId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Page not found',
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
