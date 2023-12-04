part of 'list_assets_cubit.dart';

abstract class ListAssetsState extends Equatable {
  const ListAssetsState();

  @override
  List<Object> get props => [];
}

class ListAssetsInitial extends ListAssetsState {}

class ListAssetsNewPage extends ListAssetsState {
  final String? error;
  final int? pageKey;
  final List<EntitySearchModel> items;
  final int? total;
  final int? pageSize;

  const ListAssetsNewPage(
      {required this.items,
      this.error,
      this.pageKey,
      this.pageSize,
      this.total});

  @override
  List<Object> get props => [items];
}

class ListAssetsLoading extends ListAssetsState {}
class ListAssetsDeleteLoading extends ListAssetsState {}

class ListAssetsSuccess extends ListAssetsState {}

class ListAssetsFail extends ListAssetsState {
  final String message;

  const ListAssetsFail({required this.message});

  @override
  List<Object> get props => [message];
}
