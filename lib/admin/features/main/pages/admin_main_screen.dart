import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/routes.dart';
import '../../../../config/themes/colors.dart';
import '../../../../core/resources/destinations.dart';
import '../../../../features/alerts/presentation/cubits/alerts_cubit.dart';
import '../../../../features/alerts/presentation/widgets/alerts_list_widget.dart';
import '../../../../features/main_screen/presentation/cubit/cubits.dart';
import '../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../../features/user/data/models/models.dart';
import '../widgets/widgets.dart';

class AdminMainScreen extends StatefulWidget {
  final Widget child;

  const AdminMainScreen({super.key, required this.child});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final GlobalKey<ScaffoldState> _adminScaffoldKey = GlobalKey();
  final scrollController = ScrollController();

  int currentIndex = 0;

  UserModel? _user;
  late Widget _notificationIcon;

  double _getContentWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 1000) {
      return 1000;
    }
    return screenWidth;
  }

  void _initData() {
    _user = context.read<AuthCubit>().user;
    context.read<AlertsCubit>().searchAlertsByStatus('UNACK');

    _notificationIcon =
        Image.asset('assets/icons/read_notification_filled.png', width: 24);
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AdminMainScreen oldWidget) {
    _initData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              context.goNamed(kLoginPageRoute);
            }
          },
        ),
      ],
      child: Scaffold(
        key: _adminScaffoldKey,
        backgroundColor: kSecondaryBackground,
        drawerEnableOpenDragGesture: false,
        drawer: AdminSideMenu(
          currentIndex: currentIndex,
          onItemSelected: (index) async {
            currentIndex = index;
            context.goNamed(adminDestinations[index].path);
          },
          closeDrawer: () {
            if (_adminScaffoldKey.currentState?.isDrawerOpen ?? false) {
              _adminScaffoldKey.currentState?.closeDrawer();
            }
          },
        ),
        body: Scrollbar(
          controller: scrollController,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              height: MediaQuery.of(context).size.height,
              constraints: BoxConstraints(
                  minWidth: 700, maxWidth: _getContentWidth(context)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (Responsive.isDesktop(context))
                      Container(
                          constraints: const BoxConstraints(
                              minWidth: 150, maxWidth: 250),
                          child: AdminSideMenu(
                            currentIndex: currentIndex,
                            onItemSelected: (index) async {
                              currentIndex = index;
                              context.goNamed(adminDestinations[index].path);
                            },
                            closeDrawer: () {
                              if (_adminScaffoldKey
                                      .currentState?.isDrawerOpen ??
                                  false) {
                                _adminScaffoldKey.currentState?.closeDrawer();
                              }
                            },
                          )),
                    const SizedBox(
                      width: 16,
                    ),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: kToolbarHeight,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!Responsive.isDesktop(context))
                                    InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        _adminScaffoldKey.currentState
                                            ?.openDrawer();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Image.asset(
                                              'assets/icons/menu.png',
                                              width: 24),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child:
                                          BlocBuilder<AlertsCubit, AlertsState>(
                                        builder: (context, state) {
                                          if (state is AlertsSuccess) {
                                            if (state.items.isNotEmpty) {
                                              _notificationIcon = Image.asset(
                                                'assets/icons/notification_filled.png',
                                                width: 24,
                                              );
                                            }
                                          }
                                          return SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: PopupMenuButton(
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              constraints: const BoxConstraints(
                                                  maxWidth: 300, minWidth: 300),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              splashRadius: 4,
                                              icon: _notificationIcon,
                                              tooltip: 'alerts'.tr(),
                                              offset: const Offset(0, 40),
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                        maxHeight:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.6,
                                                        maxWidth: 300),
                                                    child: const Scaffold(
                                                        body:
                                                            AlertsListWidget()),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: UserMenuWidget(
                                      user: _user,
                                      onTap: () {},
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14)),
                                  child: widget.child),
                            )
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
