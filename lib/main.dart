import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:trackeano_web_app/features/main_screen/presentation/pages/home_page.dart';

import 'config/routes/app_navigation.dart';
import 'config/routes/routes.dart';
import 'config/themes/app_themes.dart';
import 'core/resources/constants.dart';
import 'core/utils/local_storage_helper.dart';
import 'features/alerts/presentation/cubits/alerts_cubit.dart';
import 'features/entities/data/models/models.dart';
import 'features/main_screen/presentation/cubit/cubits.dart';
import 'features/settings/presentation/cubits/settings_cubit/settings_cubit.dart';
import 'firebase_options.dart';
import 'generated/codegen_loader.g.dart';
import 'injector.dart';

part 'local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  await initializeDependencies();

  // get messaging instance
  // _messaging = injector<FirebaseMessaging>();

  // await _messaging.getToken(
  //   vapidKey:
  //       "BNWNXctsnpWu3KeXevIu0Ex3TJ9BWft5WJTrerNAKxw6Erj5wPrXDSRYlMssQ236kFGlO0WzBYSuzs9rL8cdlrs",
  // );

  // try {
  //   await _messaging.subscribeToTopic('global');
  // } catch (e) {
  //   log('Fail to subscribe to global topic. ${e.toString()}');
  // }
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await setupFlutterNotifications();

  // await SentryFlutter.init((options) {
  //   options.dsn = kDebugMode
  //       ? ''
  //       : 'https://bb190289f8794c4992bcdb6b2d6a3412@o4505392304422912.ingest.sentry.io/4505392360521728';
  //   options.tracesSampleRate = 1.0;
  // },
  //     appRunner: () =>
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('es')],
    path: 'assets/translations',
    assetLoader: const CodegenLoader(),
    fallbackLocale: const Locale('en'),
    child: MultiBlocProvider(providers: [
      BlocProvider(create: (context) => injector<AuthCubit>()),
      BlocProvider(create: (context) => injector<AppStateCubit>()),
      BlocProvider(create: (context) => injector<AlertsCubit>()),
      BlocProvider(create: (context) => injector<SettingsCubit>())
    ], child: const MyApp()),
  )
      // )
      );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter _router;

  void _initAppState() async {
    final storage = injector<LocalStorageHelper>();
    final userId = await storage.readString(kActiveUserKey);
    if (userId != null && mounted) {
      // context.read<AppStateCubit>().restoreAppState(userId);
    }
  }

  @override
  void initState() {
    _router = createRouter();
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    context.read<AuthCubit>().authenticate();
    // _initAppState();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MultiBlocListener(
      listeners: [
        BlocListener<AppStateCubit, AppState>(listener: (context, state) {
          if (state is AppStateRestored) {
            String path = _router.routerDelegate.currentConfiguration.uri.path;
            if (path.isEmpty || path == '/' || path == '/login') {
              final user = context.read<AppStateCubit>().userProfile;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (user != null) {
                  _router.goNamed( user.authority == kTenantAdminRole ? kDashboardPageRoute : kMapPageRoute);
                } else {
                  _router.goNamed(kLoginPageRoute);
                }
              });
            }
          }
        }),
        BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsFail) {
              // MyDialogs.showErrorDialog(context,
              //     '${'failToActivateNotifications'.tr()}. ${state.message.tr()}');
              log('${'failToActivateNotifications'.tr()}. ${state.message.tr()}');
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              log('User authenticated. Restoring app state');
              context.read<AppStateCubit>().restoreAppState(state.user);
              // final prefs = await SharedPreferences.getInstance();
              // final userPrefsJson = prefs.getString(state.user!.id.id);
              // if (userPrefsJson != null) {
              //   final userPrefs = jsonDecode(userPrefsJson);
              //   bool enableNotifications =
              //       userPrefs[kEnableNotifications] ?? true;
              //   if (!enableNotifications && mounted) {
              //     context
              //         .read<SettingsCubit>()
              //         .unsubscribeNotifications(state.user!.customerId!.id);
              //   } else if (mounted) {
              //     context
              //         .read<SettingsCubit>()
              //         .subscribeNotifications(state.user!.customerId!.id);
              //   }
              // }
            }
            if (state is Unauthenticated && mounted) {
              log('User unauthenticated. Going to Login page');
              context.read<AppStateCubit>().restoreAppState(null);
            }
          },
        ),
      ],
      child: BlocBuilder<AppStateCubit, AppState>(
        buildWhen: (previousState, currentState) =>
            currentState is AppInitial || currentState is AppStateRestored,
        builder: (context, state) {
          if (state is AppStateRestored) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: MaterialApp.router(
                  theme: AppTheme.light,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  debugShowCheckedModeBanner: false,
                  routerConfig: _router),
            );
          }
          log('home page loaded');
          return MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
