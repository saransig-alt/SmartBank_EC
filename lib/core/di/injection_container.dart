import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:get_it/get_it.dart';

import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/bank_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/bank_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_bank_repository.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/bank/get_balance_usecase.dart';
import '../../domain/usecases/bank/get_transactions_usecase.dart';
import '../../domain/usecases/bank/listen_user_data_usecase.dart';
import '../../domain/usecases/bank/transfer_money_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/bank_provider.dart';
import '../../presentation/providers/theme_provider.dart';

/// Servicio de localización para inyección de dependencias.
final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación.
/// Debe llamarse antes de runApp().
Future<void> initDependencies() async {
  // ------------------------------------------------------------------
  // Core Services
  // ------------------------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ------------------------------------------------------------------
  // Firebase
  // ------------------------------------------------------------------
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------------
  // Capa de Datos - Datasources
  // ------------------------------------------------------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      auth: firebaseAuth,
      firestore: firebaseFirestore,
    ),
  );

  sl.registerLazySingleton<BankRemoteDataSource>(
    () => BankRemoteDataSource(firestore: firebaseFirestore),
  );

  // ------------------------------------------------------------------
  // Capa de Datos - Repositorios (implementaciones concretas)
  // ------------------------------------------------------------------
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      authDataSource: sl(),
      bankDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<IBankRepository>(
    () => BankRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // ------------------------------------------------------------------
  // Capa de Dominio - Casos de Uso
  // ------------------------------------------------------------------
  sl.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(sl()),
  );
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(sl()),
  );
  sl.registerLazySingleton<GetBalanceUseCase>(
    () => GetBalanceUseCase(sl()),
  );
  sl.registerLazySingleton<GetTransactionsUseCase>(
    () => GetTransactionsUseCase(sl()),
  );
  sl.registerLazySingleton<TransferMoneyUseCase>(
    () => TransferMoneyUseCase(sl()),
  );
  sl.registerLazySingleton<ListenUserDataUseCase>(
    () => ListenUserDataUseCase(sl()),
  );

  // ------------------------------------------------------------------
  // Capa de Presentación - Providers
  // ------------------------------------------------------------------
  sl.registerLazySingleton<BankProvider>(
    () => BankProvider(),
  );

  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(),
  );

  sl.registerLazySingleton<ThemeProvider>(
    () => ThemeProvider(sl()),
  );
}
