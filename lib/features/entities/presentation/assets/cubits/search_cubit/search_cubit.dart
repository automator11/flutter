import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/models/models.dart';
import '../../../../data/params/params.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final EntitiesRepository _assetsRepository;

  SearchCubit(this._assetsRepository) : super(SearchInitial());

  final int pageSize = 10;
  int? _pageKey;
  List<EntitySearchModel> _items = [];

  void searchAsset(String parentId, String searchQuery) async {
    emit(SearchStart(parentId: parentId, searchQuery: searchQuery));
  }

  void getPagedSearch(int page, String searchQuery, String parentId) async {
    SearchEntityParams params = SearchEntityParams(
        parentId: parentId,
        search: searchQuery,
        page: page,
        pageSize: pageSize,
        types: ["ASSET", "DEVICE"]);
    final response = await _assetsRepository.searchAssetsByParent(params);
    if (response is DataSuccess) {
      EntitiesSearchResponseModel entitiesResponseModel =
          EntitiesSearchResponseModel.fromJson(response.data);
      final newItems = entitiesResponseModel.data;
      final totalCount = entitiesResponseModel.totalElements;
      if (page == 0) {
        _items = [];
      }
      _items.addAll(newItems);
      final isLastPage = _items.length == totalCount!;
      _pageKey = isLastPage ? null : (_pageKey ?? 0) + 1;
      emit(SearchNewPage(error: null, pageKey: _pageKey, page: _items));
      return;
    }
    if (response is DataError) {
      String errorMessage = 'unknownError';
      if (response.error is UnauthorizedException) {
        errorMessage = 'sessionExpired';
      } else if (response.error is DioException) {
        errorMessage =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
      }
      emit(SearchNewPage(error: errorMessage, pageKey: _pageKey, page: _items));
    }
  }

  void resetSuggestions() {
    emit(SearchInitial());
  }
}
