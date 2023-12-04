import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/params/params.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'device_last_telemetry_state.dart';

class DeviceLastTelemetryCubit extends Cubit<DeviceLastTelemetryState> {
  final EntitiesRepository _devicesRepository;

  DeviceLastTelemetryCubit(this._devicesRepository)
      : super(DeviceLastTelemetryInitial());

  void refreshMap() async {
    emit(DeviceLastTelemetryRefresh());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(DeviceLastTelemetryInitial());
  }

  void getDeviceLastTelemetry(String deviceId) async {
    emit(DeviceLastTelemetryLoading());
    String errorMsg = '';
    Map<String, dynamic> telemetry = {};
    List<dynamic> attributes = [];

    // get telemetry
    DataState response =
        await _devicesRepository.getDeviceLastTelemetry(deviceId);
    if (response is DataSuccess) {
      telemetry = response.data as Map<String, dynamic>;
    }
    if (response is DataError) {
      String errorMessage = 'unknownError'.tr();
      if (response.error is UnauthorizedException) {
        errorMessage = 'sessionExpired'.tr();
      } else if (response.error is DioException) {
        errorMessage =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
      }
      errorMsg = '${'gettingTelemetryError'.tr()}: $errorMessage\n';
    }

    // get attributes
    response = await _devicesRepository.getDeviceAttributes(deviceId);
    if (response is DataSuccess) {
      attributes = response.data as List;
    }
    if (response is DataError) {
      String errorMessage = 'unknownError'.tr();
      if (response.error is UnauthorizedException) {
        errorMessage = 'sessionExpired'.tr();
      } else if (response.error is DioException) {
        errorMessage =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
      }
      errorMsg += '${'gettingAttributesError'.tr()}: $errorMessage';
    }

    if (errorMsg.isEmpty) {
      emit(DeviceLastTelemetrySuccess(
          telemetry: telemetry, attributes: attributes));
      return;
    }
    emit(DeviceLastTelemetryFail(
      message: errorMsg,
    ));
  }

  void saveDeviceAttributes(SaveAttributesParams params) async {
    emit(DeviceLastTelemetryLoading());
    final response = await _devicesRepository.saveDeviceAttributes(params);
    if (response is DataSuccess) {
      emit(DeviceUpdateAttributesSuccess());
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
      emit(DeviceLastTelemetryFail(
        message: errorMessage,
      ));
    }
  }
}
