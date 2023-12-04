import '../params/params.dart';
import '../../../../core/utils/data_state.dart';
import '../../../../core/resources/constants.dart';
import '../data_sources/user_remote_data_source.dart';

typedef _ApiCallFunction = Future<dynamic> Function();

class UserRepository {
  final UserRemoteDataSource _apiService;

  const UserRepository(this._apiService);

  Future<DataState> _apiCall(_ApiCallFunction apiCallFunction) async {
    try {
      final json = await apiCallFunction();
      return DataSuccess(json);
    } on Exception catch (error) {
      return DataError(error);
    }
  }

  Future<DataState> login(UserLoginParams? params) async {
    return _apiCall(() => _apiService.login(params));
  }

  Future<DataState> getUser() async {
    return _apiCall(() => _apiService.fetchUser());
  }

  Future<DataState> getCustomer(String customerId) async {
    return _apiCall(() => _apiService.fetchCustomer(customerId));
  }

  Future<DataState> verifyToken(String token) async {
    // return _apiCall(() => _apiService.verifyToken(token));

    await Future.delayed(const Duration(seconds: 3));
    return const DataSuccess({kAccessTokenKey: 'access'});
  }

  Future<DataState> changePassword(UserChangePasswordParams params) {
    return _apiCall(() => _apiService.changePassword(params));
  }

  Future<DataState> resetPassword(UserResetPasswordParams params) {
    return _apiCall(() => _apiService.resetPassword(params));
  }

  Future<DataState> sendResetPasswordEmail(String email) {
    return _apiCall(() => _apiService.sendResetPasswordEmail(email));
  }

  Future<DataState> logout() {
    return _apiCall(() => _apiService.logOutUser());
  }

  // Future<DataState> register(UserRegisterParams? params) {
  //   // TODO: implement register
  //   throw UnimplementedError();
  // }
}
