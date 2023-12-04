part of 'search_cubit.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchStart extends SearchState {
  final String searchQuery;
  final String parentId;

  const SearchStart({required this.parentId, required this.searchQuery});

  @override
  List<Object> get props => [parentId, searchQuery];
}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<EntitySearchModel> result;

  const SearchSuccess({required this.result});

  @override
  List<Object> get props => [result];
}

class SearchNewPage extends SearchState {
  final String? error;
  final int? pageKey;
  final List<EntitySearchModel> page;

  const SearchNewPage({required this.page, this.error, this.pageKey});

  @override
  List<Object> get props => [page];
}

class SearchFail extends SearchState {
  final String message;

  const SearchFail({required this.message});

  @override
  List<Object> get props => [message];
}
