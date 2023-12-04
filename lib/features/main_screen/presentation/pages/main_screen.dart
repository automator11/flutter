import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../config/routes/routes.dart';
import '../../../../config/themes/colors.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/resources/destinations.dart';
import '../../../../injector.dart';
import '../../../alerts/presentation/cubits/alerts_cubit.dart';
import '../../../alerts/presentation/widgets/widgets.dart';
import '../../../entities/data/models/models.dart';
import '../../../entities/presentation/assets/cubits/cubits.dart';
import '../../../entities/presentation/assets/widgets/widgets.dart';
import '../../../user/data/models/models.dart';
import '../cubit/cubits.dart';
import '../widgets/widgets.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final scrollController = ScrollController();

  int currentIndex = 0;

  EntityModel? _currentEstablishment;
  UserModel? _user;
  late Widget _notificationIcon;

  DropdownSelectedState _establishmentsState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntityModel>[]);

  void _initData() {
    _user = context.read<AuthCubit>().user;
    context.read<AlertsCubit>().searchAlertsByStatus('UNACK');
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;

    _notificationIcon =
        Image.asset('assets/icons/read_notification_filled.png', width: 24);
  }

  double _getMapWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 1000) {
      return 1000;
    }
    return screenWidth;
  }

  @override
  void initState() {
    _initData();
    context.read<DropdownCubit>().getEstablishments();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    _initData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppStateCubit, AppState>(
          listener: (context, state) {
            if (state is AppStateUpdatedCurrentEstablishment) {
              setState(() {
                _currentEstablishment = state.establishment;
              });
            }
          },
        ),
        BlocListener<EstablishmentsCubit, EstablishmentsState>(
          listener: (context, state) {
            if (state is EstablishmentsSuccess) {
              context.read<DropdownCubit>().getEstablishments();
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              context.goNamed(kLoginPageRoute);
            }
          },
        ),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: kSecondaryBackground,
        drawerEnableOpenDragGesture: false,
        drawer: PointerInterceptor(
          child: SideMenu(
            currentIndex: currentIndex,
            onItemSelected: (index) async {
              currentIndex = index;
              Map<String, dynamic> queryParams = {};
              if (index > 0) {
                bool result = true;
                if (_currentEstablishment == null) {
                  result = await showDialog(
                          context: context,
                          builder: (context) => BlocProvider(
                                create: (context) =>
                                    injector<EstablishmentsCubit>(),
                                child: const SelectEstablishmentDialog(),
                              )) ??
                      false;
                }
                if (!result) {
                  return;
                }
                queryParams = {'type': allDestinations[index].type};
              }
              if (mounted) {
                context.goNamed(allDestinations[index].path,
                    queryParameters: queryParams);
              }
            },
            closeDrawer: () {
              if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                _scaffoldKey.currentState?.closeDrawer();
              }
            },
          ),
        ),
        body: Scrollbar(
          controller: scrollController,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              height: MediaQuery.of(context).size.height,
              constraints:
                  BoxConstraints(minWidth: 700, maxWidth: _getMapWidth(context)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (Responsive.isDesktop(context))
                      Container(
                        constraints:
                            const BoxConstraints(minWidth: 150, maxWidth: 250),
                        child: SideMenu(
                          currentIndex: currentIndex,
                          onItemSelected: (index) async {
                            currentIndex = index;
                            Map<String, dynamic> queryParams = {};
                            if (index > 0) {
                              bool result = true;
                              if (_currentEstablishment == null) {
                                result = await showDialog(
                                        context: context,
                                        builder: (context) => BlocProvider(
                                              create: (context) =>
                                                  injector<EstablishmentsCubit>(),
                                              child:
                                                  const SelectEstablishmentDialog(),
                                            )) ??
                                    false;
                              }
                              if (!result) {
                                return;
                              }
                              queryParams = {'type': allDestinations[index].type};
                            }
                            if (mounted) {
                              context.goNamed(allDestinations[index].path,
                                  queryParameters: queryParams);
                            }
                          },
                        ),
                      ),
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
                                        _scaffoldKey.currentState?.openDrawer();
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
                                  Container(
                                    constraints: const BoxConstraints(
                                        maxWidth: 300, minWidth: 100),
                                    child: BlocSelector<DropdownCubit,
                                        DropdownState, DropdownSelectedState>(
                                      selector: (state) {
                                        if (state.groupType ==
                                            kEstablishmentTypeKey) {
                                          bool isLoading =
                                              state is DropdownLoading;
                                          bool hasError = state is DropdownFail;
                                          List<EntityModel> establishments = [];
                                          if (state is DropdownSuccess) {
                                            log('establishments loaded');
                                            establishments = state.items!;
                                            if (_currentEstablishment == null &&
                                                establishments.isNotEmpty) {
                                              _currentEstablishment =
                                                  establishments.first;
                                              log('set establishment ${_currentEstablishment?.name} as selected');
                                              context
                                                  .read<AppStateCubit>()
                                                  .updateCurrentEstablishment(
                                                      _currentEstablishment!,
                                                      _user!.id.id);
                                            }
                                          }
                                          if (state is DropdownFail) {
                                            establishments = [];
                                          }
                                          _establishmentsState =
                                              DropdownSelectedState(
                                                  isLoading: isLoading,
                                                  error: hasError,
                                                  items: establishments);
                                          return _establishmentsState;
                                        }
                                        return _establishmentsState;
                                      },
                                      builder: (context, state) {
                                        return CustomDropDown<EntityModel>(
                                          initialValue: _currentEstablishment,
                                          items: state.items as List<EntityModel>,
                                          menuItems: (state.items
                                                      as List<EntityModel>)
                                                  .isNotEmpty
                                              ? (state.items as List<EntityModel>)
                                                  .map((e) => DropdownMenuItem<
                                                          EntityModel>(
                                                      value: e,
                                                      child:
                                                          _getEstablishmentItem(
                                                              e, 300)))
                                                  .toList()
                                              : [],
                                          selectedItemBuilder: (context) => (state
                                                  .items as List<EntityModel>)
                                              .map((e) =>
                                                  DropdownMenuItem<EntityModel>(
                                                      value: e,
                                                      child:
                                                          _getEstablishmentItem(
                                                              e, 250)))
                                              .toList(),
                                          hint: '',
                                          isLoading: state.isLoading,
                                          hasError: state.error,
                                          style: const TextStyle(fontSize: 14),
                                          onChange: (value) {
                                            context
                                                .read<AppStateCubit>()
                                                .updateCurrentEstablishment(
                                                    value!, _user!.id.id);
                                          },
                                          onRefresh: () => context
                                              .read<DropdownCubit>()
                                              .getEstablishments(),
                                          validator: (value) {
                                            if (value == null) {
                                              return 'emptyFieldValidation'.tr();
                                            }
                                            return null;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(9)),
                                            padding: EdgeInsets.zero),
                                        onPressed: () {
                                          context.pushNamed<EntityModel?>(
                                              kMapEditAssetPageRoute,
                                              queryParameters: {
                                                'type': kEstablishmentTypeKey
                                              }).then((value) {
                                            if (value != null) {
                                              context
                                                  .read<AppStateCubit>()
                                                  .updateCurrentEstablishment(
                                                      value, _user!.id.id);
                                            }
                                          });
                                        },
                                        child: const Icon(
                                          Ionicons.add_outline,
                                          color: kSecondaryColor,
                                        )),
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
                                                      BorderRadius.circular(20)),
                                              splashRadius: 4,
                                              icon: _notificationIcon,
                                              tooltip: 'alerts'.tr(),
                                              offset: const Offset(0, 40),
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                    child: PointerInterceptor(
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
                                                              AlertsListWidget())),
                                                ))
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

  Widget _getEstablishmentItem(EntityModel e, double width) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              e.label ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          CircleButton(
              onTap: () async {
                await context.pushNamed<EntityModel?>(kMapEditAssetPageRoute,
                    extra: e,
                    queryParameters: {'type': kEstablishmentTypeKey}).then(
                  (value) => context.read<DropdownCubit>().getEstablishments(),
                );
              },
              backgroundColor: kPrimaryColor,
              elevation: 0,
              icon: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Ionicons.pencil_outline,
                  color: Colors.white,
                  size: 14,
                ),
              )),
          const SizedBox(
            width: 10,
          ),
          CircleButton(
              onTap: () async {
                bool result = await MyDialogs.showQuestionDialog(
                      context: context,
                      title: 'delete'
                          .tr(args: [kEstablishmentTypeKey, e.label ?? '']),
                      message: 'deleteMessage'
                          .tr(args: [kEstablishmentTypeKey, e.label ?? '']),
                    ) ??
                    false;
                if (result && mounted) {
                  context
                      .read<EstablishmentsCubit>()
                      .deleteEstablishment(e.id.id);
                }
              },
              backgroundColor: kSecondaryColor,
              elevation: 0,
              icon: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Ionicons.trash_outline,
                  color: Colors.white,
                  size: 14,
                ),
              ))
        ],
      ),
    );
  }
}
