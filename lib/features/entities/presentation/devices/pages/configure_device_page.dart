import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../widgets/widgets.dart';

class ConfigureDevicePage extends StatelessWidget {
  final EntityModel? device;
  final Map<String, dynamic>? batchInfo;
  final bool fromTable;

  const ConfigureDevicePage(
      {super.key, this.device, this.batchInfo, this.fromTable = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: kPrimaryBackground,
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          ConfigureDeviceContainer(
            device: device,
            batchInfo: batchInfo,
          ),
          Positioned(
              top: 8,
              right: 8,
              child: SizedBox(
                height: 25,
                width: 25,
                child: CircleButton(
                  onTap: () {
                    context.goNamed(kMapPageRoute);
                  },
                  icon: const Icon(
                    Ionicons.close_outline,
                    color: kIconLightColor,
                    size: 18,
                  ),
                ),
              )),
          Positioned(
              top: 8,
              left: 8,
              child: SizedBox(
                height: 25,
                width: 25,
                child: CircleButton(
                  onTap: () {
                    if (fromTable) {
                      context.goNamed(kTableDevicesPageRoute,
                          queryParameters: {'type': device?.type ?? ''});
                    } else {
                      context.pop();
                    }
                  },
                  icon: const Icon(
                    Ionicons.chevron_back_outline,
                    color: kIconLightColor,
                    size: 18,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
