import 'params.dart';

class ConfigureEarTagParams extends ConfigureDeviceParams {
  final Map<String, dynamic> currentInfo;
  final String animalId;
  final String? batchId;
  final String? batchName;

  ConfigureEarTagParams(
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
      required this.animalId,
      this.batchId,
      this.batchName})
      : super(
            additionalInfo: currentInfo
              ..addAll({
                "animalId": animalId,
                "batchId": batchId,
                "batchName": batchName
              })
              ..addAll({'establishmentName': establishmentName}));
}
