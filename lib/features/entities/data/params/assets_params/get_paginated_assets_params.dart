class GetPaginatedAssetsParams {
  final List<String> types;
  final String? parentId;
  final int page;
  final int pageSize;
  final int? dateFilter;
  final String? search;

  GetPaginatedAssetsParams(
      {required this.types,
      required this.parentId,
      required this.page,
      required this.pageSize,
      this.dateFilter,
      this.search});
}
