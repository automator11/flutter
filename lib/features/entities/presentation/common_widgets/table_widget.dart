import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/params/devices_params/params.dart';
import '../devices/cubits/cubits.dart';
import 'widgets.dart';

class TableWidget extends StatelessWidget {
  final List<String> entityInfo;
  final List<String> entityTelemetry;
  final double tableWidth;
  final PagingController<int, EntitySearchModel> pagingController;
  final int itemsCount;
  final double maxHeight;
  final bool isDevice;
  final Function(EntitySearchModel) onEdit;
  final Function(EntitySearchModel) onDelete;
  final Function(EntitySearchModel) details;

  const TableWidget(
      {super.key,
      required this.entityInfo,
      this.entityTelemetry = const [],
      required this.tableWidth,
      required this.pagingController,
      required this.itemsCount,
      required this.maxHeight,
      this.isDevice = false,
      required this.onEdit,
      required this.onDelete,
      required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          border: const Border.fromBorderSide(
              BorderSide(color: kInputDefaultBorderColor)),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TableRowWidget(
              rowBackgroundColor: kSecondaryColor,
              rowBorderRadius: BorderRadius.circular(10),
              cells: [
                SizedBox(
                    width: 80,
                    child: Align(
                      alignment: Alignment.center,
                      child: const Text(
                        'name',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ).tr(),
                    )),
                ...entityInfo.map((label) => Container(
                    constraints: const BoxConstraints.expand(width: 100),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border: Border(
                      left: BorderSide(color: Colors.white),
                    )),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ).tr())),
                if (isDevice) ...[
                  Container(
                      constraints: const BoxConstraints.expand(width: 100),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          border: Border(
                        left: BorderSide(color: Colors.white),
                      )),
                      child: const Text(
                        'lastReport',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ).tr())
                ],
                ...entityTelemetry.map((label) => Container(
                    constraints: const BoxConstraints.expand(width: 100),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border: Border(
                      left: BorderSide(color: Colors.white),
                    )),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ).tr())),
                Container(
                    constraints: const BoxConstraints.expand(width: 150),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border: Border(
                      left: BorderSide(color: Colors.white),
                    )),
                    child: const Text(
                      'action',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ).tr()),
              ]),
          Container(
            constraints:
                BoxConstraints(maxWidth: tableWidth, maxHeight: maxHeight - 45),
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() {
                pagingController.refresh();
              }),
              child: PagedListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<EntitySearchModel>(
                    itemBuilder: (context, item, index) => TableRowWidget(
                          rowBorderSide: index == itemsCount - 1
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                      color: kInputDefaultBorderColor)),
                          cells: [
                            SizedBox(
                                width: 80,
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.latest.label,
                                      style: const TextStyle(fontSize: 12),
                                    ))),
                            ...entityInfo.map((label) => SizedBox(
                                  width: 100,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        _getFormattedInfoValue(label, item),
                                        style: const TextStyle(fontSize: 12)),
                                  ),
                                )),
                            if (isDevice) ...[
                              SizedBox(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      _getLastUpdate(
                                          context, item.latest.latestValues),
                                      style: const TextStyle(fontSize: 12)),
                                ),
                              )
                            ],
                            ...entityTelemetry.map((label) => SizedBox(
                                  width: 100,
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: _getTelemetryValueWidget(
                                          context, label, item)),
                                )),
                            SizedBox(
                              width: 150,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Tooltip(
                                    message: 'seeOnMap'.tr(),
                                    child: CircleButton(
                                        onTap: () => details(item),
                                        backgroundColor: kPrimaryColor,
                                        elevation: 0,
                                        icon: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Ionicons.map_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        )),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Tooltip(
                                    message: 'edit'.tr(),
                                    child: CircleButton(
                                        onTap: () => onEdit(item),
                                        backgroundColor: kPrimaryColor,
                                        elevation: 0,
                                        icon: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Ionicons.pencil_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        )),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Tooltip(
                                    message: 'delete'.tr(),
                                    child: CircleButton(
                                        onTap: () => onDelete(item),
                                        backgroundColor: kPrimaryColor,
                                        elevation: 0,
                                        icon: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Ionicons.trash_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                    firstPageErrorIndicatorBuilder: (context) =>
                        FirstPageErrorWidget(
                          message: pagingController.error.toString(),
                          onRetry: () {
                            pagingController.refresh();
                          },
                        ),
                    newPageErrorIndicatorBuilder: (context) =>
                        NewPageErrorWidget(
                          message: pagingController.error.toString(),
                          onRetry: () {
                            pagingController.refresh();
                          },
                        ),
                    noItemsFoundIndicatorBuilder: (context) =>
                        NoItemsFoundWidget(
                          onRefresh: () {
                            pagingController.refresh();
                          },
                        ),
                    noMoreItemsIndicatorBuilder: (context) => const SizedBox(
                          height: 4,
                        )),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getLastUpdate(BuildContext context, List<TelemetryModel>? telemetry) {
    if (telemetry?.isNotEmpty ?? false) {
      return Utils.getTimeAgoDate(telemetry!.first.lastUpdateTs,
          locale: context.locale.languageCode);
    }
    return '--';
  }

  String _getFormattedInfoValue(String key, EntitySearchModel entity) {
    Map<String, dynamic> info = entity.latest.additionalInfo ?? {};
    switch (entity.latest.type) {
      case kGatewayTypeKey:
        return info[key] ?? '--';
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
        return key == 'usableArea'
            ? '$usableAreaTxt ha'
            : key == 'totalArea'
                ? '$totalAreaTxt ha'
                : '--';
      case kWaterFontTypeKey:
        String volumeTxt = '--';
        double? volume = info['volume'];
        if (volume != null) {
          volumeTxt = volume.toStringAsFixed(2);
        }
        return key == 'type'
            ? info['type']
            : key == 'volume'
                ? '$volumeTxt L'
                : '--';
      case kShadowTypeKey:
        String totalAreaTxt = '--';
        double? totalArea = info['totalArea'];
        if (totalArea != null) {
          totalAreaTxt = totalArea.toStringAsFixed(2);
        }
        return key == 'totalArea' ? '$totalAreaTxt ha' : '--';
      case kBatchTypeKey:
        if (key == 'type') {
          return info['lotType'] ?? '--';
        }
        if (key == 'lotCategory') {
          return info['lotCategory'] ?? '--';
        }
        if (key == 'birthday') {
          return info['birthday']?.toString() ?? '--';
        }
        if (key == 'lotRace') {
          return info['lotRace'] ?? '--';
        }
        if (key == 'totalAnimals') {
          return info['totalAnimals']?.toString() ?? '--';
        }
        return '--';
      case kRotationTypeKey:
        if (key == 'parcelLabel') {
          return info['parcelLabel'] ?? '--';
        }
        if (key == 'lotLabel') {
          return info['lotLabel'] ?? '--';
        }
        if (key == 'startDate') {
          return Utils.getShortDate(DateTime.fromMillisecondsSinceEpoch(
                  info['startDate'],
                  isUtc: true)
              .toLocal());
        }
        if (key == 'endDate') {
          return Utils.getShortDate(
              DateTime.fromMillisecondsSinceEpoch(info['endDate'], isUtc: true)
                  .toLocal());
        }
        if (key == 'recurrence') {
          return info['recurrence'].toString();
        }
        if (key == 'recurrenceEndTime') {
          return Utils.getShortDate(DateTime.fromMillisecondsSinceEpoch(
                  info['recurrenceEndTime'],
                  isUtc: true)
              .toLocal());
        }
        return '--';
      case kAnimalTypeKey:
        if (key == 'type') {
          return info['type'] ?? '--';
        }
        if (key == 'type') {
          return info['type'] ?? '--';
        }
        if (key == 'category') {
          return info['category'] ?? '--';
        }
        if (key == 'birthday') {
          return info['birthday']?.toString() ?? '--';
        }
        if (key == 'race') {
          return info['race'] ?? '--';
        }
        return '--';
      case kWaterLevelType:
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
        return key == 'maxLevel'
            ? maxLevelTxt
            : key == 'minLevel'
                ? minLevelTxt
                : '--';
      case kEarTagType:
        return key == 'batchName'
            ? info['batchName'] ?? '--'
            : key == 'animalName'
                ? entity.latest.label
                : '--';
      default:
        return '--';
    }
  }

  Widget _getTelemetryValueWidget(
      BuildContext context, String key, EntitySearchModel entity) {
    List<TelemetryModel> telemetry = entity.latest.latestValues ?? [];
    if (key == 'vBat') {
      TelemetryModel vBatTelemetry = telemetry.firstWhere(
        (element) => element.key == 'vBat',
        orElse: () =>
            const TelemetryModel(lastUpdateTs: 0, key: 'vBat', value: 0.0),
      );
      double vBat = double.tryParse(vBatTelemetry.value.toString()) ?? 0.0;
      return BatteryIndicator(
        value: vBat / 3.55,
        trackHeight: 14,
        barColor: kBatteryIndicatorColor,
        iconOutline: kBatteryBorderColor,
        icon: Text(
          '$vBat',
          style: const TextStyle(color: kPrimaryText, fontSize: 8),
        ),
      );
    }
    switch (entity.latest.type) {
      case kWaterLevelType:
        String currentLevel = '--';
        TelemetryModel levelTelemetry = telemetry.firstWhere(
          (element) => element.key == 'level',
          orElse: () =>
              const TelemetryModel(lastUpdateTs: 0, key: '', value: 0.0),
        );
        double? level = double.tryParse(levelTelemetry.value.toString());
        currentLevel = '${level?.toStringAsFixed(2) ?? '--'} cm';
        return Text(
          key == 'level' ? currentLevel : '--',
          style: const TextStyle(fontSize: 12),
        );
      case kTempAndHumidityType:
        String temperature = '--';
        String humidity = '--';
        TelemetryModel tempTelemetry = telemetry.firstWhere(
          (element) => element.key == 'temperature',
          orElse: () =>
              const TelemetryModel(lastUpdateTs: 0, key: '', value: 0.0),
        );
        temperature =
            '${double.tryParse(tempTelemetry.value.toString())?.toStringAsFixed(2) ?? '--'}°';
        TelemetryModel humTelemetry = telemetry.firstWhere(
          (element) => element.key == 'humidity',
          orElse: () =>
              const TelemetryModel(lastUpdateTs: 0, key: '', value: 0.0),
        );
        humidity =
            '${double.tryParse(humTelemetry.value.toString())?.toStringAsFixed(2) ?? '--'}%';
        return Text(
          key == 'temperature'
              ? temperature
              : key == 'humidity'
                  ? humidity
                  : '--',
          style: const TextStyle(fontSize: 12),
        );
      case kControllerType:
        bool status = false;
        bool disabled = false;
        TelemetryModel statusTelemetry = telemetry.firstWhere(
          (element) => element.key == 'actStatus',
          orElse: () =>
              const TelemetryModel(lastUpdateTs: 0, key: '', value: 'OFF'),
        );
        status = statusTelemetry.value == 'ON';
        TelemetryModel waitingRpcTelemetry = telemetry.firstWhere(
          (element) => element.key == 'waitingRpcCommandAck',
          orElse: () =>
              const TelemetryModel(lastUpdateTs: 0, key: '', value: false),
        );
        disabled = waitingRpcTelemetry.value;
        if (key == 'actStatus') {
          return SizedBox(
            width: 50,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: CupertinoSwitch(
                  value: status,
                  onChanged: disabled
                      ? null
                      : (value) async {
                          String action = value ? 'ON' : 'OFF';
                          String deviceLabel = entity.latest.label;
                          String deviceId = entity.entityId.id;
                          bool result = await MyDialogs.showQuestionDialog(
                                context: context,
                                title: 'sendCommand'.tr(),
                                message: 'sendCommandMessage'
                                    .tr(args: [action, deviceLabel]),
                              ) ??
                              false;
                          if (result) {
                            SaveControllersAttributesParams params =
                                SaveControllersAttributesParams(
                                    deviceId: deviceId, action: action);
                            context
                                .read<DeviceLastTelemetryCubit>()
                                .saveDeviceAttributes(params);
                          }
                        }),
            ),
          );
        }
        return Container();
      default:
        return Container();
    }
  }
}
