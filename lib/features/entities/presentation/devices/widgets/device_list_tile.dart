import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/utils.dart';
import '../../../data/models/models.dart';
import '../../../data/params/devices_params/params.dart';
import '../cubits/cubits.dart';

class DeviceListTile extends StatefulWidget {
  final EntityModel? device;
  final EntitySearchModel? searchDevice;
  final VoidCallback? onTap;

  const DeviceListTile({super.key, this.device, this.searchDevice, this.onTap});

  @override
  State<DeviceListTile> createState() => _DeviceListTileState();
}

class _DeviceListTileState extends State<DeviceListTile> {
  Map<String, dynamic> _telemetry = {};
  List<dynamic> _attributes = [];
  bool _isLoading = false;
  bool _error = false;
  String _lastUpdate = 'unknown';

  @override
  void initState() {
    String deviceId =
        widget.device?.id.id ?? widget.searchDevice?.entityId.id ?? '';
    context.read<DeviceLastTelemetryCubit>().getDeviceLastTelemetry(deviceId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeviceLastTelemetryCubit, DeviceLastTelemetryState>(
      listener: (context, state) {
        if (state is DeviceUpdateAttributesSuccess) {
          String deviceId =
              widget.device?.id.id ?? widget.searchDevice?.entityId.id ?? '';
          context
              .read<DeviceLastTelemetryCubit>()
              .getDeviceLastTelemetry(deviceId);
          MyDialogs.showSuccessDialog(context, 'commandSendSuccessfully'.tr());
        }
      },
      builder: (context, state) {
        String dataStatus = '';
        if (state is DeviceLastTelemetrySuccess) {
          _telemetry = state.telemetry;
          _attributes = state.attributes;
          dataStatus = 'connected';
          if (_telemetry.values.isNotEmpty) {
            _lastUpdate = Utils.getTimeAgoDate(
                (_telemetry.values.first as List).first['ts'],
                locale: context.locale.languageCode);
          }
        }
        _isLoading = state is DeviceLastTelemetryLoading;
        if (_isLoading) {
          dataStatus = 'connecting';
        }
        _error = state is DeviceLastTelemetryFail;
        if (_error) {
          dataStatus = 'disconnected';
        }
        return InkWell(
          onTap: widget.onTap,
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 40,
                            width: 50,
                            child: Utils.getDeviceIcon(_getDeviceType()),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            constraints: const BoxConstraints(
                                minHeight: 20, maxWidth: 80),
                            decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(4)),
                            child: Center(
                              child: Text(
                                _lastUpdate,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          if (_isLoading)
                            const SizedBox(
                              width: 80,
                              child: LinearProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(_getDeviceLabel(),
                                style: const TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(
                              height: 10,
                            ),
                            ..._getDeviceInfo(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: BatteryIndicator(
                    value: _getBatValue() / 3.55,
                    trackHeight: 14,
                    barColor: kBatteryIndicatorColor,
                    iconOutline: kBatteryBorderColor,
                    icon: Text(
                      '${_getBatValue()}V',
                      style: const TextStyle(color: kPrimaryText, fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getBatValue() {
    if (_telemetry.isEmpty || !_telemetry.containsKey('vBat')) {
      return 0;
    }
    double? vBat =
        double.tryParse((_telemetry['vBat'] as List).first['value'].toString());
    if (vBat == null) {
      return 0;
    }
    // double batLevel = (vBat - 3) / 1.7;
    return vBat;
  }

  String _getDeviceLabel() {
    return widget.device?.label ?? widget.searchDevice?.latest.label ?? '';
  }

  String _getDeviceType() {
    return widget.device?.type ?? widget.searchDevice?.latest.type ?? '';
  }

  List<Widget> _getDeviceInfo() {
    Map<String, dynamic> info = widget.device?.additionalInfo ??
        widget.searchDevice?.latest.additionalInfo ??
        {};
    switch (_getDeviceType()) {
      case kWaterLevelType:
        String currentLevel = '--';
        String percent = '--';
        String minLevelTxt = '--';
        String maxLevelTxt = '--';
        double? maxLevel;
        double? minLevel;
        if (info.containsKey('maxLevel')) {
          maxLevel = double.tryParse(info['maxLevel']?.toString() ?? "");
          maxLevelTxt = maxLevel?.toStringAsFixed(2) ?? '--';
        }
        if (info.containsKey('minLevel')) {
          minLevel = double.tryParse(info['minLevel']?.toString() ?? "");
          minLevelTxt = minLevel?.toStringAsFixed(2) ?? '--';
        }
        if (_telemetry.containsKey('level')) {
          double? level = double.tryParse(
              (_telemetry['level'] as List).first['value'].toString());
          currentLevel = '${level?.toStringAsFixed(2) ?? '--'} cm';
          if (level != null && maxLevel != null) {
            percent = '${(level / maxLevel * 100).toStringAsFixed(2)}%';
          }
        }
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'actualState'.tr()}: ',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              Expanded(
                child: Text(
                  currentLevel,
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.end,
                ),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'full'.tr()}: ',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              Expanded(
                child: Text(
                  percent,
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.end,
                ),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'minimum'.tr()}: ',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              Expanded(
                child: Text(
                  '${minLevelTxt.tr()} cm',
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.end,
                ),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'maximum'.tr()}: ',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              Expanded(
                child: Text('${maxLevelTxt.tr()} cm',
                    style: const TextStyle(
                        color: kSecondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.end),
              )
            ],
          ),
        ];
      case kTempAndHumidityType:
        String temperature = '--';
        String humidity = '--';
        if (_telemetry.containsKey('temperature')) {
          temperature =
              '${(double.tryParse((_telemetry['temperature'] as List).first['value'].toString()))?.toStringAsFixed(2) ?? '--'}°';
        }
        if (_telemetry.containsKey('humidity')) {
          humidity =
              '${(double.tryParse((_telemetry['humidity'] as List).first['value'].toString()))?.toStringAsFixed(2) ?? '--'}%';
        }
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'temperature'.tr()}: ',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              Expanded(
                child: Text(
                  temperature,
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'humidity'.tr()}: ',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              Expanded(
                child: Text(
                  humidity,
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.end,
                ),
              )
            ],
          )
        ];
      case kControllerType:
        bool status = false;
        bool disabled = false;
        if (_telemetry.isNotEmpty) {
          status = (_telemetry['actStatus'] as List).first['value'] == 'ON'
              ? true
              : false;
        }
        for (var attr in _attributes) {
          if (attr['key'] == 'waitingRpcCommandAck') {
            disabled = attr['value'];
          }
        }
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text('${'controllerActualState'.tr()}: ',
                    style:
                        const TextStyle(color: kSecondaryText, fontSize: 12)),
              ),
              CupertinoSwitch(
                  value: status,
                  onChanged: disabled
                      ? null
                      : (value) async {
                          String action = value ? 'ON' : 'OFF';
                          String deviceLabel = widget.device?.label ??
                              widget.searchDevice?.latest.label ??
                              '';
                          String deviceId = widget.device?.id.id ??
                              widget.searchDevice?.entityId.id ??
                              '';
                          bool result = await MyDialogs.showQuestionDialog(
                                context: context,
                                title: 'sendCommand'.tr(),
                                message: 'sendCommandMessage'
                                    .tr(args: [action, deviceLabel]),
                              ) ??
                              false;
                          if (result && mounted) {
                            SaveControllersAttributesParams params =
                                SaveControllersAttributesParams(
                                    deviceId: deviceId, action: action);
                            context
                                .read<DeviceLastTelemetryCubit>()
                                .saveDeviceAttributes(params);
                          }
                        }),
            ],
          ),
        ];
      case kEarTagType:
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'batch'.tr()}: ',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              Expanded(
                child: Text(info['batchName'] ?? 'No data',
                    style: const TextStyle(
                        color: kSecondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.end),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'Animal'.tr()}: ',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              Expanded(
                child: Text(
                  _getDeviceLabel(),
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.end,
                ),
              )
            ],
          )
        ];
      default:
        return [];
    }
  }
}
