import '../../../../core/utils/data_state.dart';
import '../data_sources/entities_remote_data_source.dart';
import '../params/params.dart';

typedef _ApiCallFunction = Future<dynamic> Function();

class EntitiesRepository {
  final EntitiesRemoteDataSource _apiService;

  EntitiesRepository(this._apiService);

  Future<DataState> _apiCall(_ApiCallFunction apiCallFunction) async {
    try {
      final json = await apiCallFunction();
      return DataSuccess(json);
    } on Exception catch (error) {
      return DataError(error);
    }
  }

  Future<DataState> createAsset(AssetCreateParams params) async {
    return _apiCall(() => _apiService.createAsset(params));
  }

  Future<DataState> getAssets(GetAssetsParams params) async {
    return _apiCall(() => _apiService.getAssets(params));
  }

  Future<DataState> getPaginatedAssets(GetPaginatedAssetsParams params) async {
    return _apiCall(() => _apiService.getPaginatedAssets(params));
  }

  Future<DataState> searchAssetsByParent(SearchEntityParams params) async {
    return _apiCall(() => _apiService.searchAssetsByParent(params));
  }

  Future<DataState> searchAssetsByGroupName(SearchEntityParams params) async {
    return _apiCall(() => _apiService.searchAssetsByGroupName(params));
  }

  Future<DataState> updateAsset(AssetUpdateParams params) async {
    return _apiCall(() => _apiService.updateAsset(params));
  }

  Future<DataState> deleteAsset(String id) async {
    return _apiCall(() => _apiService.deleteAsset(id));
  }

  Future<DataState> checkAssetRelations(String id) async {
    return _apiCall(() => _apiService.checkAssetRelations(id));
  }

  Future<DataState> getEstablishments(GetEstablishmentsParams params) async {
    return _apiCall(() => _apiService.getEstablishments(params));
  }

  Future<DataState> getEstablishmentAvailableArea(String id) async {
    return _apiCall(() => _apiService.getEstablishmentAvailableArea(id));
  }

  Future<DataState> getAssetsByGroupId(String groupId) async {
    return _apiCall(() => _apiService.getAssetsByGroupId(groupId));
  }

  Future<DataState> findBatchesRelatedRotationsByDate(
      FindBatchRelatedRotationsParams params) async {
    return _apiCall(
        () => _apiService.findBatchesRelatedRotationsByDate(params));
  }

  Future<DataState> searchAssetByName(String name) async {
    return _apiCall(() => _apiService.searchAssetsByName(name));
  }

  Future<DataState> claimDevice(ClaimDeviceParams params) async {
    return _apiCall(() => _apiService.claimDevice(params));
  }

  Future<DataState> getPagedDevicesByParent(SearchEntityParams params) async {
    return _apiCall(() => _apiService.searchDevicesByParent(params));
  }

  Future<DataState> getPagedDevice(GetDevicesParams params) async {
    return _apiCall(() => _apiService.getPagedDevices(params));
  }

  Future<DataState> getDevicesByParent(SearchEntityParams params) async {
    return _apiCall(() async {
      final response = await _apiService.getDevicesByParent(params);
      return response;
    });
  }

  Future<DataState> configureDevice(ConfigureDeviceParams params) async {
    return _apiCall(() => _apiService.configureDevice(params));
  }

  Future<DataState> removeDevice(String deviceName) async {
    return _apiCall(() => _apiService.removeDevice(deviceName));
  }

  Future<DataState> getDeviceTypes() async {
    return _apiCall(() => _apiService.getDeviceTypes());
  }

  Future<DataState> getDevice(String deviceId) async {
    return _apiCall(() => _apiService.getDevice(deviceId));
  }

  Future<DataState> getDeviceGroups() async {
    return _apiCall(() => _apiService.getDeviceGroups());
  }

  Future<DataState> getDevicesByGroupId(String groupId) async {
    return _apiCall(() => _apiService.getDevicesByGroupId(groupId));
  }

  Future<DataState> getDeviceTelemetryKeys(String deviceId) async {
    return _apiCall(() => _apiService.getDeviceTelemetryKeys(deviceId));
  }

  Future<DataState> getDeviceLastTelemetry(String deviceId) async {
    return _apiCall(() => _apiService.getDeviceLastTelemetry(deviceId));
  }

  Future<DataState> getEntitiesAndLastValuesByParent(
      SearchEntityParams params) async {
    return _apiCall(() => _apiService.getEntitiesAndLastValuesByParent(params));
  }

  Future<DataState> getDeviceTelemetry(GetTelemetryParams params) async {
    return _apiCall(() => _apiService.getDeviceTelemetry(params));
  }

  Future<DataState> saveDeviceAttributes(SaveAttributesParams params) async {
    return _apiCall(() => _apiService.saveDeviceAttributes(params));
  }

  Future<DataState> getDeviceAttributes(String deviceId) async {
    return _apiCall(() => _apiService.getDeviceAttributes(deviceId));
  }
}
