import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/models/models.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'device_types_state.dart';

class DeviceTypesCubit extends Cubit<DeviceTypesState> {
  final EntitiesRepository _devicesRepository;

  DeviceTypesCubit(this._devicesRepository) : super(DeviceTypesInitial());

  void getDeviceTypes() async {
    emit(DeviceTypesLoading());
    final response = await _devicesRepository.getDeviceTypes();
    if (response is DataSuccess) {
      emit(DeviceTypesSuccess(
          types:
              DeviceTypesResponseModel.fromJson({'data': response.data}).data));
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
      emit(DeviceTypesFail(
        message: errorMessage,
      ));
    }
  }
}
