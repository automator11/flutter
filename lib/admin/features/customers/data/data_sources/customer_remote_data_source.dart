import 'package:dio/dio.dart';
import 'package:trackeano_web_app/admin/features/customers/data/params/create_customer_params.dart';
import 'package:trackeano_web_app/core/resources/constants.dart';
import 'package:trackeano_web_app/features/entities/data/params/params.dart';

import '../../../../../core/exceptions/exception.dart';
import '../../../../../core/utils/http_client_helper.dart';

typedef _CustomerRequestFunction = Future<Response> Function();

class CustomerRemoteDataSource {
  final HttpClientHelper _httpClient;

  CustomerRemoteDataSource(this._httpClient);

  Future<dynamic> _customerRequest(
      _CustomerRequestFunction userRequestFunction) async {
    try {
      final response = await userRequestFunction();
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

  Future<dynamic> getPagedCustomers(SearchEntityParams params) =>
      _customerRequest(() => _httpClient.dio.get(
          '$kCustomersService?page=${params.page}&pageSize=${params.pageSize}&textSearch=${params.search}'));

  Future<dynamic> getCustomer(String customerId) => _customerRequest(
      () => _httpClient.dio.get('$kCustomerService$customerId'));

  Future<Response> createCustomer(CreateCustomerParams params) async {
    Map<String, dynamic> map = {};
    if (params.id?.isNotEmpty ?? false) {
      map.addAll({
        'id': {'id': params.id, 'entityType': 'CUSTOMER'}
      });
    }
    if (params.tenantId?.isNotEmpty ?? false) {
      map.addAll({
        'tenantId': {'id': params.id, 'entityType': 'TENANT'}
      });
    }
    if (params.title.isNotEmpty) {
      map.addAll({'title': params.title});
    }
    if (params.customerId?.isNotEmpty ?? false) {
      map.addAll({
        'customerId': {'id': params.customerId, 'entityType': 'CUSTOMER'}
      });
    }
    if (params.ownerId?.isNotEmpty ?? false) {
      map.addAll({
        'ownerId': {'id': params.ownerId, 'entityType': 'TENANT'}
      });
    }
    if (params.country?.isNotEmpty ?? false) {
      map.addAll({'country': params.country});
    }
    if (params.state?.isNotEmpty ?? false) {
      map.addAll({'state': params.state});
    }
    if (params.city?.isNotEmpty ?? false) {
      map.addAll({'city': params.city});
    }
    if (params.address?.isNotEmpty ?? false) {
      map.addAll({'address': params.address});
    }
    if (params.address2?.isNotEmpty ?? false) {
      map.addAll({'address2': params.address2});
    }
    if (params.zip?.isNotEmpty ?? false) {
      map.addAll({'zip': params.zip});
    }
    if (params.phone?.isNotEmpty ?? false) {
      map.addAll({'phone': params.phone});
    }
    if (params.email?.isNotEmpty ?? false) {
      map.addAll({'email': params.email});
    }
    return await _httpClient.dio.post(kCreateCustomerService, data: map);
  }

  Future<dynamic> deleteCustomer(String customerId) => _customerRequest(
      () => _httpClient.dio.delete('$kCustomerService$customerId'));
}
