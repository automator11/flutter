import 'params.dart';

class ShadowCreateParams extends AssetCreateParams {
  final String parentName;
  final double totalArea;
  final Map<String, dynamic> position;

  ShadowCreateParams(
      {required super.name,
      required super.customerId,
      required super.label,
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
