import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';
import '../network/dio_interceptors.dart';
import '../network/api_client.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/inventory_service.dart';
import '../../presentation/features/auth/repositories/auth_repository.dart';
import '../../presentation/features/inventory/repositories/inventory_repository.dart';
import '../../presentation/features/home/repositories/analytics_repository.dart';
import '../../presentation/features/sales/repositories/sales_repository.dart';
import '../../presentation/features/notifications/repositories/notification_repository.dart';
import '../../presentation/features/installments/repositories/installment_repository.dart';
import '../../presentation/features/installments/repositories/installment_repository_impl.dart' as installment_impl;
import '../../presentation/features/clients/repositories/client_repository.dart';
import '../../presentation/features/clients/repositories/client_repository_impl.dart';
import '../../data/services/product_service.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/sales_service.dart';
import '../../data/services/returns_service.dart';
import '../../data/services/deleted_sales_service.dart';
import '../../data/services/damaged_products_service.dart';
import '../../data/services/expenses_service.dart';
import '../../presentation/features/damaged/providers/damaged_products_provider.dart';
import '../../presentation/features/returns/providers/returns_provider.dart';
import '../../presentation/features/expenses/providers/expenses_provider.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External services
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Core services
  locator.registerSingleton<LocalStorageService>(
    LocalStorageServiceImpl(locator<SharedPreferences>())
  );
  
  // Network
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  // Add interceptors
  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(AuthInterceptor(locator<LocalStorageService>()));
  
  // Register Dio instance
  locator.registerSingleton<Dio>(dio);
  
  // Register ApiClient with proper Dio instance
  locator.registerLazySingleton<ApiClient>(() => ApiClient(
    baseUrl: AppConstants.baseUrl,
  ));
  
  // Data Services
  locator.registerLazySingleton<InventoryService>(
    () => InventoryService()
  );
  
  locator.registerLazySingleton<ProductService>(
    () => ProductService()
  );
  
  locator.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService()
  );
  
  locator.registerLazySingleton<SalesService>(
    () => SalesService()
  );
  
  locator.registerLazySingleton<ReturnsService>(
    () => ReturnsService()
  );
  
  locator.registerLazySingleton<DeletedSalesService>(
    () => DeletedSalesService()
  );
  
  locator.registerLazySingleton<DamagedProductsService>(
    () => DamagedProductsService()
  );
  
  locator.registerLazySingleton<ExpensesService>(
    () => ExpensesService()
  );
  
  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<LocalStorageService>())
  );
  
  // Use the new inventory repository implementation
  locator.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl()
  );

  // Register analytics repository
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
    () => installment_impl.InstallmentRepositoryImpl()
  );

  locator.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl()
  );

  // Providers
  locator.registerLazySingleton<DamagedProductsProvider>(
    () => DamagedProductsProvider(locator<DamagedProductsService>())
  );

  locator.registerLazySingleton<ReturnsProvider>(
    () => ReturnsProvider(locator<ReturnsService>())
  );

  locator.registerLazySingleton<ExpensesProvider>(
    () => ExpensesProvider(locator<ExpensesService>())
  );
}
