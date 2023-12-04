import 'package:dio/dio.dart';

import '../../../../../core/exceptions/exception.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/http_client_helper.dart';
import '../../../../../features/entities/data/params/params.dart';
import '../params/create_user_params.dart';

typedef _UsersRequestFunction = Future<Response> Function();

class AdminUsersRemoteDataSource {
  final HttpClientHelper _httpClient;

  AdminUsersRemoteDataSource(this._httpClient);

  Future<dynamic> _usersRequest(
      _UsersRequestFunction userRequestFunction) async {
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

  Future<dynamic> getPagedUsers(SearchEntityParams params) =>
      _usersRequest(() => _httpClient.dio.get(
          '$kUsersService/users?page=${params.page}&pageSize=${params.pageSize}&textSearch=${params.search}'));

  Future<dynamic> getPagedUsersByCustomer(SearchEntityParams params) =>
      _usersRequest(() => _httpClient.dio.get(
          '$kCustomerService/${params.parentId}/users?page=${params.page}&pageSize=${params.pageSize}&textSearch=${params.search}'));

  Future<dynamic> getUser(String userId) => _usersRequest(
          () => _httpClient.dio.get('$kUsersService/$userId'));

  Future<Response> createUser(CreateUserParams params) async {
    Map<String, dynamic> map = {};
    if (params.id?.isNotEmpty ?? false) {
      map.addAll({
        'id': {'id': params.id, 'entityType': params.authority == kTenantAdminRole ? 'TENANT' : 'CUSTOMER'}
      });
    }
    if (params.tenantId?.isNotEmpty ?? false) {
      map.addAll({
        'tenantId': {'id': params.tenantId, 'entityType': 'TENANT'}
      });
    }
    if (params.customerId?.isNotEmpty ?? false) {
      map.addAll({
        'customerId': {'id': params.customerId, 'entityType': params.authority == kTenantAdminRole ? 'TENANT' : 'CUSTOMER'}
      });
    }
    if (params.ownerId?.isNotEmpty ?? false) {
      map.addAll({
        'ownerId': {'id': params.ownerId, 'entityType': params.authority == kTenantAdminRole ? 'TENANT' : 'CUSTOMER'}
      });
    }
    if (params.email?.isNotEmpty ?? false) {
      map.addAll({'email': params.email});
    }
    if (params.authority?.isNotEmpty ?? false) {
      map.addAll({'authority': params.authority});
    }
    if (params.firstName?.isNotEmpty ?? false) {
      map.addAll({'firstName': params.firstName});
    }
    if (params.lastName?.isNotEmpty ?? false) {
      map.addAll({'lastName': params.lastName});
    }
    return await _httpClient.dio.post('$kUsersService?sendActivationMail=${params.sendActivationMail}', data: map);
  }

  Future<dynamic> deleteUser(String userId) => _usersRequest(
          () => _httpClient.dio.delete('$kUsersService/$userId'));

  Future<dynamic> getActivationLink(String userId) => _usersRequest(
          () => _httpClient.dio.get('$kUsersService/$userId/activationLink'));

  Future<dynamic> sendActivationMail(String email) => _usersRequest(
          () => _httpClient.dio.get('$kUsersService/sendActivationMail?$email'));
}
