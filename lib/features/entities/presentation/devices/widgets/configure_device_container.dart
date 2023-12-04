import 'package:flutter/material.dart';

import '../../../../../core/resources/constants.dart';
import '../../../data/models/models.dart';
import '../pages/pages.dart';

class ConfigureDeviceContainer extends StatelessWidget {
  final EntityModel? device;
  final Map<String, dynamic>? batchInfo;
  const ConfigureDeviceContainer({super.key,this.device, this.batchInfo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (device?.type == kWaterLevelType)
              ConfigureWaterLevelPage(device: device!),
            if (device?.type == kTempAndHumidityType)
              ConfigureTempHumPage(device: device!),
            if (device?.type == kControllerType)
              ConfigureControllerPage(device: device!),
            if (device?.type == kEarTagType)
              ConfigureEarTagPage(
                device: device!,
                batchInfo: batchInfo,
              ),
          ],
        ),
      ),
    );
  }
}
