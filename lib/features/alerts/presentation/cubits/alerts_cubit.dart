import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/exceptions/error_handler.dart';
import '../../../../core/exceptions/exception.dart';
import '../../../../core/utils/data_state.dart';
import '../../data/models/models.dart';
import '../../data/params/params.dart';
import '../../data/repositories/repositories.dart';

part 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  final AlertsRepository _alertsRepository;

  AlertsCubit(this._alertsRepository) : super(AlertsInitial());

  final pageSize = 10;
  int? _pageKey;
  List<AlarmModel> _items = [];

  void getPagedAlerts(int page,
      {String status = '', String search = ''}) async {
    emit(AlertsInitial());
    final response = await _alertsRepository.getAlerts(GetAlertsParams(
        status: status, page: page, pageSize: 10, textSearch: search));
    if (response is DataSuccess) {
      AlarmsResponseModel alarmsResponseModel =
          AlarmsResponseModel.fromJson(response.data);
      final newItems = alarmsResponseModel.data;
      final totalCount = alarmsResponseModel.totalElements;
      if (page == 0) {
        _items = [];
      }
      _items.addAll(newItems);
      final isLastPage = _items.length == totalCount!;
      _pageKey = isLastPage ? null : (_pageKey ?? 0) + 1;
      emit(AlertsNewPage(error: null, pageKey: _pageKey, items: _items));
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
      emit(
          AlertsNewPage(error: errorMessage, pageKey: _pageKey, items: _items));
    }
  }

  void searchAlertsByStatus(String searchStatus) async {
    emit(AlertsLoading());
    final response = await _alertsRepository.getAlerts(GetAlertsParams(
        searchStatus: searchStatus, page: 0, pageSize: 100, textSearch: ''));
    if (response is DataSuccess) {
      AlarmsResponseModel responseModel =
          AlarmsResponseModel.fromJson(response.data);
      emit(AlertsSuccess(items: responseModel.data));
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
      emit(AlertsFail(
        message: errorMessage,
      ));
    }
  }

  void acknowledgeAlert(String id) async {
    emit(AlertsInitial());
    final response = await _alertsRepository.acknowledgeAlert(id);
    if (response is DataSuccess) {
      emit(AlertsAck());
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
      emit(AlertsFail(
        message: errorMessage,
      ));
    }
  }

  void deleteAlert(String id) async {
    emit(AlertsLoading());
    final response = await _alertsRepository.deleteAlert(id);
    if (response is DataSuccess) {
      emit(AlertsDeleted());
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
      emit(AlertsFail(
        message: errorMessage,
      ));
    }
  }

  void getDeviceAlert(String id) async {
    emit(AlertsLoading());
    final response = await _alertsRepository.getDeviceAlert(id);
    if (response is DataSuccess) {
      AlarmsResponseModel responseModel =
          AlarmsResponseModel.fromJson(response.data);
      emit(AlertsSuccess(items: responseModel.data));
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
      emit(AlertsFail(
        message: errorMessage,
      ));
    }
  }
}
