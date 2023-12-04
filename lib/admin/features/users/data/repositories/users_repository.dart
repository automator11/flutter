import '../../../../../core/utils/data_state.dart';
import '../../../../../features/entities/data/params/params.dart';
import '../data_sources/users_remote_data_source.dart';
import '../params/create_user_params.dart';

typedef _ApiCallFunction = Future<dynamic> Function();

class UsersRepository {
  final AdminUsersRemoteDataSource _apiService;

  const UsersRepository(this._apiService);

  Future<DataState> _apiCall(_ApiCallFunction apiCallFunction) async {
    try {
      final json = await apiCallFunction();
      return DataSuccess(json);
    } on Exception catch (error) {
      return DataError(error);
    }
  }

  Future<DataState> getPagedUsers(SearchEntityParams params) async {
    return _apiCall(() => params.parentId != null
        ? _apiService.getPagedUsersByCustomer(params)
        : _apiService.getPagedUsers(params));
  }

  Future<DataState> getUser(String userId) async {
    return _apiCall(() => _apiService.getUser(userId));
  }

  Future<DataState> createUser(CreateUserParams params) async {
    return _apiCall(() => _apiService.createUser(params));
  }

  Future<DataState> deleteUser(String userId) async {
    return _apiCall(() => _apiService.deleteUser(userId));
  }

  Future<DataState> getActivationLink(String userId) async {
    return _apiCall(() => _apiService.getActivationLink(userId));
  }

  Future<DataState> sendActivationMail(String email) async {
    return _apiCall(() => _apiService.sendActivationMail(email));
  }
}
