import 'package:dio/dio.dart';

import '../../../../../core/exceptions/exception.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/http_client_helper.dart';
import '../../../../../features/entities/data/params/params.dart';

typedef _DevicesAdminRequestFunction = Future<Response> Function();

class DevicesAdminRemoteDataSource {
  final HttpClientHelper _httpClient;

  DevicesAdminRemoteDataSource(this._httpClient);

  Future<dynamic> _devicesAdminRequest(
      _DevicesAdminRequestFunction devicesRequestFunction) async {
    try {
      final response = await devicesRequestFunction();
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

  Future<dynamic> getPagedDevices(SearchEntityParams params) =>
      _devicesAdminRequest(() => _httpClient.dio.get(
        kUserDevicesService,
        queryParameters: {
          'page': params.page,
          'pageSize': params.pageSize,
          'textSearch': params.search
        },
      ));

  Future<dynamic> getPagedDevicesByCustomer(SearchEntityParams params) =>
      _devicesAdminRequest(() => _httpClient.dio.get(
          '$kCustomerService${params.parentId}/devices?page=${params.page}&pageSize=${params.pageSize}&textSearch=${params.search}'));

  Future<dynamic> claimDeviceToCustomer(String customerId, ClaimDeviceParams params) => _devicesAdminRequest(
          () => _httpClient.dio.get('${kCustomerService}device/${params.name}/claim?$customerId'));
}
