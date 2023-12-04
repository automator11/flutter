import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/routes.dart';
import '../../../../config/themes/colors.dart';
import '../../../../core/resources/constants.dart';
import '../../../../injector.dart';
import '../../../main_screen/presentation/cubit/cubits.dart';
import '../../data/models/common_models/entity_model.dart';
import '../devices/cubits/cubits.dart';
import '../devices/widgets/widgets.dart';

class TitleHeader extends SliverPersistentHeaderDelegate {
  final String title;
  final Function(String) onSearch;
  final double extent;
  final String? type;
  final bool isDevice;

  const TitleHeader(
      {required this.title,
      required this.onSearch,
      required this.extent,
      this.type,
      this.isDevice = false});

  void _addEntity(BuildContext context) async {
    if (isDevice) {
      if (type == kEarTagType) {
        await showDialog(
            context: context,
            builder: (context) => BlocProvider(
                  create: (context) => injector<DevicesCubit>(),
                  child: const ClaimEarTagDevicesDialog(),
                ));
      } else {
        await showDialog(
            context: context,
            builder: (context) => BlocProvider(
                  create: (context) => injector<DevicesCubit>(),
                  child: const ClaimDeviceDialog(),
                ));
      }
      context.read<AppStateCubit>().emitDeviceClaimed();
      return;
    }
    await context.pushNamed<EntityModel?>(kMapEditAssetPageRoute,
        queryParameters: {'type': type}).then((value) {
      if (value != null) {
        context.read<AppStateCubit>().emitAssetCreated(type!);
      }
    });
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: kSecondaryBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                title,
                style: const TextStyle(
                    color: kPrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ).tr(),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                  color: kSecondaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: kElevationToShadow[3]),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search'.tr(),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/icons/search_grey.png',
                      width: 12,
                    ),
                  ),
                  border: Theme.of(context)
                      .inputDecorationTheme
                      .border
                      ?.copyWith(borderSide: BorderSide.none),
                  enabledBorder: Theme.of(context)
                      .inputDecorationTheme
                      .enabledBorder
                      ?.copyWith(borderSide: BorderSide.none),
                  errorBorder: Theme.of(context)
                      .inputDecorationTheme
                      .errorBorder
                      ?.copyWith(borderSide: BorderSide.none),
                  focusedBorder: Theme.of(context)
                      .inputDecorationTheme
                      .focusedBorder
                      ?.copyWith(borderSide: BorderSide.none),
                  focusedErrorBorder: Theme.of(context)
                      .inputDecorationTheme
                      .focusedErrorBorder
                      ?.copyWith(borderSide: BorderSide.none),
                ),
              ),
            ),
            if (type != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 4, right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _addEntity(context),
                      child: const Text(
                        'add',
                        style: TextStyle(
                            fontSize: 12,
                            color: kPrimaryText,
                            fontWeight: FontWeight.bold),
                      ).tr(),
                    ),
                    TextButton(
                      onPressed: () {
                        if(isDevice){
                          context.goNamed(kTableDevicesPageRoute,
                              queryParameters: {'type': type});
                          return;
                        }
                        context.goNamed(kTableAssetsPageRoute,
                            queryParameters: {'type': type});
                      },
                      child: const Text(
                        'seeMore',
                        style: TextStyle(color: kSecondaryText, fontSize: 12),
                      ).tr(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => extent + 20;

  @override
  double get minExtent => extent + 20;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
