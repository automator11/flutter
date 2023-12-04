import '../../../../core/utils/data_state.dart';
import '../data_sources/alerts_remote_data_source.dart';
import '../params/params.dart';

typedef _ApiCallFunction = Future<dynamic> Function();

class AlertsRepository {
  final AlertsRemoteDataSource _apiService;

  AlertsRepository(this._apiService);

  Future<DataState> _apiCall(_ApiCallFunction apiCallFunction) async {
    try {
      final json = await apiCallFunction();
      return DataSuccess(json);
    } on Exception catch (error) {
      return DataError(error);
    }
  }

  Future<DataState> getAlerts(GetAlertsParams params) async {
    return _apiCall(() => _apiService.getAlerts(params));
  }

  Future<DataState> acknowledgeAlert(String alertId) async {
    return _apiCall(() => _apiService.acknowledgeAlert(alertId));
  }

  Future<DataState> clearAlert(String alertId) async {
    return _apiCall(() => _apiService.clearAlert(alertId));
  }

  Future<DataState> deleteAlert(String alertId) async {
    return _apiCall(() => _apiService.deleteAlert(alertId));
  }

  Future<DataState> getDeviceAlert(String deviceId) async {
    return _apiCall(() => _apiService.getDeviceAlert(deviceId));
  }
}
