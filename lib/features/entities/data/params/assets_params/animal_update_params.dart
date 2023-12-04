import 'params.dart';

class AnimalUpdateParams extends AssetUpdateParams {
  final String parentName;
  final String animalType;
  final String category;
  final int birthday;
  final String race;
  final String batchName;

  AnimalUpdateParams(
      {required super.id,
      required super.createdTime,
      required super.name,
      required super.label,
      required super.customerId,
      required super.ownerId,
      required super.tenantId,
      required super.type,
      required super.assetProfileId,
      required this.parentName,
      required this.animalType,
      required this.category,
      required this.birthday,
      required this.race,
      required this.batchName})
      : super(additionalInfo: {
          "establishmentName": parentName,
          "batchName": batchName,
          "type": animalType,
          "category": category,
          "race": race,
          "birthday": birthday
        });
}
