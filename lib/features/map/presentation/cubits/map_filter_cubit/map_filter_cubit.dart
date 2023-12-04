import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../entities/data/models/models.dart';
import '../../../../entities/data/params/params.dart';
import '../../../../entities/data/repositories/entities_repository.dart';
import '../../../../../core/exceptions/error_handler.dart';
import '../../../../../core/exceptions/exception.dart';
import '../../../../../core/utils/data_state.dart';

part 'map_filter_state.dart';

class MapFilterCubit extends Cubit<MapFilterState> {
  final EntitiesRepository _repository;

  MapFilterCubit(this._repository) : super(MapFilterInitial());

  void refreshMap() async {
    emit(MapFilterRefresh());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(MapFilterInitial());
  }

  void getEntities(
      {required List<String> assets,
      required List<String> devices,
      required String parentId}) async {
    emit(MapFilterLoading());
    late DataState response;
    bool error = false;
    List<EntityModel> items = [];
    if (assets.isNotEmpty) {
      SearchEntityParams assetsParams = SearchEntityParams(
          types: assets,
          parentId: parentId,
          entityType: 'ASSET',
          page: 0,
          pageSize: 1000);
      response = await _repository
          .getEntitiesAndLastValuesByParent(assetsParams);
      if (response is DataSuccess) {
        EntitiesSearchResponseModel assetsResponseModel =
            EntitiesSearchResponseModel.fromJson(response.data);
        items.addAll(
            assetsResponseModel.data.map((e) => e.toEntityModel()).toList());
      } else {
        error = true;
      }
    }
    if (devices.isNotEmpty && !error) {
      SearchEntityParams devicesParams = SearchEntityParams(
          types: devices,
          parentId: parentId,
          entityType: 'DEVICE',
          page: 0,
          pageSize: 1000);
      response = await _repository
          .getEntitiesAndLastValuesByParent(devicesParams);
      if (response is DataSuccess) {
        EntitiesSearchResponseModel devicesResponseModel =
            EntitiesSearchResponseModel.fromJson(response.data);
        items.addAll(
            devicesResponseModel.data.map((e) => e.toEntityModel()).toList());
      }
    }
    if (response is DataSuccess) {
      emit(MapFilterSuccess(items: items));
    }
    if (response is DataError) {
      if (response.error is UnauthorizedException) {
        emit(const MapFilterFail(message: 'sessionExpired'));
        return;
      }
      if (response.error is DioException) {
        final String errorStr =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
        emit(MapFilterFail(message: errorStr));
        return;
      }
      emit(const MapFilterFail(message: 'unknownError'));
    }
  }

  void itemSelected(EntityModel item) async {
    emit(MapFilterInitial());
    await Future.delayed(const Duration(milliseconds: 100));
    emit(MapFilterItemSelected(item: item));
  }
}
