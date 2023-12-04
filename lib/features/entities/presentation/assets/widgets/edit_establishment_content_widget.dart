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

class EditEstablishmentContentWidget extends StatefulWidget {
  final EntityModel? asset;

  const EditEstablishmentContentWidget({super.key, this.asset});

  @override
  State<EditEstablishmentContentWidget> createState() =>
      _EditEstablishmentContentWidgetState();
}

class _EditEstablishmentContentWidgetState
    extends State<EditEstablishmentContentWidget> {
  final _updateEstablishmentFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _areaController = TextEditingController();

  String _name = '';
  double? _area;
  Map<String, dynamic> _mainHousePosition = {};
  String? _mainHousePositionErrorMessage;
  Map<String, dynamic> _position = {};
  String? _positionErrorMessage;

  bool _isLoading = false;

  @override
  void initState() {
    if (widget.asset != null) {
      _nameController.text = _name = widget.asset!.label!;
      _area = widget.asset!.additionalInfo?['totalArea'];
      _areaController.text = _area.toString();
      _mainHousePosition =
          widget.asset!.additionalInfo?['mainHousePosition'] ?? {};
      _position = widget.asset!.additionalInfo?['position'] ?? {};
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Form(
        key: _updateEstablishmentFormKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CustomTextField(
            controller: _nameController,
            label: 'name'.tr(),
            hint: 'establishmentName'.tr(),
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
            controller: _areaController,
            label: '${'totalArea'.tr()} (ha)',
            hint: 'establishmentArea'.tr(),
            keyboardType: const TextInputType.numberWithOptions(),
            onSave: (value) => _area = double.tryParse(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'emptyFieldValidation'.tr();
              }
              if (double.tryParse(value) == null) {
                return 'validDoubleFieldValidation'.tr();
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16,
          ),
          CustomSelectorField(
            onTap: () async {
              var result = await context.pushNamed<Map<String, dynamic>>(
                  kSelectPositionMapPageRoute,
                  extra: _mainHousePosition.isNotEmpty
                      ? _mainHousePosition
                      : _position);
              if (result is Map<String, dynamic>) {
                setState(() {
                  _mainHousePosition = result;
                  _mainHousePositionErrorMessage = null;
                });
              }
            },
            label: 'mainHousePosition'.tr(),
            errorMessage: _mainHousePositionErrorMessage,
            value: _mainHousePosition.isEmpty
                ? Text('selectMainHousePosition'.tr(),
                    style: const TextStyle(fontSize: 12))
                : Text(
                    '${'latitude'.tr()}: ${_mainHousePosition['marker']['latitude']}\n${'longitude'.tr()}: ${_mainHousePosition['marker']['latitude']}',
                    style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(
            height: 16,
          ),
          CustomSelectorField(
            onTap: () async {
              var result =
              await context.pushNamed<Map<String, dynamic>>(
                  kSelectPositionMapPageRoute,
                  queryParameters: {
                    'locationType': LocationType.polygon.name,
                    'assetType': kEstablishmentTypeKey
                  },
                  extra: _mainHousePosition.isNotEmpty
                      ? _mainHousePosition
                      : _position);
              if (result is Map<String, dynamic>) {
                setState(() {
                  _position = result;
                  _positionErrorMessage = null;
                });
              }
            },
            label: 'establishmentPosition'.tr(),
            errorMessage: _positionErrorMessage,
            value: _position.isEmpty
                ? Text('selectEstablishmentPosition'.tr(),
                style: const TextStyle(fontSize: 12))
                : const Text('viewEstablishmentPosition',
                style: TextStyle(fontSize: 12))
                .tr(),
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 120,
                height: 30,
                child: CustomOutlinedButton(
                    borderRadius: 10,
                    onPressed: () => context.pop(),
                    child: const Text(
                      'cancel',
                      style: TextStyle(color: kSecondaryColor),
                    ).tr()),
              ),
              SizedBox(
                width: 120,
                height: 30,
                child: BlocConsumer<EstablishmentsCubit, EstablishmentsState>(
                  listener: (context, state) async {
                    if (state is EstablishmentsFail) {
                      MyDialogs.showErrorDialog(context, state.message);
                    }
                    if (state is EstablishmentsSuccess) {
                      await MyDialogs.showSuccessDialog(
                          context,
                          widget.asset != null
                              ? 'establishmentUpdated'.tr()
                              : 'establishmentCreated'.tr());
                      if (mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  builder: (context, state) {
                    _isLoading = state is EstablishmentsLoading;
                    return CustomElevatedButton(
                        borderRadius: 10,
                        isLoading: _isLoading,
                        child:
                            Text(widget.asset != null ? 'update' : 'add').tr(),
                        onPressed: () {
                          if (_validateForm()) {
                            _updateEstablishmentFormKey.currentState!.save();
                            UserModel? user = context.read<AuthCubit>().user;
                            if (widget.asset != null) {
                              _updateAsset(user);
                              return;
                            }
                            _createAsset(user);
                          }
                        });
                  },
                ),
              )
            ],
          ),
        ]),
      ),
    );
  }

  void _createAsset(UserModel? user) {
    EstablishmentCreateParams params = EstablishmentCreateParams(
        name: _name.toLowerCase(),
        label: _name,
        type: kEstablishmentTypeKey,
        assetProfileId: kAssetsProfiles[kEstablishmentTypeKey],
        area: _area!,
        customerId: user!.customerId!.id,
        mainHousePosition: _mainHousePosition,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id);
    context.read<EstablishmentsCubit>().createEstablishment(params);
  }

  void _updateAsset(UserModel? user) {
    EstablishmentUpdateParams params = EstablishmentUpdateParams(
        id: widget.asset!.id.id,
        createdTime: widget.asset!.createdTime,
        assetProfileId: kAssetsProfiles[kEstablishmentTypeKey]!,
        type: kEstablishmentTypeKey,
        name: _name.toLowerCase(),
        label: _name,
        area: _area!,
        customerId: user!.customerId!.id,
        mainHousePosition: _mainHousePosition,
        position: _position,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id);
    context.read<EstablishmentsCubit>().updateEstablishment(params);
  }

  bool _validateForm() {
    if (_mainHousePosition.isEmpty) {
      setState(() {
        _mainHousePositionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    if (_position.isEmpty) {
      setState(() {
        _positionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    return _updateEstablishmentFormKey.currentState?.validate() ?? false;
  }
}
