import 'params.dart';

class ConfigureWaterLevelParams extends ConfigureDeviceParams {
  final Map<String, dynamic> currentInfo;
  final double initLevel;
  final double minLevel;
  final double maxLevel;
  final Map<String, dynamic> position;

  ConfigureWaterLevelParams(
      {required super.id,
      required super.createdTime,
      required super.customerId,
      required super.label,
      required super.name,
      required super.ownerId,
      required super.tenantId,
      required super.type,
      required super.deviceData,
      required super.deviceProfileId,
      required super.establishmentName,
      required this.currentInfo,
      required this.initLevel,
      required this.maxLevel,
      required this.minLevel,
      required this.position})
      : super(
            additionalInfo: currentInfo
              ..addAll({
                "initLevel": initLevel,
                "maxLevel": maxLevel,
                "minLevel": minLevel,
                "position": position
              })
              ..addAll({'establishmentName': establishmentName}));
}
