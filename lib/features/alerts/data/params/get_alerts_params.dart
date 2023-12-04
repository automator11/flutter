class GetAlertsParams {
  final String? searchStatus;
  final String? status;
  final int pageSize;
  final int page;
  final String textSearch;

  GetAlertsParams(
      {this.searchStatus,
      this.status,
      required this.pageSize,
      required this.page,
      required this.textSearch});
}
