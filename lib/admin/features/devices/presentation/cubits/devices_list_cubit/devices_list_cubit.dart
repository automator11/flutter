import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../../../features/entities/data/models/models.dart';
import '../../../../../../features/entities/data/params/params.dart';
import '../../../data/repositories/devices_admin_repository.dart';

part 'devices_list_state.dart';

class DevicesListCubit extends Cubit<DevicesListState> {
  final DevicesAdminRepository _devicesAdminRepository;

  DevicesListCubit(this._devicesAdminRepository) : super(DevicesListInitial());

  int? _pageKey;
  List<EntityModel> _items = [];

  void getPagedDevices(SearchEntityParams params) async {
    emit(DevicesListInitial());
    final response = await _devicesAdminRepository.getPagedDevices(params);
    if (response is DataSuccess) {
      EntitiesResponseModel devicesResponseModel =
          EntitiesResponseModel.fromJson(response.data);
      final newItems = devicesResponseModel.data;
      final totalCount = devicesResponseModel.totalElements;
      if (params.page == 0) {
        _items = [];
      }
      _items.addAll(newItems);
      final isLastPage = _items.length == totalCount!;
      _pageKey = isLastPage ? null : (_pageKey ?? 0) + 1;
      emit(DevicesListNewPage(
        error: null,
        pageKey: _pageKey,
        items: _items,
        total: totalCount,
        pageSize: params.pageSize,
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
      emit(DevicesListNewPage(
          error: errorMessage,
          pageKey: _pageKey,
          items: _items,
          total: _items.length));
    }
  }
}
