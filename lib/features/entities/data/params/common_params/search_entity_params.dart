class SearchEntityParams {
  String? parentId;
  String? search;
  int? page;
  int? pageSize;
  List<String>? types;
  String? entityType;

  SearchEntityParams(
      {this.parentId,
      this.search,
      this.page,
      this.pageSize,
      this.types,
      this.entityType});
}
