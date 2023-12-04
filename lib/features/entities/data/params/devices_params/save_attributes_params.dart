abstract class SaveAttributesParams {
  final String deviceId;

  const SaveAttributesParams({required this.deviceId});

  Map<String, dynamic> toJson();
}
