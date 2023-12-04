import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:trackeano_web_app/admin/features/customers/data/models/models.dart';

import '../../../../../../admin/features/customers/data/repositories/customer_repository.dart';
import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/resources/constants.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/models/models.dart';
import '../../../../data/params/params.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'dropdown_state.dart';

class DropdownCubit extends Cubit<DropdownState> {
  final EntitiesRepository _repository;
  final CustomerRepository _customerRepository;

  DropdownCubit(this._repository, this._customerRepository)
      : super(DropdownInitial());

  void getAssetsByGroupId(String groupId) async {
    emit(DropdownLoading(groupType: groupId));
    final response = await _repository.getAssetsByGroupId(groupId);
    if (response is DataSuccess) {
      EntitiesResponseModel entitiesResponseModel =
          EntitiesResponseModel.fromJson(response.data);
      emit(DropdownSuccess(
          items: entitiesResponseModel.data, groupType: groupId));
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
      emit(DropdownFail(message: errorMessage, groupType: groupId));
    }
  }

  void getAssetsByGroupName(String name) async {
    emit(DropdownLoading(groupType: name));
    SearchEntityParams params =
        SearchEntityParams(parentId: '', search: name, page: 0, pageSize: 100);
    final response = await _repository.searchAssetsByGroupName(params);
    if (response is DataSuccess) {
      EntitiesSearchResponseModel entitiesResponseModel =
          EntitiesSearchResponseModel.fromJson(response.data);
      emit(DropdownSuccess(
          searchItems: entitiesResponseModel.data, groupType: name));
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
      emit(DropdownFail(message: errorMessage, groupType: name));
    }
  }

  void getAssetsByParentId(String parentId, String assetType,
      {String? searchQuery}) async {
    emit(DropdownLoading(groupType: assetType));
    GetPaginatedAssetsParams params = GetPaginatedAssetsParams(
        parentId: parentId,
        types: [assetType],
        search: searchQuery,
        page: 0,
        pageSize: 100);
    final response = await _repository.getPaginatedAssets(params);
    if (response is DataSuccess) {
      EntitiesSearchResponseModel entitiesResponseModel =
          EntitiesSearchResponseModel.fromJson(response.data);
      emit(DropdownSuccess(
          searchItems: entitiesResponseModel.data, groupType: assetType));
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
      emit(DropdownFail(message: errorMessage, groupType: assetType));
    }
  }

  void getSensors() async {
    emit(const DropdownLoading(groupType: 'sensors'));
    DataState response = await _repository.getDeviceGroups();
    EntityGroupModel? sensorsGroup;
    if (response is DataSuccess) {
      EntityGroupsResponseModel groupsResponseModel =
          EntityGroupsResponseModel.fromJson({'data': response.data});
      for (EntityGroupModel group in groupsResponseModel.data) {
        if (group.name == kDevicesSensorGroupName) {
          sensorsGroup = group;
        }
      }
    }
    if (sensorsGroup != null) {
      response =
          await _repository.getDevicesByGroupId(sensorsGroup.id.id);
      if (response is DataSuccess) {
        EntitiesResponseModel entitiesResponseModel =
            EntitiesResponseModel.fromJson(response.data);
        emit(DropdownSuccess(
            items: entitiesResponseModel.data, groupType: 'sensors'));
        return;
      }
    }
    if (sensorsGroup == null && response is DataSuccess) {
      emit(const DropdownSuccess(items: [], groupType: 'sensors'));
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
      emit(DropdownFail(message: errorMessage, groupType: 'sensors'));
    }
  }

  void getSensorVariables(String deviceId) async {
    emit(const DropdownLoading(groupType: 'telemetry'));
    final response = await _repository.getDeviceTelemetryKeys(deviceId);
    if (response is DataSuccess) {
      emit(DropdownSuccess(
          textItems: (response.data as List).map((e) => e.toString()).toList(),
          groupType: 'telemetry'));
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
      emit(DropdownFail(message: errorMessage, groupType: 'telemetry'));
    }
  }

  void getEstablishments() async {
    emit(const DropdownLoading(groupType: kEstablishmentTypeKey));
    GetEstablishmentsParams params =
        GetEstablishmentsParams(search: '', page: 0, pageSize: 100);
    final response = await _repository.getEstablishments(params);
    if (response is DataSuccess) {
      EntitiesResponseModel entitiesResponseModel =
          EntitiesResponseModel.fromJson(response.data);
      emit(DropdownSuccess(
          items: entitiesResponseModel.data, groupType: kEstablishmentTypeKey));
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
      emit(DropdownFail(
          message: errorMessage, groupType: kEstablishmentTypeKey));
    }
  }

  void getCustomers() async {
    emit(const DropdownLoading(groupType: 'Customer'));
    SearchEntityParams params =
    SearchEntityParams(search: '', page: 0, pageSize: 100);
    final response = await _customerRepository.getPagedCustomers(params);
    if (response is DataSuccess) {
      CustomersResponseModel customersResponseModel =
      CustomersResponseModel.fromJson(response.data);
      emit(DropdownSuccess(
          customersItems: customersResponseModel.data, groupType: 'Customer'));
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
      emit(DropdownFail(
          message: errorMessage, groupType: 'Customer'));
    }
  }
}
