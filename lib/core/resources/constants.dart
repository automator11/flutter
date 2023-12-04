///  API constants
const kBaseUrl = 'https://api.trakeano.com/api';

const kObtainTokenService = '/auth/login';
const kRefreshTokenService = '/auth/token';
const kGetUserProfileService = '/auth/user';
const kChangePasswordService = '/auth/changePassword';
const kLogoutService = '/auth/logout';
const kResetPasswordService = '/noauth/resetPassword';
const kResetPasswordByEmailService = '/noauth/resetPasswordByEmail';

const kAssetsService = '/asset';
const kEntitiesQueryCountService = '/entitiesQuery/count';
const kUserAssetsService = '/user/assets';
const kAssetsTelemetryService = '/plugins/telemetry/ASSET/';
const kQueryAssetsService = '/assets';
const kEntitiesQueryFindService = '/entitiesQuery/find';
const kSchedulerService = '/schedulerEvent';
const kEntityGroupService = '/entityGroup/';
const kUserDevicesService = '/user/devices';
const kClaimDeviceService = '/customer/device/';
const kDeviceService = '/device';
const kDevicesService = '/devices';
const kDeviceTypesService = '/device/types';
const kDeviceGroups = '/entityGroups/DEVICE';
const kDevicesTelemetryService = '/plugins/telemetry/DEVICE/';
const kGetSchedulerEventsService = '/schedulerEvents';
const kAlertsService = '/alarms';
const kAlertService = '/alarm';
const kCustomerService = '/customer/';
const kAttributesService = '/plugins/telemetry/';

// Admin endpoints
const kCustomersService = '/customers';
const kCreateCustomerService = '/customer';
const kUsersService = '/user';

///  Other global constants
const kAccessTokenKey = 'token';
const kRefreshTokenKey = 'refreshToken';
const kUserIdKey = 'userId';
const kIsLoggedInKey = 'isLoggedIn';
const kCurrentEstablishmentKey = 'currentEstablishment';

/// Assets constants
const kEstablishmentTypeKey = 'Establecimiento';
const kGatewayTypeKey = 'Gateway';
const kPaddockTypeKey = 'Parcela';
const kWaterFontTypeKey = 'Aguada';
const kShadowTypeKey = 'Sombra';
const kBatchTypeKey = 'Lote';
const kRotationTypeKey = 'Rotacion';
const kAnimalTypeKey = 'Animal';
const Map<String, String> kAssetsProfiles = {
  'Establecimiento': 'f5172e20-a0e7-11ed-bd83-0953c8671281',
  'Gateway': 'a37442e0-a940-11ed-a021-dd5d507ec163',
  'Parcela': 'eb9075c0-a2ca-11ed-a021-dd5d507ec163',
  'Aguada': '171061f0-a2ea-11ed-a021-dd5d507ec163',
  'Sombra': '00f6ba90-a2ea-11ed-a021-dd5d507ec163',
  'Lote': '289f02f0-a2ea-11ed-a021-dd5d507ec163',
  'Rotacion': '3a1bf0b0-a2ea-11ed-a021-dd5d507ec163',
  'Animal': '33c0ef90-a86c-11ed-a021-dd5d507ec163'
};
const kWaterFontTypeGroupId = '68ee5b70-a868-11ed-a021-dd5d507ec163';
const kBatchTypeGroupId = '78f41190-a7af-11ed-a021-dd5d507ec163';
const kAnimalRaceGroupId = 'f3e31c30-9b5b-11ed-b267-c574002d3922';
const kAnimalCategoryGroupId = 'eceb3480-9b5b-11ed-b267-c574002d3922';
const kAvailablePaddocksName = 'AvailableParcels';
const kAvailableBatchesName = 'AvailableLots';
const kAvailableAnimalsName = 'AvailableAnimals';

/// Devices constants
const kWaterLevelType = 'WaterLevel';
const kControllerType = 'Controller';
const kTempAndHumidityType = 'TempAndHumidity';
const kEarTagType = 'EarTag';
const Map<String, String> kDevicesProfiles = {
  kWaterLevelType: 'fd5627b0-b1f1-11ed-a021-dd5d507ec163',
  kControllerType: '78aa5250-b2bb-11ed-a021-dd5d507ec163',
  kTempAndHumidityType: 'd14155b0-b68c-11ed-a021-dd5d507ec163',
  kEarTagType: '3c2fd080-f4c3-11ed-a021-dd5d507ec163'
};
const kDevicesSensorGroupName = 'Sensors';

// Prefs constants
const kEnableNotifications = 'enableNotifications';
const kSelectedEstablishment = 'selectedEstablishment';
const kActiveUserKey = 'activeUser';

// Roles

const kTenantAdminRole = 'TENANT_ADMIN';
const kCustomerRole = 'CUSTOMER_USER';
