import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/resources/enums.dart';
import '../../../../user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/params/params.dart';
import '../cubits/cubits.dart';

class EditShadowContentWidget extends StatefulWidget {
  final EntityModel? asset;

  const EditShadowContentWidget({super.key, this.asset});

  @override
  State<EditShadowContentWidget> createState() =>
      _EditShadowContentWidgetState();
}

class _EditShadowContentWidgetState extends State<EditShadowContentWidget> {
  final _editShadowFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _totalAreaController = TextEditingController();

  String _name = '';
  double? _totalArea;
  Map<String, dynamic> _position = {};
  String? _positionErrorMessage;

  bool _isLoading = false;

  @override
  void initState() {
    if (widget.asset != null) {
      _nameController.text = _name = widget.asset!.label ?? '';
      _totalArea = widget.asset!.additionalInfo?['totalArea'] ?? '';
      _totalAreaController.text = _totalArea.toString();
      _position = widget.asset!.additionalInfo?['position'] ?? {};
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Form(
        key: _editShadowFormKey,
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
              controller: _totalAreaController,
              keyboardType: const TextInputType.numberWithOptions(),
              label: 'totalArea'.tr(),
              onSave: (value) => _totalArea = double.tryParse(value),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'emptyFieldValidation'.tr();
                }
                if (double.tryParse(value!) == null) {
                  return 'validDoubleFieldValidation'.tr();
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
                    queryParameters: {'locationType': LocationType.custom.name},
                    extra: _position);
                if (result is Map<String, dynamic>) {
                  setState(() {
                    _position = result;
                    _positionErrorMessage = null;
                  });
                }
              },
              label: 'shadowPosition'.tr(),
              errorMessage: _positionErrorMessage,
              value: _position.isEmpty
                  ? const Text('selectShadowPosition',
                          style: TextStyle(fontSize: 12))
                      .tr()
                  : const Text('viewShadowPosition',
                          style: TextStyle(fontSize: 12))
                      .tr(),
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
                            ? 'shadowUpdated'.tr()
                            : 'shadowCreated'.tr());
                    if (mounted) {
                      Navigator.pop(context, state.asset);
                    }
                  }
                },
                builder: (context, state) {
                  _isLoading = state is AssetsLoading;
                  return CustomElevatedButton(
                      isLoading: _isLoading,
                      onPressed: () {
                        if (_validateForm()) {
                          _editShadowFormKey.currentState!.save();
                          UserModel? user = context.read<AuthCubit>().user;
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
    ShadowCreateParams params = ShadowCreateParams(
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kShadowTypeKey,
        assetProfileId: kAssetsProfiles[kShadowTypeKey]!,
        totalArea: _totalArea!);
    context.read<AssetsCubit>().createAsset(params, parentId: parent.id.id);
  }

  void _updateAsset(UserModel? user, EntityModel? parent) {
    ShadowUpdateParams params = ShadowUpdateParams(
        id: widget.asset!.id.id,
        createdTime: widget.asset!.createdTime,
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kShadowTypeKey,
        assetProfileId: kAssetsProfiles[kShadowTypeKey]!,
        totalArea: _totalArea!);
    context.read<AssetsCubit>().updateAsset(params, parentId: parent.id.id);
  }

  bool _validateForm() {
    if (_position.isEmpty) {
      setState(() {
        _positionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    return _editShadowFormKey.currentState?.validate() ?? false;
  }
}
