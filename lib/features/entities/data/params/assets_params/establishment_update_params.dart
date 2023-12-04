import 'params.dart';

class EstablishmentUpdateParams extends AssetUpdateParams {
  final double area;
  final Map<String, dynamic> mainHousePosition;
  final Map<String, dynamic> position;

  EstablishmentUpdateParams(
      {required super.id,
      required super.createdTime,
      required super.name,
      required super.label,
      required super.customerId,
      required super.ownerId,
      required super.tenantId,
      required super.type,
      required super.assetProfileId,
      required this.area,
      required this.mainHousePosition,
      required this.position})
      : super(additionalInfo: {
          "totalArea": area,
          "position": position,
          "mainHousePosition": mainHousePosition
        });
}
