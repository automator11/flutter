class EntityUpdateParams {
  String id;
  int createdTime;
  String name;
  String label;
  String tenantId;
  String customerId;
  String ownerId;
  Map<String, dynamic> additionalInfo;
  String type;

  EntityUpdateParams(
      {required this.id,
      required this.createdTime,
      required this.name,
      required this.label,
      required this.customerId,
      required this.ownerId,
      required this.tenantId,
      required this.additionalInfo,
      required this.type});
}
