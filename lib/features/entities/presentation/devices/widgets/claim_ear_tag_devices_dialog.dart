import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../injector.dart';
import '../../assets/cubits/cubits.dart';
import '../../assets/widgets/widgets.dart';
import '../cubits/cubits.dart';
import '../pages/pages.dart';
import 'widgets.dart';

class ClaimEarTagDevicesDialog extends StatefulWidget {
  const ClaimEarTagDevicesDialog({super.key});

  @override
  State<ClaimEarTagDevicesDialog> createState() =>
      _ClaimEarTagDevicesDialogState();
}

class _ClaimEarTagDevicesDialogState extends State<ClaimEarTagDevicesDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 600),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'claimDevice',
                        style: TextStyle(
                            color: kSecondaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ).tr(),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'claimEarTagDeviceMessage',
                        style: TextStyle(
                            color: kSecondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ).tr(),
                      const SizedBox(
                        height: 24,
                      ),
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: kInputDefaultBorderColor)),
                        onTap: () async {
                          var currentEstablishment = context
                              .read<AppStateCubit>()
                              .currentEstablishment;
                          bool? result = currentEstablishment != null;
                          if (currentEstablishment == null) {
                            result = await showDialog(
                                context: context,
                                builder: (context) => BlocProvider(
                                      create: (context) =>
                                          injector<EstablishmentsCubit>(),
                                      child: const SelectEstablishmentDialog(),
                                    ));
                          }
                          if (result is bool && result && mounted) {
                            await showDialog(
                                context: context,
                                builder: (context) => BlocProvider(
                                      create: (context) =>
                                          injector<ListAssetsCubit>(),
                                      child: const SelectBatchDialog(),
                                    ));
                            if (mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          }
                        },
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'addByBatch',
                                    style: TextStyle(fontSize: 14),
                                  ).tr(),
                                  const Text(
                                    'addByBatchSubtitle',
                                    style: TextStyle(
                                        color: kSecondaryText, fontSize: 12),
                                  ).tr(),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Ionicons.chevron_back_outline,
                              size: 30,
                              color: kSecondaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: kInputDefaultBorderColor)),
                        onTap: () async {
                          var currentEstablishment = context
                              .read<AppStateCubit>()
                              .currentEstablishment;
                          bool? result = currentEstablishment != null;
                          if (currentEstablishment == null) {
                            result = await showDialog(
                                context: context,
                                builder: (context) => BlocProvider(
                                      create: (context) =>
                                          injector<EstablishmentsCubit>(),
                                      child: const SelectEstablishmentDialog(),
                                    ));
                          }
                          if (result is bool && result && mounted) {
                            await showDialog<bool?>(
                                    context: context,
                                    builder: (context) => DialogContainer(
                                            child: MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                                create: (context) =>
                                                    injector<DevicesCubit>()),
                                            BlocProvider(
                                                create: (context) =>
                                                    injector<DropdownCubit>()),
                                            BlocProvider(
                                                create: (context) =>
                                                    injector<AssetsCubit>()),
                                          ],
                                          child: const ClaimEarTagPage(),
                                        ))) ??
                                false;
                            if (mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          }
                        },
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'addByAnimal',
                                    style: TextStyle(fontSize: 14),
                                  ).tr(),
                                  const Text(
                                    'addByAnimalSubtitle',
                                    style: TextStyle(
                                        color: kSecondaryText, fontSize: 12),
                                  ).tr(),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Ionicons.chevron_forward_outline,
                              size: 30,
                              color: kSecondaryColor,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                    top: 16,
                    right: 16,
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircleButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Ionicons.close,
                          color: kIconLightColor,
                          size: 18,
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
