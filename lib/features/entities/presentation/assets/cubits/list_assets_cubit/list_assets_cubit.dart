import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/resources/constants.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/models/models.dart';
import '../../../../data/params/params.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'list_assets_state.dart';

class ListAssetsCubit extends Cubit<ListAssetsState> {
  final EntitiesRepository _assetsRepository;

  ListAssetsCubit(this._assetsRepository) : super(ListAssetsInitial());

  int? _pageKey;
  List<EntitySearchModel> _items = [];

  void getPagedAssets(int page, String type, String parentId,
      {int? dateFilter, String? search, int pageSize = 50}) async {
    emit(ListAssetsInitial());
    final response = await _assetsRepository.getPaginatedAssets(
        GetPaginatedAssetsParams(
            types: [type],
            parentId: parentId,
            page: page,
            pageSize: pageSize,
            dateFilter: dateFilter,
            search: search));
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
      emit(ListAssetsNewPage(
        error: null,
        pageKey: _pageKey,
        items: _items,
        total: totalCount,
        pageSize: pageSize,
      ));
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
      emit(ListAssetsNewPage(
          error: errorMessage,
          pageKey: _pageKey,
          items: _items,
          total: _items.length));
    }
  }

  void getAssets(String type, String parentId,
      {int? dateFilter, String? search, int page = 0, int pageSize = 3}) async {
    emit(ListAssetsLoading());
    final response = await _assetsRepository.getPaginatedAssets(
        GetPaginatedAssetsParams(
            types: [type],
            parentId: parentId,
            page: page,
            pageSize: pageSize,
            dateFilter: dateFilter,
            search: search));
    if (response is DataSuccess) {
      EntitiesSearchResponseModel entitiesResponseModel =
          EntitiesSearchResponseModel.fromJson(response.data);
      final newItems = entitiesResponseModel.data;
      emit(ListAssetsNewPage(error: null, pageKey: _pageKey, items: newItems));
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
      emit(ListAssetsNewPage(
          error: errorMessage, pageKey: _pageKey, items: _items));
    }
  }

  void deleteAsset(String id, {String? type}) async {
    emit(ListAssetsDeleteLoading());
    late DataState response;
    bool delete = true;
    if (type == kPaddockTypeKey || type == kBatchTypeKey) {
      delete = false;
      response = await _assetsRepository.checkAssetRelations(id);
      if (response is DataSuccess) {
        delete = response.data as int == 0;
        if (!delete) {
          emit(ListAssetsFail(
            message: 'containsRelatedAssets'.tr(namedArgs: {'type': type!}),
          ));
        }
      }
    }
    if (delete) {
      response = await _assetsRepository.deleteAsset(id);
      if (response is DataSuccess) {
        emit(ListAssetsSuccess());
        return;
      }
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
      emit(ListAssetsFail(
        message: errorMessage,
      ));
    }
  }
}
