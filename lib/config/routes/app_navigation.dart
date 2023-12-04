import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:trackeano_web_app/admin/features/customers/presentation/cubits/customers_list_cubit/customers_list_cubit.dart';
import 'package:trackeano_web_app/admin/features/customers/presentation/pages/customer_users_table_page.dart';
import 'package:trackeano_web_app/admin/features/customers/presentation/pages/customers_table_page.dart';
import 'package:trackeano_web_app/admin/features/devices/presentation/cubits/devices_list_cubit/devices_list_cubit.dart';

import '../../admin/features/customers/presentation/cubits/customers_cubit/customers_cubit.dart';
import '../../admin/features/devices/presentation/pages/devices_admin_table_page.dart';
import '../../admin/features/main/pages/pages.dart';
import '../../admin/features/users/presentation/cubits/users_cubit/users_cubit.dart';
import '../../admin/features/users/presentation/cubits/users_list_cubit/users_list_cubit.dart';
import '../../admin/features/users/presentation/pages/pages.dart';
import '../../core/resources/constants.dart';
import '../../core/resources/enums.dart';
import '../../core/utils/local_storage_helper.dart';
import '../../features/alerts/presentation/pages/pages.dart';
import '../../features/entities/data/models/models.dart';
import '../../features/entities/presentation/assets/cubits/cubits.dart';
import '../../features/entities/presentation/assets/pages/pages.dart';
import '../../features/entities/presentation/devices/cubits/cubits.dart';
import '../../features/entities/presentation/devices/pages/pages.dart';
import '../../features/main_screen/presentation/cubit/cubits.dart';
import '../../features/main_screen/presentation/pages/pages.dart';
import '../../features/map/presentation/cubits/map_filter_cubit/map_filter_cubit.dart';
import '../../features/map/presentation/pages/map_view_page.dart';
import '../../features/map/presentation/widgets/widgets.dart';
import '../../features/user/presentation/cubit/cubits.dart';
import '../../features/user/presentation/pages/pages.dart';
import '../../injector.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _mainShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'mainShell');
final GlobalKey<NavigatorState> _secondaryShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'secondaryShell');
final GlobalKey<NavigatorState> _adminShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'adminShell');

GoRouter createRouter() => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      observers: [
        SentryNavigatorObserver(),
      ],
      redirect: (context, GoRouterState state) async {
        log(state.uri.toString());
        LocalStorageHelper storage = injector<LocalStorageHelper>();
        String token = await storage.readString(kAccessTokenKey) ?? '';
        if (token.isEmpty &&
            state.uri.toString() != '/login' &&
            state.uri.toString() != 'login' &&
            state.uri.toString() != 'forgotPassword' &&
            state.uri.toString() != '/forgotPassword') {
          return '/login';
        }
        final user = context.read<AppStateCubit>().userProfile;
        if (state.uri.toString().contains('/admin/') &&
            user?.authority != kTenantAdminRole) {
          return '/forbidden';
        }
        return null;
      },
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: kHomePageRoute,
          path: '/',
          // redirect: (context, GoRouterState state) async {
          //   if (state.uri.toString().contains('/confirm/')) {
          //     List<String> path = state.uri.toString().split('/');
          //     return '/createPassword?token=${path.last}';
          //   }
          //   return null;
          // },
          builder: (context, state) {
            return const HomePage();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: kLoginPageRoute,
          path: '/login',
          builder: (context, _) => BlocProvider(
            create: (context) => injector<LoginCubit>(),
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: kForgotPasswordPageRoute,
          path: '/forgotPassword',
          builder: (context, _) => BlocProvider(
            create: (context) => injector<ResetPasswordCubit>(),
            child: const ForgotPasswordPage(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: kScanQrCodePageRoute,
          path: '/scanQr',
          builder: (context, state) {
            return const ScanQrCodePage();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: kForbiddenPageRoute,
          path: '/forbidden',
          builder: (context, state) {
            return const ForbiddenPage();
          },
        ),
        // admin routes
        ShellRoute(
            parentNavigatorKey: _rootNavigatorKey,
            navigatorKey: _adminShellNavigatorKey,
            builder: (context, state, child) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => injector<DropdownCubit>(),
                    ),
                  ],
                  child: AdminMainScreen(
                    child: child,
                  ),
                ),
            routes: [
              GoRoute(
                parentNavigatorKey: _adminShellNavigatorKey,
                name: kDashboardPageRoute,
                path: '/admin/dashboard',
                builder: (context, state) {
                  return const DashboardPage();
                },
              ),
              GoRoute(
                parentNavigatorKey: _adminShellNavigatorKey,
                name: kAdminCustomersPageRoute,
                path: '/admin/customers',
                builder: (context, state) {
                  return MultiBlocProvider(providers: [
                    BlocProvider(
                        create: (context) => injector<CustomersListCubit>()),
                    BlocProvider(
                        create: (context) => injector<CustomersCubit>()),
                  ], child: const CustomersTablePage());
                },
              ),
              GoRoute(
                parentNavigatorKey: _adminShellNavigatorKey,
                name: kAdminUsersPageRoute,
                path: '/admin/users',
                builder: (context, state) {
                  return MultiBlocProvider(providers: [
                    BlocProvider(
                        create: (context) => injector<UsersListCubit>()),
                    BlocProvider(
                        create: (context) => injector<UsersCubit>()),
                  ], child: const UsersTablePage());
                },
              ),
              GoRoute(
                parentNavigatorKey: _adminShellNavigatorKey,
                name: kAdminCustomersUsersPageRoute,
                path: '/admin/customers/users',
                builder: (context, state) {
                  String customerId = state.uri.queryParameters['customerId'] ?? '';
                  return MultiBlocProvider(providers: [
                    BlocProvider(
                        create: (context) => injector<UsersListCubit>()),
                    BlocProvider(
                        create: (context) => injector<UsersCubit>()),
                  ], child: CustomerUsersTablePage(customerId: customerId,));
                },
              ),
              GoRoute(
                parentNavigatorKey: _adminShellNavigatorKey,
                name: kAdminDevicesPageRoute,
                path: '/admin/devices',
                builder: (context, state) {
                  return MultiBlocProvider(providers: [
                    BlocProvider(
                        create: (context) => injector<DevicesListCubit>()),
                    // BlocProvider(
                    //     create: (context) => injector<UsersCubit>()),
                  ], child: const DevicesAdminTablePage());
                },
              ),
            ]),
        ShellRoute(
            parentNavigatorKey: _rootNavigatorKey,
            navigatorKey: _mainShellNavigatorKey,
            builder: (context, state, child) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => injector<DropdownCubit>(),
                    ),
                    BlocProvider(
                      create: (context) => injector<EstablishmentsCubit>(),
                    ),
                  ],
                  child: MainScreen(
                    child: child,
                  ),
                ),
            routes: [
              ShellRoute(
                  parentNavigatorKey: _mainShellNavigatorKey,
                  navigatorKey: _secondaryShellNavigatorKey,
                  builder: (context, state, child) {
                    EntityModel? selectedEntity;
                    if (state.extra != null) {
                      selectedEntity = state.extra as EntityModel;
                    }
                    return MultiBlocProvider(
                        providers: [
                          BlocProvider<MapFilterCubit>(
                            create: (context) => injector<MapFilterCubit>(),
                          ),
                          BlocProvider<SearchCubit>(
                            create: (context) => injector<SearchCubit>(),
                          ),
                          BlocProvider<ListAssetsCubit>(
                            create: (context) => injector<ListAssetsCubit>(),
                          ),
                          BlocProvider<DevicesCubit>(
                            create: (context) => injector<DevicesCubit>(),
                          ),
                        ],
                        child: MapViewPage(
                          selectedEntity: selectedEntity,
                          child: child,
                        ));
                  },
                  routes: [
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kMapPageRoute,
                      path: '/map',
                      pageBuilder: (context, state) {
                        return CustomTransitionPage(
                          key: state.pageKey,
                          child: const SearchBarWidget(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: CurveTween(curve: Curves.easeInOutCirc)
                                  .animate(animation),
                              child: child,
                            );
                          },
                        );
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kMapAssetsPageRoute,
                      path: '/map/assets',
                      pageBuilder: (context, state) {
                        String assetType =
                            state.uri.queryParameters['type'] ?? '';
                        String title = assetType;
                        return CustomTransitionPage(
                          key: state.pageKey,
                          child: BlocProvider(
                            create: (context) => injector<ListAssetsCubit>(),
                            child: PointerInterceptor(
                              child: AssetsPage(
                                assetType: assetType,
                                title: title,
                              ),
                            ),
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: CurveTween(curve: Curves.easeInOutCirc)
                                  .animate(animation),
                              child: child,
                            );
                          },
                        );
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kMapEditAssetPageRoute,
                      path: '/map/assets/edit',
                      pageBuilder: (context, state) {
                        EntityModel? asset;
                        bool fromTable =
                            state.uri.queryParameters['fromTable'] == '1'
                                ? true
                                : false;
                        if (state.extra != null) {
                          asset = state.extra as EntityModel;
                        }
                        String? type =
                            asset?.type ?? state.uri.queryParameters['type'];
                        return CustomTransitionPage(
                          key: state.pageKey,
                          child: MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => injector<AssetsCubit>(),
                              ),
                              BlocProvider(
                                create: (context) => injector<DropdownCubit>(),
                              ),
                            ],
                            child: PointerInterceptor(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: EditAssetPage(
                                  asset: asset,
                                  type: type,
                                  fromTable: fromTable,
                                ),
                              ),
                            ),
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: CurveTween(curve: Curves.easeInOutCirc)
                                  .animate(animation),
                              child: child,
                            );
                          },
                        );
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kMapDevicesPageRoute,
                      path: '/map/devices',
                      pageBuilder: (context, state) {
                        String deviceType =
                            state.uri.queryParameters['type'] ?? '';
                        String title = deviceType;
                        return CustomTransitionPage(
                          key: state.pageKey,
                          child: BlocProvider(
                              create: (context) => injector<DevicesCubit>(),
                              child: PointerInterceptor(
                                child: DevicesPage(
                                  deviceType: deviceType,
                                  title: title,
                                ),
                              )),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: CurveTween(curve: Curves.easeInOutCirc)
                                  .animate(animation),
                              child: child,
                            );
                          },
                        );
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kMapDevicesDetailsPageRoute,
                      path: '/map/devices/details',
                      pageBuilder: (context, state) {
                        EntityModel device = state.extra as EntityModel;
                        return CustomTransitionPage(
                          key: state.pageKey,
                          child: MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => injector<DevicesCubit>(),
                              ),
                              BlocProvider(
                                create: (context) =>
                                    injector<DeviceLastTelemetryCubit>(),
                              ),
                              BlocProvider(
                                create: (context) =>
                                    injector<DeviceTelemetryCubit>(),
                              ),
                            ],
                            child: PointerInterceptor(
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: DeviceDetailsPage(device: device))),
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: CurveTween(curve: Curves.easeInOutCirc)
                                  .animate(animation),
                              child: child,
                            );
                          },
                        );
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kMapConfigureDevicesPageRoute,
                      path: '/map/devices/configure',
                      builder: (context, state) {
                        EntityModel device = state.extra as EntityModel;
                        Map<String, dynamic>? batchInfo =
                            state.uri.queryParameters;
                        bool fromTable =
                            state.uri.queryParameters['fromTable'] == '1'
                                ? true
                                : false;
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) => injector<DevicesCubit>(),
                            ),
                            BlocProvider(
                                create: (context) => injector<DropdownCubit>()),
                          ],
                          child: PointerInterceptor(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConfigureDevicePage(
                                  device: device,
                                  batchInfo: batchInfo,
                                  fromTable: fromTable),
                            ),
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kCreateTempHumAlertPageRoute,
                      path: '/createTempHumAlert',
                      builder: (context, state) {
                        AlertModel? alert = state.extra != null
                            ? state.extra as AlertModel
                            : null;
                        return PointerInterceptor(
                            child: Align(
                                alignment: Alignment.topCenter,
                                child: CreateTempHumAlertPage(alert: alert)));
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kClaimEarTagPageRoute,
                      path: '/claimEarTag',
                      builder: (context, state) {
                        EntitySearchModel? batchInfo =
                            state.extra as EntitySearchModel?;
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider(
                                create: (context) => injector<DevicesCubit>()),
                            BlocProvider(
                                create: (context) => injector<DropdownCubit>()),
                            BlocProvider(
                                create: (context) => injector<AssetsCubit>()),
                          ],
                          child: PointerInterceptor(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ClaimEarTagPage(
                                batchInfo: batchInfo,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kAlertsPageRoute,
                      path: '/alertsPage',
                      builder: (context, state) {
                        return PointerInterceptor(
                            child: const Align(
                                alignment: Alignment.topCenter,
                                child: AlertsPage()));
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _secondaryShellNavigatorKey,
                      name: kAddEarTagByBatchPageRoute,
                      path: '/addEarTagByBatch',
                      builder: (context, state) {
                        EntitySearchModel batch =
                            state.extra as EntitySearchModel;
                        return PointerInterceptor(
                            child: Align(
                          alignment: Alignment.topCenter,
                          child: MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (context) =>
                                      injector<DropdownCubit>()),
                              BlocProvider(
                                  create: (context) =>
                                      injector<DevicesCubit>()),
                            ],
                            child: AddEarTagByBatchPage(batch: batch),
                          ),
                        ));
                      },
                    ),
                  ]),
              GoRoute(
                parentNavigatorKey: _mainShellNavigatorKey,
                name: kSelectPositionMapPageRoute,
                path: '/selectPositionMap',
                builder: (context, state) {
                  LocationType locationType =
                      state.uri.queryParameters['locationType'] != null
                          ? LocationType.values.byName(
                              state.uri.queryParameters['locationType']!)
                          : LocationType.single;
                  String? assetType = state.uri.queryParameters['assetType'];
                  Map<String, dynamic> initialPosition = state.extra != null
                      ? state.extra as Map<String, dynamic>
                      : {};
                  return BlocProvider(
                    create: (context) => injector<MapFilterCubit>(),
                    child: MapSelectionPage(
                      locationType: locationType,
                      assetType: assetType,
                      initialPosition: initialPosition,
                    ),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _mainShellNavigatorKey,
                name: kTableAssetsPageRoute,
                path: '/table/assets',
                pageBuilder: (context, state) {
                  String type = state.uri.queryParameters['type'] ?? '';
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: BlocProvider(
                      create: (context) => injector<ListAssetsCubit>(),
                      child: AssetsTablePage(type: type),
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child,
                      );
                    },
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _mainShellNavigatorKey,
                name: kTableDevicesPageRoute,
                path: '/table/devices',
                pageBuilder: (context, state) {
                  String type = state.uri.queryParameters['type'] ?? '';
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: BlocProvider(
                      create: (context) => injector<DevicesCubit>(),
                      child: DevicesTablePage(type: type),
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child,
                      );
                    },
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _mainShellNavigatorKey,
                name: kEarTagRoutePageRoute,
                path: '/earTagRoute',
                builder: (context, state) {
                  EntityModel device = state.extra as EntityModel;
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) =>
                              injector<DeviceLastTelemetryCubit>()),
                      BlocProvider(
                        create: (context) => injector<DeviceTelemetryCubit>(),
                      ),
                    ],
                    child: EarTagRoutePage(device: device),
                  );
                },
              ),
            ]),
      ],
    );
