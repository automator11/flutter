import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../entities/data/models/models.dart';
import '../../../entities/data/params/devices_params/params.dart';
import '../../../entities/presentation/devices/cubits/cubits.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';

class AssetMapDetailsWidget extends StatefulWidget {
  final EntityModel asset;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  const AssetMapDetailsWidget(
      {super.key, required this.asset, this.onEdit, this.onDelete, this.onClose});

  @override
  State<AssetMapDetailsWidget> createState() => _AssetMapDetailsWidgetState();
}

class _AssetMapDetailsWidgetState extends State<AssetMapDetailsWidget> {
  Map<String, dynamic> _telemetry = {};
  List<dynamic> _attributes = [];
  bool _isLoading = false;
  bool _error = false;
  String _lastUpdate = 'unknown';

  @override
  void initState() {
    if (widget.asset.id.entityType == 'DEVICE') {
      context
          .read<DeviceLastTelemetryCubit>()
          .getDeviceLastTelemetry(widget.asset.id.id);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AssetMapDetailsWidget oldWidget) {
    if (widget.asset.id.entityType == 'DEVICE') {
      context
          .read<DeviceLastTelemetryCubit>()
          .getDeviceLastTelemetry(widget.asset.id.id);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceLastTelemetryCubit, DeviceLastTelemetryState>(
      builder: (context, state) {
        if (state is DeviceLastTelemetrySuccess) {
          _telemetry = state.telemetry;
          _attributes = state.attributes;
          _lastUpdate = Utils.getTimeAgoDate(
              (_telemetry.values.first as List).first['ts'],
              locale: context.locale.languageCode);
        }
        _isLoading = state is DeviceLastTelemetryLoading;
        if (_isLoading) {}
        _error = state is DeviceLastTelemetryFail;
        if (_error) {}
        return Container(
          constraints: const BoxConstraints(maxHeight: 180, maxWidth: 250),
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          widget.asset.label ?? '',
                          style: const TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      if (widget.asset.id.entityType != 'ASSET')
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 10),
                          child: BatteryIndicator(
                            value: _getBatValue() / 3.55,
                            trackHeight: 14,
                            barColor: kBatteryIndicatorColor,
                            iconOutline: kBatteryBorderColor,
                            icon: Text(
                              '${_getBatValue()}V',
                              style: const TextStyle(
                                  color: kPrimaryText, fontSize: 8),
                            ),
                          ),
                        ),
                      if (_isLoading)
                        const LinearProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      if (!_isLoading)
                        const Divider(
                          height: 10,
                        ),
                      ..._getAssetInfo(),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                if (widget.asset.id.entityType == 'DEVICE')
                  Positioned(
                    left: 16,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
                  ),
                Positioned(
                    right: 8,
                    bottom: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.asset.id.entityType == 'DEVICE')
                          CircleButton(
                              onTap: () => context
                                  .read<DeviceLastTelemetryCubit>()
                                  .getDeviceLastTelemetry(widget.asset.id.id),
                              backgroundColor: Colors.green[600],
                              elevation: 0,
                              icon: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Ionicons.refresh_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )),
                        if (widget.onEdit != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: CircleButton(
                                onTap: widget.onEdit,
                                backgroundColor: kPrimaryColor,
                                elevation: 0,
                                icon: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Ionicons.pencil_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )),
                          ),
                        if (widget.onDelete != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: CircleButton(
                                onTap: widget.onDelete,
                                backgroundColor: kSecondaryColor,
                                elevation: 0,
                                icon: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Ionicons.trash_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )),
                          )
                      ],
                    )),
                Positioned(
                    top: 8,
                    right: 8,
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircleButton(
                        onTap: widget.onClose,
                        icon: const Icon(
                          Ionicons.close,
                          color: kIconLightColor,
                          size: 18,
                        ),
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  double _getBatValue() {
    if (_telemetry.isEmpty) {
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

  Widget _getRowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: kPrimaryText, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          Text(value,
              style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12))
        ],
      ),
    );
  }

  List<Widget> _getAssetInfo() {
    Map<String, dynamic> info = widget.asset.additionalInfo ?? {};
    switch (widget.asset.type) {
      case kGatewayTypeKey:
        return [_getRowInfo('Gateway ID:', info['id'] ?? '--')];
      case kPaddockTypeKey:
        String usableAreaTxt = '--';
        String totalAreaTxt = '--';
        double? usableArea = info['usableArea'];
        double? totalArea = info['totalArea'];
        if (usableArea != null) {
          usableAreaTxt = usableArea.toStringAsFixed(2);
        }
        if (totalArea != null) {
          totalAreaTxt = totalArea.toStringAsFixed(2);
        }
        return [
          _getRowInfo('${'usableArea'.tr()}:', '$usableAreaTxt ha'),
          _getRowInfo('${'totalArea'.tr()}:', '$totalAreaTxt ha'),
        ];
      case kWaterFontTypeKey:
        String volumeTxt = '--';
        double? volume = info['volume'];
        if (volume != null) {
          volumeTxt = volume.toStringAsFixed(2);
        }
        return [
          _getRowInfo('${'type'.tr()}:', info['type'] ?? '--'),
          _getRowInfo('${'capacity'.tr()}:', '$volumeTxt L'),
        ];
      case kShadowTypeKey:
        String totalAreaTxt = '--';
        double? totalArea = info['totalArea'];
        if (totalArea != null) {
          totalAreaTxt = totalArea.toStringAsFixed(2);
        }
        return [
          _getRowInfo('${'area'.tr()}:', '$totalAreaTxt ha'),
        ];
      case kWaterLevelType:
        String currentLevel = '--';
        String percent = '--';
        double? maxLevel;
        if (info.containsKey('maxLevel')) {
          maxLevel = double.tryParse(info['maxLevel']?.toString() ?? "");
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
          _getRowInfo('${'actualState'.tr()}: ', currentLevel),
          _getRowInfo('${'full'.tr()}: ', percent),
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
          _getRowInfo('${'temperature'.tr()}: ', temperature),
          _getRowInfo('${'humidity'.tr()}: ', humidity),
        ];
      case kControllerType:
        bool status = false;
        bool disabled = false;
        if (_telemetry.containsKey('actStatus')) {
          List statusValues = _telemetry['actStatus'] ?? [];
          status = statusValues.isNotEmpty
              ? statusValues.first['value'] == 'ON'
                  ? true
                  : false
              : false;
        }
        for (var attr in _attributes) {
          if (attr['key'] == 'waitingRpcCommandAck') {
            disabled = attr['value'];
          }
        }
        return [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${'controllerActualState'.tr()}: ',
                      style: const TextStyle(
                          color: kPrimaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CupertinoSwitch(
                        value: status,
                        onChanged: disabled
                            ? null
                            : (value) async {
                                String action = value ? 'ON' : 'OFF';
                                String deviceLabel = widget.asset.label ?? '';
                                String deviceId = widget.asset.id.id;
                                bool result =
                                    await MyDialogs.showQuestionDialog(
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
                  ),
                ],
              ),
            ),
          ),
        ];
      case kEarTagType:
        return [
          _getRowInfo('${'batch'.tr()}: ', info['batchName'] ?? 'noData'.tr()),
          _getRowInfo(
              '${'Animal'.tr()}: ', widget.asset.label ?? 'unknown'.tr()),
        ];
      default:
        return [];
    }
  }
}
