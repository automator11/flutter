import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:trackeano_web_app/admin/features/devices/data/data_sources/devices_admin_remote_data_source.dart';
import 'package:trackeano_web_app/admin/features/devices/data/repositories/devices_admin_repository.dart';

import 'admin/features/customers/data/data_sources/customer_remote_data_source.dart';
import 'admin/features/customers/data/repositories/customer_repository.dart';
import 'admin/features/customers/presentation/cubits/customers_cubit/customers_cubit.dart';
import 'admin/features/customers/presentation/cubits/customers_list_cubit/customers_list_cubit.dart';
import 'admin/features/devices/presentation/cubits/devices_list_cubit/devices_list_cubit.dart';
import 'admin/features/users/data/data_sources/users_remote_data_source.dart';
import 'admin/features/users/data/repositories/users_repository.dart';
import 'admin/features/users/presentation/cubits/users_cubit/users_cubit.dart';
import 'admin/features/users/presentation/cubits/users_list_cubit/users_list_cubit.dart';
import 'core/resources/constants.dart';
import 'core/utils/http_client_helper.dart';
import 'core/utils/local_storage_helper.dart';
import 'features/alerts/data/data_sources/alerts_remote_data_source.dart';
import 'features/alerts/data/repositories/repositories.dart';
import 'features/alerts/presentation/cubits/alerts_cubit.dart';
import 'features/entities/data/data_sources/entities_remote_data_source.dart';
import 'features/entities/data/repositories/entities_repository.dart';
import 'features/entities/presentation/assets/cubits/cubits.dart';
import 'features/entities/presentation/devices/cubits/cubits.dart';
import 'features/main_screen/presentation/cubit/cubits.dart';
import 'features/map/presentation/cubits/map_filter_cubit/map_filter_cubit.dart';
import 'features/settings/presentation/cubits/settings_cubit/settings_cubit.dart';
import 'features/user/data/data_sources/user_remote_data_source.dart';
import 'features/user/data/repositories/repositories.dart';
import 'features/user/presentation/cubit/cubits.dart';
import 'firebase_options.dart';

final injector = GetIt.instance;

Future<void> initializeDependencies() async {
  // firebase instance
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  injector.registerSingleton(messaging);

  // create LocalStorageHelper instance
  injector.registerSingleton<LocalStorageHelper>(
      LocalStorageHelper(const FlutterSecureStorage()));

  // add public paths, doesn't includes jwt token in request header
  List<String> publicPaths = [kObtainTokenService];

  // create http client instance
  HttpClientHelper httpClientHelper = HttpClientHelper(kBaseUrl, publicPaths);

  // Data sources
  injector.registerSingleton<UserRemoteDataSource>(
      UserRemoteDataSource(httpClientHelper));
  injector.registerSingleton<EntitiesRemoteDataSource>(
      EntitiesRemoteDataSource(httpClientHelper));
  injector.registerSingleton<AlertsRemoteDataSource>(
      AlertsRemoteDataSource(httpClientHelper));
  injector.registerSingleton<CustomerRemoteDataSource>(
      CustomerRemoteDataSource(httpClientHelper));
  injector.registerSingleton<AdminUsersRemoteDataSource>(
      AdminUsersRemoteDataSource(httpClientHelper));
  injector.registerSingleton<DevicesAdminRemoteDataSource>(
      DevicesAdminRemoteDataSource(httpClientHelper));

  // Repositories
  injector.registerSingleton<UserRepository>(UserRepository(injector()));
  injector
      .registerSingleton<EntitiesRepository>(EntitiesRepository(injector()));
  injector.registerSingleton<AlertsRepository>(AlertsRepository(injector()));
  injector
      .registerSingleton<CustomerRepository>(CustomerRepository(injector()));
  injector
      .registerSingleton<UsersRepository>(UsersRepository(injector()));
  injector
      .registerSingleton<DevicesAdminRepository>(DevicesAdminRepository(injector()));

  //  Blocs
  injector.registerSingleton<AppStateCubit>(AppStateCubit());
  injector.registerSingleton<AuthCubit>(AuthCubit(injector(), injector()));
  injector.registerFactory(() => LoginCubit(injector(), injector()));
  injector.registerFactory(() => ResetPasswordCubit());
  injector.registerFactory(() => ChangePasswordCubit(injector()));
  injector.registerFactory(() => MapFilterCubit(injector()));
  injector.registerFactory(() => EstablishmentsCubit(injector()));
  injector.registerFactory(() => SearchCubit(injector()));
  injector.registerFactory(() => ListAssetsCubit(injector()));
  injector.registerFactory(() => AssetsCubit(injector()));
  injector.registerFactory(() => DropdownCubit(injector(), injector()));
  injector.registerFactory(() => DevicesCubit(injector()));
  injector.registerFactory(() => DeviceTypesCubit(injector()));
  injector.registerFactory(() => DeviceTelemetryCubit(injector()));
  injector.registerFactory(() => DeviceLastTelemetryCubit(injector()));
  injector.registerFactory(() => AlertsCubit(injector()));
  injector.registerFactory(() => SettingsCubit(injector(), injector()));
  injector.registerFactory(() => CustomersListCubit(injector()));
  injector.registerFactory(() => CustomersCubit(injector()));
  injector.registerFactory(() => UsersCubit(injector()));
  injector.registerFactory(() => UsersListCubit(injector()));
  injector.registerFactory(() => DevicesListCubit(injector()));
}
