import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/appwrite_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/appwrite_inventory_service.dart';
import '../../data/services/appwrite_sales_service.dart';
import '../../data/services/appwrite_damaged_product_service.dart';
import '../../data/services/appwrite_expense_service.dart';
import '../../presentation/features/auth/repositories/appwrite_auth_repository.dart';
import '../../presentation/features/inventory/repositories/inventory_repository.dart';
import '../../presentation/features/home/repositories/analytics_repository.dart';
import '../../presentation/features/sales/repositories/sales_repository.dart';
import '../../presentation/features/notifications/repositories/notification_repository.dart';
import '../../presentation/features/installments/repositories/installment_repository.dart';
import '../../presentation/features/clients/repositories/client_repository.dart';
import '../../presentation/features/clients/repositories/client_repository_impl.dart';
import '../../data/services/expenses_service.dart';
import '../../presentation/features/expenses/providers/expenses_provider.dart';
import '../../presentation/features/damaged/providers/damaged_products_provider.dart';
import '../../presentation/features/returns/providers/returns_provider.dart';
import '../../presentation/features/home/providers/recent_activity_provider.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External services
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Core services
  locator.registerSingleton<AppwriteService>(AppwriteService());
  locator.registerSingleton<LocalStorageService>(
    LocalStorageServiceImpl(locator<SharedPreferences>())
  );
  
  // Appwrite Services
  locator.registerLazySingleton<AppwriteInventoryService>(
    () => AppwriteInventoryService()
  );
  
  locator.registerLazySingleton<AppwriteSalesService>(
    () => AppwriteSalesService()
  );
  
  locator.registerLazySingleton<AppwriteDamagedProductService>(
    () => AppwriteDamagedProductService()
  );
  
  locator.registerLazySingleton<AppwriteExpenseService>(
    () => AppwriteExpenseService()
  );
  
  // Legacy Data Services
  locator.registerLazySingleton<ExpensesService>(
    () => ExpensesService()
  );
  
  // Auth Repository
  locator.registerLazySingleton<AppwriteAuthRepository>(
    () => AppwriteAuthRepository(locator<AppwriteService>())
  );
  
  // Repositories using Appwrite
  locator.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl()
  );

  locator.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl()
  );
  
  locator.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl()
  );
  
  locator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl()
  );

  locator.registerLazySingleton<InstallmentRepository>(
    () => InstallmentRepositoryImpl()
  );

  locator.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl()
  );

  // Providers
  locator.registerLazySingleton<ExpensesProvider>(
    () => ExpensesProvider(locator<ExpensesService>())
  );
  
  locator.registerLazySingleton<DamagedProductsProvider>(
    () => DamagedProductsProvider()
  );
  
  locator.registerLazySingleton<ReturnsProvider>(
    () => ReturnsProvider()
  );
  
  locator.registerLazySingleton<RecentActivityProvider>(
    () => RecentActivityProvider(locator<AnalyticsRepository>())
  );
}
