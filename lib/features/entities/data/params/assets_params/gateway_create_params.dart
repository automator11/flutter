import 'params.dart';

class GatewayCreateParams extends AssetCreateParams {
  final String parentName;
  final String gatewayId;
  final Map<String, dynamic> position;

  GatewayCreateParams(
      {required super.name,
      required super.customerId,
      required super.label,
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
