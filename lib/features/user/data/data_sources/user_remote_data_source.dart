import 'package:dio/dio.dart';

import '../params/params.dart';
import '../../../../core/exceptions/exception.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/utils/http_client_helper.dart';

typedef _UserRequestFunction = Future<Response> Function();

class UserRemoteDataSource {
  final HttpClientHelper _httpClient;

  UserRemoteDataSource(this._httpClient);

  Future<dynamic> _userRequest(_UserRequestFunction userRequestFunction) async {
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

//  Authentication services

  // Future<Response> register(UserRegisterParams params) async {
  //   Map<String, dynamic> map = {
  //     'name': params.name,
  //     'lastname': params.lastName,
  //     'email': params.email,
  //     'password': params.password,
  //     'code': params.code
  //   };
  //   return await httpClient.post(kRegisterService, false, map);
  // }

  Future<dynamic> login(UserLoginParams? params) =>
      _userRequest(() => _httpClient.dio.post(
            kObtainTokenService,
            data: {'username': params?.email, 'password': params?.password},
          ));

  Future<dynamic> logOutUser() async {
    return _userRequest(() => _httpClient.dio.post(
          kLogoutService,
        ));
  }

  Future<dynamic> sendResetPasswordEmail(String email) =>
      _userRequest(() => _httpClient.dio
          .post(kResetPasswordByEmailService, data: {'email': email}));

  Future<dynamic> resetPassword(UserResetPasswordParams params) =>
      _userRequest(() => _httpClient.dio.post(
            kResetPasswordService,
            data: {
              "resetToken": params.code ?? '',
              "password": params.password ?? ''
            },
          ));

  // Future<dynamic> removeAccount() =>
  //     _clientRequest(() => _httpClient.dio.put(kRemoveAccountService, data: {}));

// User Services

  Future<dynamic> fetchUser() =>
      _userRequest(() => _httpClient.dio.get(kGetUserProfileService));

  Future<dynamic> fetchCustomer(String customerId) =>
      _userRequest(() => _httpClient.dio.get('$kCustomerService$customerId'));
  //
  // Future<Response> updateUser(UserUpdateParams params) async {
  //   Map<String, dynamic> map = {};
  //   if (params.name.isNotEmpty) {
  //     map.addAll({'name': params.name});
  //   }
  //   if (params.lastName.isNotEmpty) {
  //     map.addAll({'lastname': params.lastName});
  //   }
  //   if (params.userName.isNotEmpty) {
  //     map.addAll({'username': params.userName});
  //   }
  //   if (params.phone.isNotEmpty) {
  //     map.addAll({'phone': params.phone});
  //   }
  //   if (params.password.isNotEmpty) {
  //     map.addAll({'password': params.password});
  //   }
  //   return await httpClient.put(kEditUsersService, true, map);
  // }

  Future<dynamic> changePassword(UserChangePasswordParams params) =>
      _userRequest(() => _httpClient.dio.patch(kChangePasswordService, data: {
            'currentPassword': params.oldPassword,
            'newPassword': params.newPassword,
          }));
}
