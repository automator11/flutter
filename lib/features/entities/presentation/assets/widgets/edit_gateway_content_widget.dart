import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/params/params.dart';
import '../cubits/assets_cubit/assets_cubit.dart';

class EditGatewayContentWidget extends StatefulWidget {
  final EntityModel? asset;

  const EditGatewayContentWidget({super.key, this.asset});

  @override
  State<EditGatewayContentWidget> createState() =>
      _EditGatewayContentWidgetState();
}

class _EditGatewayContentWidgetState extends State<EditGatewayContentWidget> {
  final _createGatewayFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _gatewayIdController = TextEditingController();

  String _name = '';
  String _gatewayId = '';
  Map<String, dynamic> _position = {};
  String? _positionErrorMessage;

  bool _isLoading = false;

  @override
  void initState() {
    if (widget.asset != null) {
      _nameController.text = _name = widget.asset!.label ?? '';
      _gatewayIdController.text =
          _gatewayId = widget.asset!.additionalInfo?['id'] ?? '';
      _position = widget.asset!.additionalInfo?['position'] ?? {};
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Form(
        key: _createGatewayFormKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'name'.tr(),
              onSave: (value) => _name = value,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'emptyFieldValidation'.tr();
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
              controller: _gatewayIdController,
              label: 'gatewayId'.tr(),
              onSave: (value) => _gatewayId = value,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'emptyFieldValidation'.tr();
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            CustomSelectorField(
              onTap: () async {
                var result = await context.pushNamed<Map<String, dynamic>>(
                    kSelectPositionMapPageRoute,
                    extra: _position);
                if (result is Map<String, dynamic>) {
                  setState(() {
                    _position = result;
                    _positionErrorMessage = null;
                  });
                }
              },
              label: 'gatewayPosition'.tr(),
              errorMessage: _positionErrorMessage,
              value: _position.isEmpty
                  ? Text('selectMainHousePosition'.tr(),
                      style: const TextStyle(fontSize: 12))
                  : Text(
                      '${'latitude'.tr()}: ${_position['marker']['latitude']}\n${'longitude'.tr()}: ${_position['marker']['latitude']}',
                      style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 120,
              height: 30,
              child: BlocConsumer<AssetsCubit, AssetsState>(
                listener: (context, state) async {
                  if (state is AssetsFail) {
                    MyDialogs.showErrorDialog(context, state.message);
                  }
                  if (state is AssetsSuccess) {
                    await MyDialogs.showSuccessDialog(
                        context,
                        widget.asset != null
                            ? 'gatewayUpdated'.tr()
                            : 'gatewayCreated'.tr());
                    if (mounted) {
                      Navigator.pop(context, state.asset);
                    }
                  }
                },
                builder: (context, state) {
                  _isLoading = state is AssetsLoading;
                  return CustomElevatedButton(
                      isLoading: _isLoading,
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_validateForm()) {
                                _createGatewayFormKey.currentState!.save();
                                UserModel? user =
                                    context.read<AuthCubit>().user;
                                EntityModel? parent = context
                                    .read<AppStateCubit>()
                                    .currentEstablishment;
                                if (widget.asset != null) {
                                  _updateAsset(user, parent);
                                  return;
                                }
                                _createAsset(user, parent);
                              }
                            },
                      borderRadius: 10,
                      child: Text(widget.asset != null ? 'update' : 'add')
                          .tr());
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _createAsset(UserModel? user, EntityModel? parent) {
    GatewayCreateParams params = GatewayCreateParams(
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        gatewayId: _gatewayId,
        parentName: parent!.name,
        type: kGatewayTypeKey,
        assetProfileId: kAssetsProfiles[kGatewayTypeKey]!);
    context.read<AssetsCubit>().createAsset(params);
  }

  void _updateAsset(UserModel? user, EntityModel? parent) {
    GatewayUpdateParams params = GatewayUpdateParams(
        id: widget.asset!.id.id,
        createdTime: widget.asset!.createdTime,
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        gatewayId: _gatewayId,
        parentName: parent!.name,
        type: kGatewayTypeKey,
        assetProfileId: kAssetsProfiles[kGatewayTypeKey]!);
    context.read<AssetsCubit>().updateAsset(params);
  }

  bool _validateForm() {
    if (_position.isEmpty) {
      setState(() {
        _positionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    return _createGatewayFormKey.currentState?.validate() ?? false;
  }
}
