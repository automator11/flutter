
import '../../models/models.dart';
import 'params.dart';

class ConfigureTempHumParams extends ConfigureDeviceParams {
  final Map<String, dynamic> currentInfo;
  final Map<String, dynamic> position;
  final AlertsResponseModel alerts;

  ConfigureTempHumParams(
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
      required this.alerts,
      required this.position})
      : super(
            additionalInfo: currentInfo
              ..addAll(alerts.toJson())
              ..addAll({
                'establishmentName': establishmentName,
                'position': position
              }));
}
