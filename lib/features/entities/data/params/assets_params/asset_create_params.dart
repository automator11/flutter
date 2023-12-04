import '../params.dart';

class AssetCreateParams extends EntityCreateParams {
  final String? assetProfileId;

  AssetCreateParams(
      {required super.name,
      required super.label,
      required super.customerId,
      required super.ownerId,
      required super.tenantId,
      required super.additionalInfo,
      required super.type,
      required this.assetProfileId});
}
