
import '../common_params/params.dart';

class ConfigureDeviceParams extends EntityUpdateParams {
  Map<String, dynamic> deviceData;
  String? deviceProfileId;
  String? firmwareId;
  String? softwareId;
  String? externalId;
  String establishmentName;

  ConfigureDeviceParams({
    required super.id,
    required super.createdTime,
    required super.additionalInfo,
    required super.customerId,
    required super.label,
    required super.name,
    required super.ownerId,
    required super.tenantId,
    required super.type,
    required this.deviceData,
    required this.establishmentName,
    this.deviceProfileId,
    this.firmwareId,
    this.softwareId,
  });
}
