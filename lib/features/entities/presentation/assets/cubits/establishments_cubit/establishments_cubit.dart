import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/models/models.dart';
import '../../../../data/params/params.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'establishments_state.dart';

class EstablishmentsCubit extends Cubit<EstablishmentsState> {
  final EntitiesRepository _assetsRepository;

  EstablishmentsCubit(this._assetsRepository) : super(EstablishmentsInitial());

  int? _pageKey;
  String _search = '';

  void getPagedEstablishments(int page) async {
    emit(EstablishmentsListLoading());
    GetEstablishmentsParams params =
        GetEstablishmentsParams(search: _search, page: page, pageSize: 100);
    final response = await _assetsRepository.getEstablishments(params);
    if (response is DataSuccess) {
      EntitiesResponseModel entitiesResponseModel =
          EntitiesResponseModel.fromJson(response.data);
      emit(EstablishmentsNewPage(
          error: null,
          pageKey: _pageKey,
          establishments: entitiesResponseModel.data));
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
      emit(EstablishmentsFail(message: errorMessage));
    }
  }

  void searchEstablishments(String search) async {
    _search = search;
    refresh();
    getPagedEstablishments(0);
  }

  void createEstablishment(EstablishmentCreateParams params) async {
    emit(EstablishmentsLoading());
    final response = await _assetsRepository.createAsset(params);
    if (response is DataSuccess) {
      emit(EstablishmentsCreated());
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
      emit(EstablishmentsFail(
        message: errorMessage,
      ));
    }
  }

  void updateEstablishment(EstablishmentUpdateParams params) async {
    emit(EstablishmentsLoading());
    final response = await _assetsRepository.updateAsset(params);
    if (response is DataSuccess) {
      emit(EstablishmentsSuccess(establishmentId: params.id));
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
      emit(EstablishmentsFail(
        message: errorMessage,
      ));
    }
  }

  void deleteEstablishment(String id) async {
    emit(EstablishmentsLoading());
    late DataState response;
    bool delete = false;
    response = await _assetsRepository.checkAssetRelations(id);
    if (response is DataSuccess) {
      delete = response.data as int == 0;
      if (!delete) {
        emit(EstablishmentsFail(
          message: 'establishmentContainsRelatedAssets'.tr(),
        ));
      }
    }
    if (delete) {
      response = await _assetsRepository.deleteAsset(id);
      if (response is DataSuccess) {
        emit(EstablishmentsSuccess(establishmentId: id));
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
      emit(EstablishmentsFail(
        message: errorMessage,
      ));
    }
  }

  void refresh() {
    _pageKey = 0;
  }
}
