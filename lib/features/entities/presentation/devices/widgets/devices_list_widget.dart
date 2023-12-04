import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../injector.dart';
import '../../../data/models/models.dart';
import '../cubits/cubits.dart';
import 'widgets.dart';

class DevicesListWidget extends StatefulWidget {
  final String type;

  const DevicesListWidget({super.key, required this.type});

  @override
  State<DevicesListWidget> createState() => _DevicesListWidgetState();
}

class _DevicesListWidgetState extends State<DevicesListWidget> {
  EntityModel? currentEstablishment;

  final bool _isLoading = false;

  late String deviceType;

  void _getDevices() => context.read<DevicesCubit>().getPagedDevicesByParent(
      0, '', deviceType, currentEstablishment!.id.id,
      pageSize: 3);

  @override
  void initState() {
    currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    deviceType = widget.type;
    _getDevices();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DevicesListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    deviceType = widget.type;
    _getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppStateCubit, AppState>(
      listener: (context, state) {
        if (state is AppStateDeviceClaimed) {
          _getDevices();
        }
      },
      child: BlocConsumer<DevicesCubit, DevicesState>(
        listener: (context, state) {
          if (state is DevicesFail) {
            MyDialogs.showErrorDialog(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is DevicesLoading) {
            return const SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          List<EntitySearchModel> items = [];
          if (state is DevicesNewPage) {
            items = state.searchDevices ?? [];
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() {
                _getDevices();
              }),
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    Widget child = BlocProvider(
                      create: (context) => injector<DeviceLastTelemetryCubit>(),
                      child: DeviceListTile(
                        device: items[index].toEntityModel(),
                        onTap: () async {
                          bool result = await context.pushNamed<bool>(
                                  kMapDevicesDetailsPageRoute,
                                  extra: items[index].toEntityModel()) ??
                              false;
                          if (result && mounted) {
                            _getDevices();
                          }
                        },
                      ),
                    );
                    return index == items.length - 1
                        ? const SizedBox(
                            height: 20,
                          )
                        : child;
                  }),
            ),
          );
        },
      ),
    );
  }
}
