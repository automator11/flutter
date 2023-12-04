import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/resources/enums.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/params/params.dart';
import '../cubits/cubits.dart';

class EditWaterFontContentWidget extends StatefulWidget {
  final EntityModel? asset;

  const EditWaterFontContentWidget({super.key, this.asset});

  @override
  State<EditWaterFontContentWidget> createState() =>
      _EditWaterFontContentWidgetState();
}

class _EditWaterFontContentWidgetState
    extends State<EditWaterFontContentWidget> {
  final _updateWaterFontFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _volumeController = TextEditingController();

  String _name = '';
  double? _volume;
  String? _type;
  Map<String, dynamic> _position = {};
  String? _positionErrorMessage;

  bool _isLoading = false;

  List<String> _waterFontTypes = [];

  @override
  void initState() {
    if (widget.asset != null) {
      _nameController.text = _name = widget.asset!.label ?? '';
      _volume = widget.asset!.additionalInfo?['volume'];
      _volumeController.text = _volume.toString();
      _type = widget.asset!.additionalInfo?['type'] ?? '';
      _position = widget.asset!.additionalInfo?['position'] ?? {};
    }
    context.read<DropdownCubit>().getAssetsByGroupId(kWaterFontTypeGroupId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Form(
        key: _updateWaterFontFormKey,
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
              controller: _volumeController,
              keyboardType: const TextInputType.numberWithOptions(),
              label: '${'volume'.tr()} (L)',
              onSave: (value) => _volume = double.tryParse(value),
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
            BlocBuilder<DropdownCubit, DropdownState>(
              builder: (context, state) {
                bool isLoading = state is DropdownLoading;
                bool hasError = state is DropdownFail;
                if (state is DropdownSuccess) {
                  _waterFontTypes = state.items != null
                      ? state.items!
                          .map((e) =>
                              (e.label?.isEmpty ?? true) ? e.name : e.label!)
                          .toList()
                      : <String>[];
                }
                if (state is DropdownFail) {
                  _waterFontTypes = [];
                }
                return CustomDropDown(
                  initialValue: _type,
                  items: _waterFontTypes,
                  label: 'type'.tr(),
                  hint: '',
                  isLoading: isLoading,
                  hasError: hasError,
                  onRefresh: () => context
                      .read<DropdownCubit>()
                      .getAssetsByGroupId(kWaterFontTypeGroupId),
                  onSave: (value) => _type = value!,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'emptyFieldValidation'.tr();
                    }
                    return null;
                  },
                );
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
              label: 'waterFontPosition'.tr(),
              errorMessage: _positionErrorMessage,
              value: _position.isEmpty
                  ? const Text('selectWaterFontPosition',
                          style: TextStyle(fontSize: 12))
                      .tr()
                  : const Text('viewWaterFontPosition',
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
                            ? 'waterFontUpdated'.tr()
                            : 'waterFontCreated'.tr());
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
                          _updateWaterFontFormKey.currentState!.save();
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
                      child:
                          Text(widget.asset != null ? 'update' : 'add').tr());
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _createAsset(UserModel? user, EntityModel? parent) {
    WaterFontCreateParams params = WaterFontCreateParams(
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kWaterFontTypeKey,
        assetProfileId: kAssetsProfiles[kWaterFontTypeKey]!,
        volume: _volume!,
        waterFontType: _type!);
    context.read<AssetsCubit>().createAsset(params, parentId: parent.id.id);
  }

  void _updateAsset(UserModel? user, EntityModel? parent) {
    WaterFontUpdateParams params = WaterFontUpdateParams(
        id: widget.asset!.id.id,
        createdTime: widget.asset!.createdTime,
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kWaterFontTypeKey,
        assetProfileId: kAssetsProfiles[kWaterFontTypeKey]!,
        volume: _volume!,
        waterFontType: _type!);
    context.read<AssetsCubit>().updateAsset(params, parentId: parent.id.id);
  }

  bool _validateForm() {
    if (_position.isEmpty) {
      setState(() {
        _positionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    return _updateWaterFontFormKey.currentState?.validate() ?? false;
  }
}
