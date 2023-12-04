class GetDevicesParams {
  final int page;
  final int pageSize;
  final String type;
  final String search;

  GetDevicesParams(
      {required this.page,
      required this.pageSize,
      required this.type,
      required this.search});
}
