import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/routes/routes.dart';
import '../../config/themes/colors.dart';
import '../utils/destination.dart';
import 'constants.dart';

List<Destination> allDestinations = <Destination>[
  Destination(
    index: 0,
    path: kMapPageRoute,
    title: 'map',
    icon: SvgPicture.asset('assets/icons/map_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/map_accent.svg'),
  ),

  // Devices
  Destination(
    index: 1,
    path: kMapDevicesPageRoute,
    title: 'forehead',
    type: kEarTagType,
    icon: SvgPicture.asset('assets/icons/forehead_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/forehead_accent.svg'),
  ),
  Destination(
    index: 2,
    path: kMapDevicesPageRoute,
    title: 'waterLevels',
    type: kWaterLevelType,
    icon: SvgPicture.asset('assets/icons/water_level_white_icon.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/water_level_accent_icon.svg'),
  ),
  Destination(
    index: 3,
    path: kMapDevicesPageRoute,
    title: 'tempHum',
    type: kTempAndHumidityType,
    icon: SvgPicture.asset('assets/icons/temp_hum_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/tem_hum_accent.svg'),
  ),
  Destination(
    index: 4,
    path: kMapDevicesPageRoute,
    title: 'controllers',
    type: kControllerType,
    icon: SvgPicture.asset('assets/icons/controller_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/controller_accent.svg'),
  ),
  Destination(
    index: 5,
    path: kMapAssetsPageRoute,
    title: 'gateways',
    type: kGatewayTypeKey,
    icon: SvgPicture.asset('assets/icons/wifi_white_icon.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/wifi_accent_icon.svg'),
  ),

  // Animals management
  Destination(
    index: 6,
    path: kMapAssetsPageRoute,
    title: 'animals',
    type: kAnimalTypeKey,
    icon: SvgPicture.asset('assets/icons/cow_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/cow_accent.svg'),
  ),
  Destination(
    index: 7,
    path: kMapAssetsPageRoute,
    title: 'batches',
    type: kBatchTypeKey,
    icon: SvgPicture.asset('assets/icons/batch_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/batch_accent.svg'),
  ),
  Destination(
    index: 8,
    path: kMapAssetsPageRoute,
    title: 'rotations',
    type: kRotationTypeKey,
    icon: SvgPicture.asset('assets/icons/rotation_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/rotation_accent.svg'),
  ),

  // Establishment
  Destination(
    index: 9,
    path: kMapAssetsPageRoute,
    title: 'paddocks',
    type: kPaddockTypeKey,
    icon: SvgPicture.asset('assets/icons/paddock_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/paddock_accent.svg'),
  ),
  Destination(
    index: 10,
    path: kMapAssetsPageRoute,
    title: 'waterFonts',
    type: kWaterFontTypeKey,
    icon: SvgPicture.asset('assets/icons/water_level_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/water_level_icon.svg'),
  ),
  Destination(
    index: 11,
    path: kMapAssetsPageRoute,
    title: 'shadows',
    type: kShadowTypeKey,
    icon: SvgPicture.asset('assets/icons/shadow_outlined.svg'),
    selectedIcon: SvgPicture.asset('assets/icons/shadow_accent.svg'),
  ),
];

List<Destination> adminDestinations = <Destination>[
  const Destination(
    index: 0,
    path: kDashboardPageRoute,
    title: 'dashboard',
    icon: Icon(Ionicons.grid_outline, color: Colors.white,),
    selectedIcon: Icon(Ionicons.grid_outline, color: kPrimaryColor,),
  ),
  const Destination(
    index: 1,
    path: kAdminCustomersPageRoute,
    title: 'customers',
    icon: Icon(Ionicons.storefront_outline, color: Colors.white,),
    selectedIcon: Icon(Ionicons.storefront_outline, color: kPrimaryColor,),
  ),
  const Destination(
    index: 2,
    path: kAdminUsersPageRoute,
    title: 'users',
    icon: Icon(Ionicons.people_outline, color: Colors.white,),
    selectedIcon: Icon(Ionicons.people_outline, color: kPrimaryColor,),
  ),
  const Destination(
    index: 3,
    path: kAdminDevicesPageRoute,
    title: 'devices',
    icon: Icon(Ionicons.rocket_outline, color: Colors.white,),
    selectedIcon: Icon(Ionicons.rocket_outline, color: kPrimaryColor,),
  ),
];

