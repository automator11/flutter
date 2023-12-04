import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/utils.dart';
import '../../../data/models/models.dart';

class EarTagAddedDialog extends StatelessWidget {
  final EntityModel device;

  const EarTagAddedDialog({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 30, 16.0, 16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            'deviceAdded',
            style: TextStyle(
                color: kSecondaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ).tr(),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: const Border.fromBorderSide(
                  BorderSide(color: kInputDefaultBorderColor)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 70,
                  child: Utils.getDeviceIcon(kAnimalTypeKey),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${'batch'.tr()}: ',
                          style: const TextStyle(
                              color: kSecondaryText, fontSize: 12)),
                      Text(device.additionalInfo?['batchName'] ?? '',
                          style: const TextStyle(
                              color: kSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('${'ID'.tr()}: ',
                          style: const TextStyle(
                              color: kSecondaryText, fontSize: 12)),
                      Text(device.label ?? '',
                          style: const TextStyle(
                              color: kSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'type'.tr()}: ',
                          style: const TextStyle(
                              color: kSecondaryText, fontSize: 12)),
                      Text(device.additionalInfo?['type'] ?? '',
                          style: const TextStyle(
                              color: kSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'category'.tr()}: ',
                          style: const TextStyle(
                              color: kSecondaryText, fontSize: 12)),
                      Text(device.additionalInfo?['category'] ?? '',
                          style: const TextStyle(
                              color: kSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'year'.tr()}: ',
                          style: const TextStyle(
                              color: kSecondaryText, fontSize: 12)),
                      Text(device.additionalInfo?['birthday']?.toString() ?? '',
                          style: const TextStyle(
                              color: kSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'race'.tr()}: ',
                          style: const TextStyle(
                              color: kSecondaryText, fontSize: 12)),
                      Text(device.additionalInfo?['race'] ?? '',
                          style: const TextStyle(
                              color: kSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: 120,
            child: CustomElevatedButton(
                borderRadius: 10,
                child: const Text('continue').tr(),
                onPressed: () {
                  Navigator.pop(context);
                }),
          )
        ]),
      ),
    );
  }
}
