import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';
import '../network/dio_interceptors.dart';
import '../network/api_client.dart';
import '../../data/services/local_storage_service.dart';
import '../../presentation/features/auth/repositories/auth_repository.dart';
import '../../presentation/features/inventory/repositories/inventory_repository.dart';
import '../../presentation/features/sales/repositories/sales_repository.dart';
import '../../presentation/features/expenses/repositories/expenses_repository.dart';
import '../../presentation/features/notifications/repositories/notification_repository.dart';
import '../../presentation/features/installments/repositories/installment_repository.dart';
import '../../presentation/features/installments/repositories/installment_repository_impl.dart' as installment_impl;
import '../../presentation/features/clients/repositories/client_repository.dart';

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
  
  // Register ApiClient without dio parameter to match our mock implementation
  locator.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<ApiClient>(), locator<LocalStorageService>())
  );
  
  locator.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(locator<ApiClient>())
  );
  
  locator.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(locator<ApiClient>())
  );
  
  locator.registerLazySingleton<ExpensesRepository>(
    () => ExpensesRepositoryImpl(locator<ApiClient>())
  );
  
  locator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(locator<ApiClient>())
  );

  locator.registerLazySingleton<InstallmentRepository>(
    () => installment_impl.InstallmentRepositoryImpl(locator<ApiClient>())
  );

  locator.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(locator<ApiClient>())
  );
}
