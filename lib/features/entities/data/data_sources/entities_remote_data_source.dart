import 'package:dio/dio.dart';

import '../../../../core/exceptions/exception.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/utils/http_client_helper.dart';
import '../params/params.dart';

typedef _EntitiesRequestFunction = Future<Response> Function();

class EntitiesRemoteDataSource {
  final HttpClientHelper _httpClient;

  EntitiesRemoteDataSource(this._httpClient);

  Future<dynamic> _assetRequest(
      _EntitiesRequestFunction assetRequestFunction) async {
    try {
      final response = await assetRequestFunction();
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

  Future<dynamic> getEstablishments(GetEstablishmentsParams params) =>
      _assetRequest(() => _httpClient.dio.get(
            kUserAssetsService,
            queryParameters: {
              'type': kEstablishmentTypeKey,
              'page': params.page,
              'pageSize': params.pageSize,
              'textSearch': params.search
            },
          ));

  Future<dynamic> getEstablishmentAvailableArea(String id) =>
      _assetRequest(() => _httpClient.dio.get(
            '$kAssetsTelemetryService/$id/values/attributes?keys=availableArea',
          ));

  Future<dynamic> createAsset(AssetCreateParams params) =>
      _assetRequest(() => _httpClient.dio.post(
            kAssetsService,
            data: {
              "tenantId": {"id": params.tenantId, "entityType": "TENANT"},
              "customerId": {"id": params.customerId, "entityType": "CUSTOMER"},
              "name": params.name.toLowerCase(),
              "type": params.type,
              "label": params.name,
              "assetProfileId": {
                "id": params.assetProfileId,
                "entityType": "ASSET_PROFILE"
              },
              "additionalInfo": params.additionalInfo,
              "ownerId": {"id": params.ownerId, "entityType": "CUSTOMER"}
            },
          ));

  Future<dynamic> getAssets(GetAssetsParams params) => _assetRequest(() {
        Map<String, dynamic> queryBody = {
          "relationType": "Contains",
          "assetTypes": params.types,
          "parameters": {
            "rootId": params.parentId,
            "rootType": "ASSET",
            "direction": "FROM",
            "relationTypeGroup": "COMMON",
            "maxLevel": 0,
            "fetchLastLevelOnly": false
          }
        };
        return _httpClient.dio.post(
          kQueryAssetsService,
          data: queryBody,
        );
      });

  Future<dynamic> getPaginatedAssets(GetPaginatedAssetsParams params) =>
      _assetRequest(() {
        Map<String, dynamic> body = {
          "entityFields": [
            {"type": "ENTITY_FIELD", "key": "id"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "tenantId"},
            {"type": "ENTITY_FIELD", "key": "customerId"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "name"},
            {"type": "ENTITY_FIELD", "key": "additionalInfo"},
            {"type": "ENTITY_FIELD", "key": "label"},
            {"type": "ENTITY_FIELD", "key": "type"},
            {"type": "ENTITY_FIELD", "key": "ownerId"},
            {"type": "ENTITY_FIELD", "key": "assetProfileId"}
          ],
          "entityFilter": {
            "type": "assetSearchQuery",
            "rootEntity": {"entityType": "ASSET", "id": params.parentId},
            "direction": "FROM",
            "maxLevel": 1,
            "fetchLastLevelOnly": false,
            "relationType": "Contains",
            "assetTypes": params.types
          },
          "pageLink": {
            "page": params.page,
            "pageSize": params.pageSize,
            "sortOrder": {
              "key": {"key": "name", "type": "ENTITY_FIELD"},
              "direction": "ASC"
            }
          }
        };
        if (params.types.contains(kRotationTypeKey) &&
            params.dateFilter != null) {
          body.addAll({
            "keyFilters": [
              {
                "key": {"type": "ATTRIBUTE", "key": "startDate"},
                "valueType": "NUMERIC",
                "predicate": {
                  "operation": "LESS_OR_EQUAL",
                  "value": {
                    "defaultValue": params.dateFilter,
                    "dynamicValue": null
                  },
                  "type": "NUMERIC"
                }
              },
              {
                "key": {"type": "ATTRIBUTE", "key": "endDate"},
                "valueType": "NUMERIC",
                "predicate": {
                  "operation": "GREATER_OR_EQUAL",
                  "value": {
                    "defaultValue": params.dateFilter,
                    "dynamicValue": null
                  },
                  "type": "NUMERIC"
                }
              }
            ],
          });
        }
        if (params.search != null) {
          body.addAll({
            "keyFilters": [
              {
                "key": {"type": "ENTITY_FIELD", "key": "label"},
                "valueType": "STRING",
                "predicate": {
                  "operation": "CONTAINS",
                  "value": {
                    "defaultValue": params.search,
                    "dynamicValue": null
                  },
                  "type": "STRING"
                }
              }
            ],
          });
        }
        return _httpClient.dio.post(
          kEntitiesQueryFindService,
          data: body,
        );
      });

  Future<dynamic> searchAssetsByParent(SearchEntityParams params) =>
      _assetRequest(() {
        Map<String, dynamic> body = {
          "entityFields": [
            {"type": "ENTITY_FIELD", "key": "id"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "tenantId"},
            {"type": "ENTITY_FIELD", "key": "customerId"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "name"},
            {"type": "ENTITY_FIELD", "key": "additionalInfo"},
            {"type": "ENTITY_FIELD", "key": "label"},
            {"type": "ENTITY_FIELD", "key": "type"},
            {"type": "ENTITY_FIELD", "key": "ownerId"},
            {"type": "ENTITY_FIELD", "key": "assetProfileId"}
          ],
          "entityFilter": {
            "type": "relationsQuery",
            "rootEntity": {"entityType": "ASSET", "id": params.parentId},
            "direction": "FROM",
            "maxLevel": 1,
            "fetchLastLevelOnly": false,
            "filters": [
              {
                "relationType": "Contains",
                "entityTypes": params.types ?? ["ASSET"]
              }
            ]
          },
          "keyFilters": [
            {
              "key": {"type": "ENTITY_FIELD", "key": "label"},
              "valueType": "STRING",
              "predicate": {
                "operation": "CONTAINS",
                "value": {"defaultValue": params.search, "dynamicValue": null},
                "type": "STRING"
              }
            }
          ],
          "pageLink": {
            "page": params.page,
            "pageSize": params.pageSize,
            "sortOrder": {
              "key": {"key": "name", "type": "ENTITY_FIELD"},
              "direction": "ASC"
            }
          }
        };
        return _httpClient.dio.post(
          kEntitiesQueryFindService,
          data: body,
        );
      });

  Future<dynamic> searchAssetsByGroupName(SearchEntityParams params) =>
      _assetRequest(() {
        Map<String, dynamic> body = {
          "entityFields": [
            {"type": "ENTITY_FIELD", "key": "id"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "tenantId"},
            {"type": "ENTITY_FIELD", "key": "customerId"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "name"},
            {"type": "ENTITY_FIELD", "key": "additionalInfo"},
            {"type": "ENTITY_FIELD", "key": "label"},
            {"type": "ENTITY_FIELD", "key": "type"},
            {"type": "ENTITY_FIELD", "key": "ownerId"},
            {"type": "ENTITY_FIELD", "key": "assetProfileId"}
          ],
          "entityFilter": {
            "type": "entitiesByGroupName",
            "groupType": "ASSET",
            "entityGroupNameFilter": params.search
          },
          "pageLink": {
            "page": params.page,
            "pageSize": params.pageSize,
            "sortOrder": {
              "key": {"key": "name", "type": "ENTITY_FIELD"},
              "direction": "ASC"
            }
          }
        };
        return _httpClient.dio.post(
          kEntitiesQueryFindService,
          data: body,
        );
      });

  Future<dynamic> updateAsset(AssetUpdateParams params) =>
      _assetRequest(() => _httpClient.dio.post(kAssetsService, data: {
            "id": {"entityType": "ASSET", "id": params.id},
            "createdTime": params.createdTime,
            "name": params.name.toLowerCase(),
            "label": params.name,
            "type": params.type,
            "assetProfileId": {
              "id": params.assetProfileId,
              "entityType": "ASSET_PROFILE"
            },
            "additionalInfo": params.additionalInfo,
            "ownerId": {"id": params.ownerId, "entityType": "CUSTOMER"},
            "customerId": {"entityType": "CUSTOMER", "id": params.customerId}
          }));

  Future<dynamic> deleteAsset(String id) =>
      _assetRequest(() => _httpClient.dio.delete('$kAssetsService/$id'));

  Future<dynamic> checkAssetRelations(String id) => _assetRequest(() {
        Map<String, dynamic> body = {
          "entityFilter": {
            "type": "relationsQuery",
            "rootEntity": {"entityType": "ASSET", "id": id},
            "direction": "FROM",
            "maxLevel": 1,
            "fetchLastLevelOnly": false,
            "filters": [
              {
                "relationType": "Contains",
                "entityTypes": ["ASSET"]
              }
            ]
          }
        };
        return _httpClient.dio.post(
          kEntitiesQueryCountService,
          data: body,
        );
      });

  Future<dynamic> getAssetsByGroupId(String groupId) =>
      _assetRequest(() => _httpClient.dio
          .get('$kEntityGroupService/$groupId/assets?page=0&pageSize=100'));

  Future<dynamic> findBatchesRelatedRotationsByDate(
          FindBatchRelatedRotationsParams params) =>
      _assetRequest(() {
        Map<String, dynamic> body = {
          "entityFields": [
            {"type": "ENTITY_FIELD", "key": "id"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "tenantId"},
            {"type": "ENTITY_FIELD", "key": "customerId"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "name"},
            {"type": "ENTITY_FIELD", "key": "additionalInfo"},
            {"type": "ENTITY_FIELD", "key": "label"},
            {"type": "ENTITY_FIELD", "key": "type"},
            {"type": "ENTITY_FIELD", "key": "ownerId"},
            {"type": "ENTITY_FIELD", "key": "assetProfileId"}
          ],
          "entityFilter": {
            "type": "assetSearchQuery",
            "rootEntity": {"entityType": "ASSET", "id": params.batchId},
            "direction": "FROM",
            "maxLevel": 1,
            "fetchLastLevelOnly": false,
            "relationType": "Contains",
            "assetTypes": ["Rotacion"]
          },
          "keyFilters": [
            {
              "key": {"type": "ENTITY_FIELD", "key": "additionalInfo"},
              "valueType": "STRING",
              "predicate": {
                "operation": "CONTAINS",
                "value": {
                  "defaultValue": params.batchName,
                  "dynamicValue": null
                },
                "type": "STRING"
              }
            }
          ],
          "pageLink": {
            "page": 0,
            "pageSize": 100,
            "sortOrder": {
              "key": {"key": "name", "type": "ENTITY_FIELD"},
              "direction": "ASC"
            }
          }
        };
        return _httpClient.dio.post(
          kEntitiesQueryFindService,
          data: body,
        );
      });

  Future<dynamic> searchAssetsByName(String name) => _assetRequest(() {
        Map<String, dynamic> body = {
          "entityFields": [
            {"type": "ENTITY_FIELD", "key": "id"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "tenantId"},
            {"type": "ENTITY_FIELD", "key": "customerId"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "name"},
            {"type": "ENTITY_FIELD", "key": "additionalInfo"},
            {"type": "ENTITY_FIELD", "key": "label"},
            {"type": "ENTITY_FIELD", "key": "type"},
            {"type": "ENTITY_FIELD", "key": "ownerId"},
            {"type": "ENTITY_FIELD", "key": "assetProfileId"}
          ],
          "entityFilter": {
            "type": "entityName",
            "entityType": "ASSET",
            "entityNameFilter": name
          },
          "pageLink": {
            "page": 0,
            "pageSize": 10,
            "sortOrder": {
              "key": {"key": "name", "type": "ENTITY_FIELD"},
              "direction": "ASC"
            }
          }
        };
        return _httpClient.dio.post(
          kEntitiesQueryFindService,
          data: body,
        );
      });

  Future<dynamic> claimDevice(ClaimDeviceParams params) =>
      _assetRequest(() => _httpClient.dio.post(
        '$kClaimDeviceService${params.name}/claim',
        data: {'secretKey': params.secretKey},
      ));

  Future<dynamic> getDeviceTypes() => _assetRequest(() => _httpClient.dio.get(
    kDeviceTypesService,
  ));

  Future<dynamic> getPagedDevices(GetDevicesParams params) =>
      _assetRequest(() => _httpClient.dio.get(
        kUserDevicesService,
        queryParameters: {
          'page': params.page,
          'pageSize': params.pageSize,
          'type': params.type,
          'textSearch': params.search
        },
      ));

  Future<dynamic> getEntitiesAndLastValuesByParent(SearchEntityParams params) =>
      _assetRequest(() {
        Map<String, dynamic> body = {
          "entityFields": [
            {"type": "ENTITY_FIELD", "key": "id"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "tenantId"},
            {"type": "ENTITY_FIELD", "key": "customerId"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "name"},
            {"type": "ENTITY_FIELD", "key": "additionalInfo"},
            {"type": "ENTITY_FIELD", "key": "label"},
            {"type": "ENTITY_FIELD", "key": "type"},
            {"type": "ENTITY_FIELD", "key": "ownerId"},
            {"type": "ENTITY_FIELD", "key": "assetProfileId"}
          ],
          "pageLink": {
            "page": params.page,
            "pageSize": params.pageSize,
            "sortOrder": {
              "key": {"key": "name", "type": "ENTITY_FIELD"},
              "direction": "ASC"
            }
          }
        };
        if (params.entityType == "ASSET") {
          body.addAll({
            "entityFilter": {
              "type": "assetSearchQuery",
              "rootEntity": {"entityType": "ASSET", "id": params.parentId},
              "direction": "FROM",
              "maxLevel": 1,
              "fetchLastLevelOnly": false,
              "relationType": "Contains",
              "assetTypes": params.types
            }
          });
        }
        if (params.entityType == "DEVICE") {
          body.addAll({
            "entityFilter": {
              "type": "deviceSearchQuery",
              "rootEntity": {"entityType": "ASSET", "id": params.parentId},
              "direction": "FROM",
              "maxLevel": 2,
              "fetchLastLevelOnly": true,
              "relationType": "Contains",
              "deviceTypes": params.types
            }
          });
          body.addAll({
            "latestValues": [
              {"type": "TIME_SERIES", "key": "temperature"},
              {"type": "TIME_SERIES", "key": "humidity"},
              {"type": "TIME_SERIES", "key": "latitude"},
              {"type": "TIME_SERIES", "key": "longitude"}
            ],
          });
        }
        return _httpClient.dio.post(
          kEntitiesQueryFindService,
          data: body,
        );
      });

  Future<dynamic> searchDevicesByParent(SearchEntityParams params) =>
      _assetRequest(() {
        Map<String, dynamic> body = {
          "entityFields": [
            {"type": "ENTITY_FIELD", "key": "id"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "tenantId"},
            {"type": "ENTITY_FIELD", "key": "customerId"},
            {"type": "ENTITY_FIELD", "key": "createdTime"},
            {"type": "ENTITY_FIELD", "key": "name"},
            {"type": "ENTITY_FIELD", "key": "additionalInfo"},
            {"type": "ENTITY_FIELD", "key": "label"},
            {"type": "ENTITY_FIELD", "key": "type"},
            {"type": "ENTITY_FIELD", "key": "ownerId"},
            {"type": "ENTITY_FIELD", "key": "assetProfileId"}
          ],
          "latestValues": [
            {"type": "TIME_SERIES", "key": "temperature"},
            {"type": "TIME_SERIES", "key": "humidity"},
            {"type": "TIME_SERIES", "key": "latitude"},
            {"type": "TIME_SERIES", "key": "longitude"},
            {"type": "TIME_SERIES", "key": "level"},
            {"type": "TIME_SERIES", "key": "vBat"},
            {"type": "TIME_SERIES", "key": "actStatus"},
            {"type": "ATTRIBUTE", "key": "waitingRpcCommandAck"},
          ],
          "entityFilter": {
            "type": "deviceSearchQuery",
            "rootEntity": {"entityType": "ASSET", "id": params.parentId},
            "direction": "FROM",
            "maxLevel": 2,
            "fetchLastLevelOnly": true,
            "relationType": "Contains",
            "deviceTypes": params.types
          },
          "keyFilters": [
            {
              "key": {"type": "ENTITY_FIELD", "key": "name"},
              "valueType": "STRING",
              "predicate": {
                "operation": "CONTAINS",
                "value": {"defaultValue": params.search, "dynamicValue": null},
                "type": "STRING"
              }
            }
          ],
          "pageLink": {
            "page": params.page,
            "pageSize": params.pageSize,
            "sortOrder": {
              "key": {"key": "name", "type": "ENTITY_FIELD"},
              "direction": "ASC"
            }
          }
        };
        return _httpClient.dio.post(
          kEntitiesQueryFindService,
          data: body,
        );
      });

  Future<dynamic> getDevicesByParent(SearchEntityParams params) =>
      _assetRequest(() {
        Map<String, dynamic> queryBody = {
          "relationType": "Contains",
          "deviceTypes": params.types,
          "parameters": {
            "rootId": params.parentId,
            "rootType": "ASSET",
            "direction": "FROM",
            "relationTypeGroup": "COMMON",
            "maxLevel": 0,
            "fetchLastLevelOnly": false
          }
        };
        return _httpClient.dio.post(
          kDevicesService,
          data: queryBody,
        );
      });

  Future<dynamic> configureDevice(ConfigureDeviceParams params) =>
      _assetRequest(() => _httpClient.dio.post(kDeviceService, data: {
        "id": {"id": params.id, "entityType": "DEVICE"},
        "tenantId": {"id": params.tenantId, "entityType": "TENANT"},
        "customerId": {"id": params.customerId, "entityType": "CUSTOMER"},
        "ownerId": {"id": params.ownerId, "entityType": "CUSTOMER"},
        "name": params.name,
        "type": params.type,
        "label": params.label,
        "createdTime": params.createdTime,
        "deviceData": params.deviceData,
        "additionalInfo": params.additionalInfo
      }));

  Future<dynamic> removeDevice(String deviceName) =>
      _assetRequest(() => _httpClient.dio.delete(
        '$kClaimDeviceService$deviceName/claim',
      ));

  Future<dynamic> getDevice(String deviceId) =>
      _assetRequest(() => _httpClient.dio.get(
        '$kDeviceService/$deviceId',
      ));

  Future<dynamic> getDeviceGroups() =>
      _assetRequest(() => _httpClient.dio.get(kDeviceGroups));

  Future<dynamic> getDevicesByGroupId(String groupId) =>
      _assetRequest(() => _httpClient.dio
          .get('$kEntityGroupService/$groupId/devices?page=0&pageSize=100'));

  Future<dynamic> getDeviceTelemetryKeys(String deviceId) =>
      _assetRequest(() => _httpClient.dio
          .get('$kDevicesTelemetryService$deviceId/keys/timeseries'));

  Future<dynamic> getDeviceLastTelemetry(String deviceId) =>
      _assetRequest(() => _httpClient.dio.get(
          '$kDevicesTelemetryService$deviceId/values/timeseries?useStrictDataTypes=true'));

  Future<dynamic> getDeviceTelemetry(GetTelemetryParams params) {
    String keysStr = '';
    // comma-separated timeseries keys
    for (var i = 0; i < params.keys.length; i++) {
      keysStr +=
      i == params.keys.length - 1 ? params.keys[i] : '${params.keys[i]},';
    }
    return _assetRequest(() => _httpClient.dio.get(
        '$kDevicesTelemetryService${params.deviceId}/values/timeseries',
        queryParameters: {
          'keys': keysStr,
          'startTs': params.start,
          'endTs': params.end
        }));
  }

  Future<dynamic> saveDeviceAttributes(SaveAttributesParams params) =>
      _assetRequest(() => _httpClient.dio.post(
          '$kAttributesService${params.deviceId}/SERVER_SCOPE',
          data: params.toJson()));

  Future<dynamic> getDeviceAttributes(String deviceId) =>
      _assetRequest(() => _httpClient.dio.get(
        '$kDevicesTelemetryService$deviceId/values/attributes',
      ));
}
