import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/params/params.dart';
import '../cubits/cubits.dart';

class ClaimDeviceDialog extends StatefulWidget {
  const ClaimDeviceDialog({super.key});

  @override
  State<ClaimDeviceDialog> createState() => _ClaimDeviceDialogState();
}

class _ClaimDeviceDialogState extends State<ClaimDeviceDialog> {
  final _claimDeviceFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _secretKeyController = TextEditingController();

  String _name = '';
  String _secretKey = '';

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 600),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 50, 16.0, 16.0),
                  child: Form(
                    key: _claimDeviceFormKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                        'claimDeviceMessage',
                        style: TextStyle(
                            color: kSecondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ).tr(),
                      const SizedBox(
                        height: 24,
                      ),
                      CustomTextField(
                        controller: _nameController,
                        label: 'name'.tr(),
                        hint: 'deviceName'.tr(),
                        onSave: (value) => _name = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'emptyFieldValidation'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomTextField(
                        controller: _secretKeyController,
                        label: 'secretKey',
                        hint: 'deviceSecretKey'.tr(),
                        onSave: (value) => _secretKey = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'emptyFieldValidation'.tr();
                          }
                          return null;
                        },
                      ),
                      // const SizedBox(
                      //   height: 16,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      //   child: Row(
                      //     children: [
                      //       const Expanded(
                      //           child: Divider(
                      //         height: 10,
                      //         color: kInputDefaultBorderColor,
                      //       )),
                      //       Padding(
                      //         padding:
                      //             const EdgeInsets.symmetric(horizontal: 8.0),
                      //         child: const Text(
                      //           'or',
                      //           style: TextStyle(
                      //               color: kSecondaryText,
                      //               fontSize: 22,
                      //               fontWeight: FontWeight.w500),
                      //         ).tr(),
                      //       ),
                      //       const Expanded(
                      //           child: Divider(
                      //         height: 10,
                      //         color: kInputDefaultBorderColor,
                      //       ))
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 16,
                      // ),
                      // SizedBox(
                      //   height: 80,
                      //   child: CustomElevatedButton(
                      //       borderRadius: 10,
                      //       backgroundColor: kSecondaryColor,
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Image.asset('assets/icons/scan_qr.png'),
                      //           const Text(
                      //             'scanQr',
                      //             style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 18,
                      //                 fontWeight: FontWeight.w500),
                      //           ).tr()
                      //         ],
                      //       ),
                      //       onPressed: () async {
                      //         String? result = await context
                      //             .pushNamed<String?>(kScanQrCodePageRoute);
                      //         if (result != null && mounted) {
                      //           List<String> splitted = result.split(';');
                      //           _name = splitted[0];
                      //           _nameController.text = _name;
                      //           _secretKey = splitted[1];
                      //           _secretKeyController.text = _secretKey;
                      //         }
                      //       }),
                      // ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 120,
                            child: CustomOutlinedButton(
                              borderRadius: 10,
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text('cancel').tr(),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 120,
                            child: BlocConsumer<DevicesCubit, DevicesState>(
                              listener: (context, state) async {
                                if (state is DevicesFail) {
                                  MyDialogs.showErrorDialog(
                                      context, state.message);
                                }
                                if (state is GetDeviceSuccess) {
                                  // TODO: Update device with establishment
                                  await MyDialogs.showSuccessDialog(
                                      context, 'deviceClaimed'.tr());
                                  if (mounted) {
                                    Navigator.pop(context, state.device);
                                  }
                                }
                              },
                              builder: (context, state) {
                                _isLoading = state is DevicesLoading;
                                return CustomElevatedButton(
                                    borderRadius: 10,
                                    isLoading: _isLoading,
                                    child: const Text('claim').tr(),
                                    onPressed: () {
                                      if (_claimDeviceFormKey.currentState
                                              ?.validate() ??
                                          false) {
                                        _claimDeviceFormKey.currentState!
                                            .save();
                                        ClaimDeviceParams params =
                                            ClaimDeviceParams(
                                                name: _name,
                                                secretKey: _secretKey);
                                        context
                                            .read<DevicesCubit>()
                                            .claimDevice(params);
                                      }
                                    });
                              },
                            ),
                          ),
                        ],
                      )
                    ]),
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
                          Ionicons.close_outline,
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
