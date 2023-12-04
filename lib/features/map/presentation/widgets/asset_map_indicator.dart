import 'package:flutter/material.dart';



import '../../../../core/resources/constants.dart';

class AssetMapIndicator extends StatelessWidget {
  final String? assetType;
  final String? animalCategory;

  const AssetMapIndicator({super.key, this.assetType, this.animalCategory})
      : assert(assetType != kAnimalTypeKey && animalCategory == null);

  @override
  Widget build(BuildContext context) {
    if (assetType == kAnimalTypeKey || assetType == kEarTagType) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
                BorderSide(width: 2.0, color: _getColor()[1])),
            color: _getColor().first),
      );
    }
    return Image.asset(
      _getAssetImage(),
      height: 40,
      width: 40,
    );
  }

  List<Color> _getColor() {
    return [Colors.red, Colors.white];
  }

  String _getAssetImage() {
    switch (assetType) {
      case kEstablishmentTypeKey:
        return 'assets/icons/default_map_indicator.png';
      case kWaterLevelType:
        return 'assets/icons/water_level_map_indicator.png';
      case kTempAndHumidityType:
        return 'assets/icons/temp_hum_map_indicator.png';
      case kGatewayTypeKey:
        return 'assets/icons/gateway_map_indicator.png';
      case kControllerType:
        return 'assets/icons/controller_map_indicator.png';
      default:
        return 'assets/icons/default_map_indicator.png';
    }
  }
}
