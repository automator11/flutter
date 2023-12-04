class GetTelemetryParams {
  final String deviceId;
  final int start;
  final int end;
  final List<String> keys;

  const GetTelemetryParams(
      {required this.deviceId,
      required this.start,
      required this.end,
      required this.keys});
}
