
import '../../models/models.dart';
import 'params.dart';

class ConfigureControllerParams extends ConfigureDeviceParams {
  final Map<String, dynamic> currentInfo;
  final Map<String, dynamic> position;
  final AutomationsResponseModel automations;
  final String token;

  ConfigureControllerParams(
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
      required this.currentInfo,
      required this.automations,
      required this.position,
      required super.establishmentName,
      required this.token})
      : super(
            additionalInfo: currentInfo
              ..addAll(automations.toJson())
              ..addAll({
                'establishmentName': establishmentName,
                'position': position,
                "token": token
              }));
}
