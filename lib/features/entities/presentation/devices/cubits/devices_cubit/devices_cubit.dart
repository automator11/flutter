import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/resources/constants.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/models/models.dart';
import '../../../../data/params/params.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final EntitiesRepository _devicesRepository;

  DevicesCubit(this._devicesRepository) : super(DevicesInitial());

  int? _pageKey;
  List<EntityModel> _items = [];
  List<EntitySearchModel> _searchItems = [];

  void claimDevice(ClaimDeviceParams params) async {
    emit(DevicesLoading());
    final response = await _devicesRepository.claimDevice(params);
    if (response is DataSuccess) {
      EntityModel device = EntityModel.fromJson(response.data['device']);
      emit(GetDeviceSuccess(device: device));
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
      emit(DevicesFail(
        message: errorMessage,
      ));
    }
  }

  void getPagedDevices(int page, String search, String type) async {
    emit(DevicesInitial());
    GetDevicesParams params =
        GetDevicesParams(search: search, page: page, pageSize: 100, type: type);
    final response = await _devicesRepository.getPagedDevice(params);
    if (response is DataSuccess) {
      EntitiesResponseModel entitiesResponseModel =
          EntitiesResponseModel.fromJson(response.data);
      final newItems = entitiesResponseModel.data;
      final totalCount = entitiesResponseModel.totalElements;
      if (page == 0) {
        _items = [];
      }
      _items.addAll(newItems);
      final isLastPage = _items.length == totalCount!;
      _pageKey = isLastPage ? null : (_pageKey ?? 0) + 1;
      emit(DevicesNewPage(error: null, pageKey: _pageKey, devices: _items));
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
      emit(DevicesNewPage(
          error: errorMessage, pageKey: _pageKey, devices: _items));
    }
  }

  void getPagedDevicesByParent(
      int page, String? search, String type, String parentId,
      {int pageSize = 10}) async {
    emit(DevicesInitial());
    SearchEntityParams params = SearchEntityParams(
        search: search,
        page: page,
        pageSize: pageSize,
        types: [type],
        parentId: parentId);
    final response = await _devicesRepository.getPagedDevicesByParent(params);
    if (response is DataSuccess) {
      EntitiesSearchResponseModel entitiesResponseModel =
          EntitiesSearchResponseModel.fromJson(response.data);
      final newItems = entitiesResponseModel.data;
      final totalCount = entitiesResponseModel.totalElements;
      if (page == 0) {
        _searchItems = [];
      }
      _searchItems.addAll(newItems);
      final isLastPage = _searchItems.length == totalCount!;
      _pageKey = isLastPage ? null : (_pageKey ?? 0) + 1;
      emit(DevicesNewPage(
          error: null,
          pageKey: _pageKey,
          searchDevices: _searchItems,
          devices: const [],
          total: totalCount,
          pageSize: pageSize));
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
      emit(DevicesNewPage(
          error: errorMessage, pageKey: _pageKey, devices: _items));
    }
  }

  void configureDevice(ConfigureDeviceParams params) async {
    emit(DevicesLoading());
    final response = await _devicesRepository.configureDevice(params);
    if (response is DataSuccess) {
      emit(DevicesSuccess());
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
      emit(DevicesFail(
        message: errorMessage,
      ));
    }
  }

  void removeDevice(String deviceName) async {
    emit(DevicesLoading());
    final response = await _devicesRepository.removeDevice(deviceName);
    if (response is DataSuccess) {
      emit(DevicesSuccess());
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
      emit(DevicesFail(
        message: errorMessage,
      ));
    }
  }

  void getDevice(String id) async {
    emit(DevicesLoading());
    final response = await _devicesRepository.getDevice(id);
    if (response is DataSuccess) {
      emit(GetDeviceSuccess(device: EntityModel.fromJson(response.data)));
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
      emit(DevicesFail(
        message: errorMessage,
      ));
    }
  }

  void validateEarTagAnimal(String animalId) async {
    emit(DevicesLoading());
    final response = await _devicesRepository.getDevicesByParent(
        SearchEntityParams(parentId: animalId, types: [kEarTagType]));
    if (response is DataSuccess) {
      EntitiesResponseModel responseModel =
          EntitiesResponseModel.fromJson({'data': response.data});
      emit(DeviceValidationSuccess(relatedDevices: responseModel.data));
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
      emit(DevicesFail(
        message: errorMessage,
      ));
    }
  }

  void setDeviceClaimed(EntityModel device) {
    emit(DevicesInitial());
    Future.delayed(const Duration(milliseconds: 100));
    emit(GetDeviceSuccess(device: device));
  }
}
