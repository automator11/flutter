import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/resources/destinations.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../../injector.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../../common_widgets/widgets.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';

class DevicesTablePage extends StatefulWidget {
  final String type;

  const DevicesTablePage({super.key, required this.type});

  @override
  State<DevicesTablePage> createState() => _DevicesTablePageState();
}

class _DevicesTablePageState extends State<DevicesTablePage> {
  final PagingController<int, EntitySearchModel> _pagingController =
      PagingController(firstPageKey: 0);
  EntityModel? currentEstablishment;

  final int _rowsPerPage = 50;

  String _search = "";

  int? nextPage;
  int pageSize = 50;
  int total = 0;

  bool _isLoading = false;

  void _getPage(int page) {
    context.read<DevicesCubit>().getPagedDevicesByParent(
        page, _search, widget.type, currentEstablishment!.id.id,
        pageSize: _rowsPerPage);
  }

  @override
  void initState() {
    currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    if (currentEstablishment != null) {
      _pagingController.addPageRequestListener((pageKey) {
        _getPage(pageKey);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppStateCubit, AppState>(
      listener: (context, state) {
        if (state is AppStateDeviceClaimed) {
          _pagingController.refresh();
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        double tableWidth = constraints.maxWidth - 40;
        double headerHeight = 40;
        double tableHeight = constraints.maxHeight - headerHeight - 12;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: headerHeight,
                          height: headerHeight,
                          child: CustomElevatedButton(
                              padding: EdgeInsets.zero,
                              backgroundColor: kSecondaryColor,
                              onPressed: () async {
                                if (widget.type == kEarTagType) {
                                  await showDialog(
                                      context: context,
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                injector<DevicesCubit>(),
                                            child:
                                                const ClaimEarTagDevicesDialog(),
                                          ));
                                } else {
                                  await showDialog(
                                      context: context,
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                injector<DevicesCubit>(),
                                            child: const ClaimDeviceDialog(),
                                          ));
                                }
                                if (mounted) {
                                  context
                                      .read<AppStateCubit>()
                                      .emitDeviceClaimed();
                                }
                              },
                              child: const Icon(
                                Ionicons.add_outline,
                                color: Colors.white,
                              )),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        SizedBox(
                          width: headerHeight,
                          height: headerHeight,
                          child: CustomElevatedButton(
                              padding: EdgeInsets.zero,
                              backgroundColor: kSecondaryColor,
                              onPressed: () {
                                context.goNamed(
                                    allDestinations
                                        .firstWhere(
                                            (element) =>
                                                element.type == widget.type,
                                            orElse: () => allDestinations.first)
                                        .path,
                                    queryParameters: {'type': widget.type});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                    'assets/icons/return_white_icon.png'),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 200,
                      height: headerHeight,
                      child: TextField(
                        onChanged: (value) {
                          Debouncer deb = Debouncer(milliseconds: 500);
                          deb.run(() {
                            setState(() {
                              _search = value;
                            });
                            _getPage(0);
                          });
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'search'.tr(),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/icons/search_grey.png',
                              width: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocConsumer<DevicesCubit, DevicesState>(
                  listener: (context, state) {
                if (_isLoading) {
                  _isLoading = false;
                  Navigator.of(context, rootNavigator: true).pop();
                }
                if (state is DevicesLoading) {
                  _isLoading = true;
                  MyDialogs.showLoadingDialog(
                      context, 'loadingDeleteDevice'.tr(args: [widget.type]));
                }
                if (state is DevicesSuccess) {
                  MyDialogs.showSuccessDialog(
                      context, 'deleteDeviceSuccess'.tr(args: [widget.type]));
                  _pagingController.refresh();
                }
                if (state is DevicesFail) {
                  MyDialogs.showErrorDialog(context, state.message);
                }
              }, builder: (context, state) {
                if (state is DevicesNewPage) {
                  _pagingController.value = PagingState(
                    nextPageKey: state.pageKey,
                    error: state.error,
                    itemList: state.searchDevices,
                  );
                  total = state.total!;
                }
                return TableWidget(
                  pagingController: _pagingController,
                  entityInfo: _getDevicesInformation(),
                  entityTelemetry: _getDevicesTelemetry(),
                  isDevice: true,
                  tableWidth: tableWidth,
                  itemsCount: total,
                  maxHeight: tableHeight,
                  details: (item) async {
                    context.goNamed(kMapDevicesDetailsPageRoute,
                        extra: item.toEntityModel());
                  },
                  onEdit: (item) async {
                    context.goNamed(kMapConfigureDevicesPageRoute,
                        queryParameters: {'fromTable': '1'},
                        extra: item.toEntityModel());
                  },
                  onDelete: (item) async {
                    bool result = await MyDialogs.showQuestionDialog(
                          context: context,
                          title: 'delete'.tr(args: [
                            item.latest.type ?? '',
                            item.latest.label
                          ]),
                          message: 'deleteMessage'.tr(args: [
                            item.latest.type ?? '',
                            item.latest.label
                          ]),
                        ) ??
                        false;
                    if (result && context.mounted) {
                      context
                          .read<DevicesCubit>()
                          .removeDevice(item.entityId.id);
                    }
                  },
                );
              })
            ],
          ),
        );
      }),
    );
  }

  List<String> _getDevicesInformation() {
    switch (widget.type) {
      case kWaterLevelType:
        return ["maxLevel", "minLevel"];
      case kControllerType:
        return [];
      case kTempAndHumidityType:
        return [];
      case kEarTagType:
        return ["batchName", "animalName"];
      default:
        return [];
    }
  }

  List<String> _getDevicesTelemetry() {
    switch (widget.type) {
      case kWaterLevelType:
        return ["level", "vBat"];
      case kControllerType:
        return ["actStatus", "vBat"];
      case kTempAndHumidityType:
        return ["temperature", "humidity", "vBat"];
      case kEarTagType:
        return ["vBat"];
      default:
        return [];
    }
  }
}
