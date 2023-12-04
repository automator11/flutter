import '../../../../../core/utils/data_state.dart';
import '../../../../../features/entities/data/params/params.dart';
import '../data_sources/devices_admin_remote_data_source.dart';

typedef _ApiCallFunction = Future<dynamic> Function();

class DevicesAdminRepository {
  final DevicesAdminRemoteDataSource _apiService;

  const DevicesAdminRepository(this._apiService);

  Future<DataState> _apiCall(_ApiCallFunction apiCallFunction) async {
    try {
      final json = await apiCallFunction();
      return DataSuccess(json);
    } on Exception catch (error) {
      return DataError(error);
    }
  }

  Future<DataState> getPagedDevices(SearchEntityParams params) async {
    return _apiCall(() => params.parentId != null
        ? _apiService.getPagedDevicesByCustomer(params)
        : _apiService.getPagedDevices(params));
  }

  Future<DataState> claimDeviceToCustomer(
      String customerId, ClaimDeviceParams params) async {
    return _apiCall(
        () => _apiService.claimDeviceToCustomer(customerId, params));
  }
}
