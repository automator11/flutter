import 'package:flutter/material.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/utils/utils.dart';

class AssetDeviceInfoWidget extends StatelessWidget {
  final String? type;
  final String? deviceData;

  const AssetDeviceInfoWidget({super.key, this.type, this.deviceData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 110,
      child: Column(
        children: [
          SizedBox(
            height: 60,
            width: 70,
            child: Utils.getDeviceIcon(type),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            constraints: const BoxConstraints.expand(height: 30),
            decoration: BoxDecoration(
                color: kPrimaryColor, borderRadius: BorderRadius.circular(4)),
            child: Center(
              child: Text(
                deviceData ?? 'noData',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
