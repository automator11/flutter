import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../data/models/models.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';

class DeviceDetailsPage extends StatefulWidget {
  final EntityModel device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  bool _isLoading = false;
  late EntityModel _device;

  Map<String, dynamic> _telemetry = {};
  List<dynamic> _attributes = [];
  bool _isTelemetryLoading = false;

  @override
  void initState() {
    _device = widget.device;
    context
        .read<DeviceLastTelemetryCubit>()
        .getDeviceLastTelemetry(_device.id.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: kPrimaryBackground,
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: BlocListener<DevicesCubit, DevicesState>(
        listener: (context, state) async {
          if (_isLoading) {
            _isLoading = false;
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (state is DevicesLoading) {
            _isLoading = true;
            MyDialogs.showLoadingDialog(context,
                'loadingRemoveDevice'.tr(args: [_device.type?.tr() ?? '']));
          }
          if (state is DevicesSuccess) {
            await MyDialogs.showSuccessDialog(context,
                'removeDeviceSuccess'.tr(args: [_device.type?.tr() ?? '']));
            if (!mounted) {
              return;
            }
            Navigator.of(context, rootNavigator: true).pop(true);
          }
          if (state is DevicesFail) {
            if (!mounted) {
              return;
            }
            MyDialogs.showErrorDialog(context, state.message);
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                child: SingleChildScrollView(
                  child: BlocBuilder<DeviceLastTelemetryCubit,
                      DeviceLastTelemetryState>(
                    builder: (context, state) {
                      if (state is DeviceLastTelemetrySuccess) {
                        _telemetry = state.telemetry;
                        _attributes = state.attributes;
                      }
                      _isTelemetryLoading = state is DeviceLastTelemetryLoading;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width -
                                  (2 * 84) -
                                  16,
                              child: Text(
                                _device.label ?? '',
                                style: const TextStyle(
                                    color: kSecondaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ).tr(),
                            ),
                          ),
                          if (_isTelemetryLoading)
                            const SizedBox(
                              width: 200,
                              child: LinearProgressIndicator(),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (_device.type == kWaterLevelType)
                            WaterLevelDetailsWidget(
                              device: _device,
                              telemetry: _telemetry,
                              telemetryLoading: _isTelemetryLoading,
                            ),
                          if (_device.type == kTempAndHumidityType)
                            TempHumDetailsWidget(
                              device: _device,
                              telemetry: _telemetry,
                              telemetryLoading: _isTelemetryLoading,
                            ),
                          if (_device.type == kControllerType)
                            ControllerDetailsWidget(
                              device: _device,
                              telemetry: _telemetry,
                              telemetryLoading: _isTelemetryLoading,
                            ),
                          if (_device.type == kEarTagType)
                            EarTagDetailsWidget(
                              device: _device,
                              telemetry: _telemetry,
                              attributes: _attributes,
                              telemetryLoading: _isTelemetryLoading,
                            ),
                          const SizedBox(
                            height: 60,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
                top: 8,
                right: 8,
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircleButton(
                    onTap: () {
                      context.goNamed(kMapPageRoute);
                    },
                    icon: const Icon(
                      Ionicons.close_outline,
                      color: kIconLightColor,
                      size: 18,
                    ),
                  ),
                )),
            // Positioned(
            //     top: 16,
            //     right: 16,
            //     child: MenuButton(
            //       onTap: () async {
            //         bool result = await MyDialogs.showQuestionDialog(
            //               context: context,
            //               title: 'removeDevice'
            //                   .tr(args: [_device.type?.tr() ?? '']),
            //               message: 'removeDeviceMessage'.tr(namedArgs: {
            //                 "deviceType": _device.type?.tr() ?? '',
            //                 "deviceName": _device.label ?? ''
            //               }),
            //             ) ??
            //             false;
            //         if (result && mounted) {
            //           context.read<DevicesCubit>().removeDevice(_device.name);
            //         }
            //       },
            //       icon: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Image.asset(
            //           'assets/icons/reclaim.png',
            //         ),
            //       ),
            //     )),
            Positioned(
                top: 8,
                left: 8,
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircleButton(
                    onTap: () {
                      context.goNamed(kMapDevicesPageRoute,
                          queryParameters: {'type': widget.device.type});
                    },
                    icon: const Icon(
                      Ionicons.chevron_back_outline,
                      color: kIconLightColor,
                      size: 18,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
