import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/models/models.dart';
import '../../../../data/params/params.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'device_telemetry_state.dart';

class DeviceTelemetryCubit extends Cubit<DeviceTelemetryState> {
  final EntitiesRepository _devicesRepository;

  DeviceTelemetryCubit(this._devicesRepository)
      : super(DeviceTelemetryInitial());

  void refreshMap() async {
    emit(DeviceTelemetryRefresh());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(DeviceTelemetryInitial());
  }

  void getDeviceTelemetry(
      String deviceId, int startTs, int endTs, List<String> keys) async {
    emit(DeviceTelemetryLoading());
    GetTelemetryParams params = GetTelemetryParams(
        deviceId: deviceId, start: startTs, end: endTs, keys: keys);
    final response = await _devicesRepository.getDeviceTelemetry(params);
    if (response is DataSuccess) {
      Map<String, dynamic> telemetry = {};
      if ((response.data as Map).isNotEmpty) {
        for (var key in params.keys) {
          telemetry.addAll(
              {key: TimeseriesResponseModel.fromJson(response.data, key)});
        }
      }
      emit(DeviceTelemetrySuccess(telemetry: telemetry));
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
      emit(DeviceTelemetryFail(
        message: errorMessage,
      ));
    }
  }
}
