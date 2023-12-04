import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../data/models/models.dart';

class AssetListTile extends StatelessWidget {
  final EntitySearchModel asset;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssetListTile(
      {super.key, required this.asset, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.latest.label,
                  style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
                const SizedBox(
                  height: 5,
                ),
                ..._getAssetInfo(),
                const SizedBox(
                  height: 35,
                ),
              ],
            ),
          ),
          Positioned(
              right: 16,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleButton(
                      onTap: onEdit,
                      backgroundColor: kPrimaryColor,
                      elevation: 0,
                      icon: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Ionicons.pencil_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  CircleButton(
                      onTap: onDelete,
                      backgroundColor: kSecondaryColor,
                      elevation: 0,
                      icon: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Ionicons.trash_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ))
                ],
              ))
        ],
      ),
    );
  }

  List<Widget> _getAssetInfo() {
    TextStyle style1 = const TextStyle(color: kSecondaryText, fontSize: 12);
    TextStyle style2 = const TextStyle(color: kSecondaryColor, fontSize: 12);
    Map<String, dynamic>? info = asset.latest.additionalInfo;
    if (info?.isEmpty ?? true) {
      return [];
    }
    switch (asset.latest.type) {
      case kGatewayTypeKey:
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gateway ID:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info!['id'], style: style2)
            ],
          )
        ];
      case kPaddockTypeKey:
        String usableAreaTxt = '--';
        String totalAreaTxt = '--';
        double? usableArea = double.tryParse(info!['usableArea']?.toString() ?? '');
        double? totalArea = double.tryParse(info['totalArea']?.toString() ?? '');
        if (usableArea != null) {
          usableAreaTxt = usableArea.toStringAsFixed(2);
        }
        if (totalArea != null) {
          totalAreaTxt = totalArea.toStringAsFixed(2);
        }
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'usableArea'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text('$usableAreaTxt ha', style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'totalArea'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text('$totalAreaTxt ha', style: style2)
            ],
          )
        ];
      case kWaterFontTypeKey:
        String volumeTxt = '--';
        double? volume = double.tryParse(info!['volume']?.toString() ?? '');
        if (volume != null) {
          volumeTxt = volume.toStringAsFixed(2);
        }

        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'type'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info['type'] ?? '--', style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'capacity'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text('$volumeTxt L', style: style2)
            ],
          )
        ];
      case kShadowTypeKey:
        String totalAreaTxt = '--';
        double? totalArea = double.tryParse(info?['totalArea']?.toString() ?? '');
        if (totalArea != null) {
          totalAreaTxt = totalArea.toStringAsFixed(2);
        }
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'area'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text('$totalAreaTxt ha', style: style2)
            ],
          )
        ];
      case kBatchTypeKey:
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'type'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info?['lotType'] ?? '--', style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'category'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info?['lotCategory'] ?? '--', style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'birthday'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info?['birthday']?.toString() ?? '--', style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'race'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info?['lotRace'] ?? '--', style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'totalAnimals'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info?['totalAnimals']?.toString() ?? '--', style: style2)
            ],
          ),
        ];
      case kRotationTypeKey:
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'paddock'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info!['parcelLabel'], style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'batch'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info['lotLabel'], style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'beginning'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                  _formatDate(DateTime.fromMillisecondsSinceEpoch(
                          info['startDate'],
                          isUtc: true)
                      .toLocal()),
                  style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'finish'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                  _formatDate(DateTime.fromMillisecondsSinceEpoch(
                          info['endDate'],
                          isUtc: true)
                      .toLocal()),
                  style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'recurrence'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Text(
                  '${'daysUntil'.tr(args: [
                        info['recurrence'].toString()
                      ])} ${_formatDate(DateTime.fromMillisecondsSinceEpoch(info['recurrenceEndTime'], isUtc: true).toLocal())}',
                  style: style2,
                  textAlign: TextAlign.end,
                ),
              )
            ],
          ),
        ];
      case kAnimalTypeKey:
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'type'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info!['type'], style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'category'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info['category'], style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'birthday'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info['birthday'].toString(), style: style2)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'race'.tr()}:',
                style: style1,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(info['race'], style: style2)
            ],
          ),
        ];
      default:
        return [];
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMd().add_jm().format(date);
  }
}
