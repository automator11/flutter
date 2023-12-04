import 'params.dart';

class ShadowUpdateParams extends AssetUpdateParams {
  final String parentName;
  final double totalArea;
  final Map<String, dynamic> position;

  ShadowUpdateParams(
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
      required this.totalArea,
      required this.position})
      : super(additionalInfo: {
          "establishmentName": parentName,
          "totalArea": totalArea,
          "position": position
        });
}
