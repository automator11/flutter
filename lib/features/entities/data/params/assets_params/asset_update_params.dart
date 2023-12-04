import '../common_params/params.dart';

class AssetUpdateParams extends EntityUpdateParams {
  final String? assetProfileId;

  AssetUpdateParams(
      {required super.id,
      required super.createdTime,
      required super.name,
      required super.label,
      required super.customerId,
      required super.ownerId,
      required super.tenantId,
      required super.additionalInfo,
      required super.type,
      required this.assetProfileId});
}
