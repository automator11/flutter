import 'params.dart';

class PaddockCreateParams extends AssetCreateParams {
  final String parentName;
  final double totalArea;
  final double usableArea;
  final Map<String, dynamic> position;

  PaddockCreateParams(
      {required super.name,
      required super.customerId,
      required super.label,
      required super.ownerId,
      required super.tenantId,
      required super.type,
      required super.assetProfileId,
      required this.parentName,
      required this.totalArea,
      required this.usableArea,
      required this.position})
      : super(additionalInfo: {
          "establishmentName": parentName,
          "totalArea": totalArea,
          "usableArea": usableArea,
          "position": position
        });
}
