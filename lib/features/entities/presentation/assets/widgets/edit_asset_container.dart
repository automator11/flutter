import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/resources/constants.dart';
import '../../../data/models/models.dart';
import '../widgets/widgets.dart';

class EditAssetContainer extends StatelessWidget {
  final EntityModel? asset;
  final String? entityType;

  const EditAssetContainer(
      {super.key, this.asset, this.entityType})
      : assert(asset != null || entityType != null);

  @override
  Widget build(BuildContext context) {
    String type = asset != null ? (asset?.type ?? '') : entityType!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              asset != null ? 'editAsset' : 'addEntity',
              style: const TextStyle(
                  color: kSecondaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ).tr(args: [type]),
            if (type == kEstablishmentTypeKey)
              EditEstablishmentContentWidget(asset: asset),
            if (type == kAnimalTypeKey) EditAnimalContentWidget(asset: asset),
            if (type == kBatchTypeKey) EditBatchContentWidget(asset: asset),
            if (type == kGatewayTypeKey) EditGatewayContentWidget(asset: asset),
            if (type == kPaddockTypeKey) EditPaddockContentWidget(asset: asset),
            if (type == kRotationTypeKey)
              EditRotationContentWidget(asset: asset),
            if (type == kShadowTypeKey) EditShadowContentWidget(asset: asset),
            if (type == kWaterFontTypeKey)
              EditWaterFontContentWidget(asset: asset)
          ],
        ),
      ),
    );
  }
}
