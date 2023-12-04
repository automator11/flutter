import 'params.dart';

class GatewayUpdateParams extends AssetUpdateParams {
  final String parentName;
  final String gatewayId;
  final Map<String, dynamic> position;

  GatewayUpdateParams(
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
      required this.gatewayId,
      required this.position})
      : super(additionalInfo: {
          "establishmentName": parentName,
          "id": gatewayId,
          "position": position
        });
}
