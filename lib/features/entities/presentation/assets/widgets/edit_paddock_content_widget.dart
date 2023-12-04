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
import '../cubits/assets_cubit/assets_cubit.dart';

class EditPaddockContentWidget extends StatefulWidget {
  final EntityModel? asset;

  const EditPaddockContentWidget({super.key, this.asset});

  @override
  State<EditPaddockContentWidget> createState() =>
      _EditPaddockContentWidgetState();
}

class _EditPaddockContentWidgetState extends State<EditPaddockContentWidget> {
  final _updatePaddockFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _totalAreaController = TextEditingController();
  final _usableAreaController = TextEditingController();

  String _name = '';
  double? _totalArea;
  double? _usableArea;
  Map<String, dynamic> _position = {};
  String? _positionErrorMessage;

  bool _isLoading = false;

  @override
  void initState() {
    if (widget.asset != null) {
      _nameController.text = _name = widget.asset!.label ?? '';
      _totalArea = widget.asset!.additionalInfo?['totalArea'];
      _totalAreaController.text = _totalArea.toString();
      _usableArea = widget.asset!.additionalInfo?['usableArea'];
      _usableAreaController.text = _usableArea.toString();
      _position = widget.asset!.additionalInfo?['position'] ?? {};
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Form(
        key: _updatePaddockFormKey,
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
              keyboardType: const TextInputType.numberWithOptions(),
              controller: _totalAreaController,
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
            CustomTextField(
              keyboardType: const TextInputType.numberWithOptions(),
              controller: _usableAreaController,
              label: 'usableArea'.tr(),
              onSave: (value) => _usableArea = double.tryParse(value),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'emptyFieldValidation'.tr();
                }
                if (double.tryParse(value!) == null) {
                  return 'validDoubleFieldValidation'.tr();
                }
                double total =
                    double.tryParse(_totalAreaController.text) ?? 0.0;
                double usable = double.tryParse(value) ?? 1.0;
                if (usable > total) {
                  return 'invalidPaddockUsableAreaValue'.tr();
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
                    queryParameters: {
                      'locationType': LocationType.polygon.name,
                      'assetType': kPaddockTypeKey
                    },
                    extra: _position);
                if (result is Map<String, dynamic>) {
                  setState(() {
                    _position = result;
                    _positionErrorMessage = null;
                  });
                }
              },
              label: 'paddockPosition'.tr(),
              errorMessage: _positionErrorMessage,
              value: _position.isEmpty
                  ? const Text('selectPaddockPosition',
                          style: TextStyle(fontSize: 12))
                      .tr()
                  : const Text('viewPaddockPosition',
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
                            ? 'paddockUpdated'.tr()
                            : 'paddockCreated'.tr());
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
                          _updatePaddockFormKey.currentState!.save();
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
    PaddockCreateParams params = PaddockCreateParams(
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kPaddockTypeKey,
        assetProfileId: kAssetsProfiles[kPaddockTypeKey]!,
        totalArea: _totalArea!,
        usableArea: _usableArea!);
    context.read<AssetsCubit>().createAsset(params, parentId: parent.id.id);
  }

  void _updateAsset(UserModel? user, EntityModel? parent) {
    PaddockUpdateParams params = PaddockUpdateParams(
        id: widget.asset!.id.id,
        name: _name.toLowerCase(),
        label: _name,
        createdTime: widget.asset!.createdTime,
        customerId: user!.customerId!.id,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kPaddockTypeKey,
        assetProfileId: kAssetsProfiles[kPaddockTypeKey]!,
        totalArea: _totalArea!,
        usableArea: _usableArea!,
        beforeArea: widget.asset!.additionalInfo?['totalArea'] ?? 0.0);
    context.read<AssetsCubit>().updateAsset(params, parentId: parent.id.id);
  }

  bool _validateForm() {
    if (_position.isEmpty) {
      setState(() {
        _positionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    return _updatePaddockFormKey.currentState?.validate() ?? false;
  }
}
