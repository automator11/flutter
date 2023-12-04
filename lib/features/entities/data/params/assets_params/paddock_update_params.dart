import 'params.dart';

class PaddockUpdateParams extends AssetUpdateParams {
  final String parentName;
  final double totalArea;
  final double usableArea;
  final double beforeArea;
  final Map<String, dynamic> position;

  PaddockUpdateParams(
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
      required this.usableArea,
      required this.beforeArea,
      required this.position})
      : super(additionalInfo: {
          "establishmentName": parentName,
          "totalArea": totalArea,
          "usableArea": usableArea,
          "beforeArea": beforeArea,
          "position": position
        });
}
