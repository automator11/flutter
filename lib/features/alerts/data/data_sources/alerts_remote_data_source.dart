import 'package:dio/dio.dart';

import '../../../../core/exceptions/exception.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/utils/http_client_helper.dart';
import '../params/params.dart';

typedef _AlertsRequestFunction = Future<Response> Function();

class AlertsRemoteDataSource {
  final HttpClientHelper _httpClient;

  AlertsRemoteDataSource(this._httpClient);

  Future<dynamic> _alertsRequest(
      _AlertsRequestFunction alertsRequestFunction) async {
    try {
      final response = await alertsRequestFunction();
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
            response: response,
            requestOptions: response.requestOptions,
            type: DioExceptionType.badResponse,
            error: response.statusMessage);
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      rethrow;
    }
  }

  Future<dynamic> getAlerts(GetAlertsParams params) {
    Map<String, dynamic> queryParameters = {
      'page': params.page,
      'pageSize': params.pageSize,
      'textSearch': params.textSearch
    };
    if (params.searchStatus != null) {
      queryParameters.addAll({
        'searchStatus': params.searchStatus,
      });
    } else {
      queryParameters.addAll({
        'status': params.status ?? '',
      });
    }
    return _alertsRequest(() => _httpClient.dio.get(
          kAlertsService,
          queryParameters: queryParameters,
        ));
  }

  Future<dynamic> acknowledgeAlert(String alertId) =>
      _alertsRequest(() => _httpClient.dio.post(
            '$kAlertService/$alertId/ack',
          ));

  Future<dynamic> clearAlert(String alertId) =>
      _alertsRequest(() => _httpClient.dio.post(
            '$kAlertService/$alertId/clear',
          ));

  Future<dynamic> deleteAlert(String alertId) =>
      _alertsRequest(() => _httpClient.dio.delete(
            '$kAlertService/$alertId',
          ));

  Future<dynamic> getDeviceAlert(String entityId) => _alertsRequest(() =>
      _httpClient.dio.get('$kAlertService/DEVICE/$entityId',
          queryParameters: {'page': 0, 'pageSize': 100, 'textSearch': ""}));
}
