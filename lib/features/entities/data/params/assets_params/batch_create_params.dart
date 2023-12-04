import 'params.dart';

class BatchCreateParams extends AssetCreateParams {
  final String parentName;
  final String lotType;
  final String lotCategory;
  final int birthday;
  final String lotRace;
  final int totalAnimals;

  BatchCreateParams(
      {required super.name,
      required super.label,
      required super.customerId,
      required super.ownerId,
      required super.tenantId,
      required super.type,
      super.assetProfileId,
      required this.parentName,
      required this.lotType,
      required this.lotCategory,
      required this.birthday,
      required this.lotRace,
      required this.totalAnimals})
      : super(additionalInfo: {
          "establishmentName": parentName,
          "lotType": lotType,
          "lotCategory": lotCategory,
          "birthday": birthday,
          "lotRace": lotRace,
          "totalAnimals": totalAnimals
        });
}
