import 'params.dart';

class WaterFontUpdateParams extends AssetUpdateParams {
  final String parentName;
  final double volume;
  final String waterFontType;
  final Map<String, dynamic> position;

  WaterFontUpdateParams(
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
      required this.volume,
      required this.waterFontType,
      required this.position})
      : super(additionalInfo: {
          "establishmentName": parentName,
          "volume": volume,
          "type": waterFontType,
          "position": position
        });
}
