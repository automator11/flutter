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
import '../../assets/cubits/cubits.dart';
import '../cubits/cubits.dart';

class ConfigureWaterLevelPage extends StatefulWidget {
  final EntityModel device;

  const ConfigureWaterLevelPage({super.key, required this.device});

  @override
  State<ConfigureWaterLevelPage> createState() =>
      _ConfigureWaterLevelPageState();
}

class _ConfigureWaterLevelPageState extends State<ConfigureWaterLevelPage> {
  final _configureWaterLevelFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _initialLevelController = TextEditingController();
  final _minLevelController = TextEditingController();
  final _maxLevelController = TextEditingController();

  String _label = '';
  double? _initialLevel;
  double? _minLevel;
  double? _maxLevel;
  Map<String, dynamic> _position = {};
  String? _positionErrorMessage;

  bool _isLoading = false;

  EntityModel? _currentEstablishment;
  EntityModel? _establishment;
  DropdownSelectedState _establishmentsState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntityModel>[]);

  @override
  void initState() {
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    context.read<DropdownCubit>().getEstablishments();
    _nameController.text = _label = widget.device.label ?? '';
    _initialLevel = widget.device.additionalInfo?['initLevel'];
    _initialLevelController.text = _initialLevel?.toString() ?? '';
    _minLevel = widget.device.additionalInfo?['minLevel'];
    _minLevelController.text = _minLevel?.toString() ?? '';
    _maxLevel = widget.device.additionalInfo?['maxLevel'];
    _maxLevelController.text = _maxLevel?.toString() ?? '';
    _position = widget.device.additionalInfo?['position'] ?? {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - (2 * 84) - 16,
            child: const Text(
              'configureWaterLevel',
              style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ).tr(),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Form(
            key: _configureWaterLevelFormKey,
            child: Column(
              children: [
                BlocSelector<DropdownCubit, DropdownState,
                    DropdownSelectedState>(
                  selector: (state) {
                    if (state.groupType == kEstablishmentTypeKey) {
                      bool isLoading = state is DropdownLoading;
                      bool hasError = state is DropdownFail;
                      List<EntityModel> establishments = [];
                      if (state is DropdownSuccess) {
                        establishments = state.items!;
                      }
                      if (state is DropdownFail) {
                        establishments = [];
                      }
                      _establishmentsState = DropdownSelectedState(
                          isLoading: isLoading,
                          error: hasError,
                          items: establishments);
                      return _establishmentsState;
                    }
                    return _establishmentsState;
                  },
                  builder: (context, state) {
                    return CustomDropDown<EntityModel>(
                      initialValue: _currentEstablishment,
                      items: state.items as List<EntityModel>,
                      label: 'establishment'.tr(),
                      hint: '',
                      isLoading: state.isLoading,
                      hasError: state.error,
                      onRefresh: () =>
                          context.read<DropdownCubit>().getEstablishments(),
                      onSave: (value) => _establishment = value,
                      validator: (value) {
                        if (value == null) {
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
                CustomTextField(
                  controller: _nameController,
                  label: 'name'.tr(),
                  onSave: (value) => _label = value,
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
                  controller: _initialLevelController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  label: '${'initLevel'.tr()} (cm)',
                  onSave: (value) => _initialLevel = double.tryParse(value),
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
                  controller: _minLevelController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  label: '${'minLevel'.tr()} (cm)',
                  onSave: (value) => _minLevel = double.tryParse(value),
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
                  controller: _maxLevelController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  label: '${'maxLevel'.tr()} (cm)',
                  onSave: (value) => _maxLevel = double.tryParse(value),
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
                        queryParameters: {
                          'locationType': LocationType.single.name
                        }, extra: _position);
                    if (result is Map<String, dynamic>) {
                      setState(() {
                        _position = result;
                        _positionErrorMessage = null;
                      });
                    }
                  },
                  label: 'devicePosition'.tr(),
                  errorMessage: _positionErrorMessage,
                  value: _position.isEmpty
                      ? const Text(
                          'selectDevicePosition',
                          style: TextStyle(fontSize: 12),
                        ).tr()
                      : const Text('viewDevicePosition',
                              style: TextStyle(fontSize: 12))
                          .tr(),
                ),
                const SizedBox(
                  height: 45,
                ),
                SizedBox(
                  width: 120,
                  height: 30,
                  child: BlocConsumer<DevicesCubit, DevicesState>(
                    listener: (context, state) async {
                      if (state is DevicesFail) {
                        MyDialogs.showErrorDialog(
                            context, state.message.tr());
                      }
                      if (state is DevicesSuccess) {
                        await MyDialogs.showSuccessDialog(
                            context, 'waterLevelConfigured'.tr());
                        if (mounted) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    builder: (context, state) {
                      _isLoading = state is DevicesLoading;
                      return CustomElevatedButton(
                          isLoading: _isLoading,
                          onPressed: () {
                            if (_validateForm()) {
                              _configureWaterLevelFormKey.currentState!
                                  .save();
                              UserModel? user =
                                  context.read<AuthCubit>().user;
                              ConfigureWaterLevelParams params =
                                  ConfigureWaterLevelParams(
                                      id: widget.device.id.id,
                                      createdTime: widget
                                          .device.createdTime,
                                      name: widget.device.name,
                                      label: _label,
                                      customerId: user!.customerId!.id,
                                      position: _position,
                                      ownerId: user.ownerId.id,
                                      tenantId: user.tenantId.id,
                                      type: kWaterLevelType,
                                      deviceProfileId: kDevicesProfiles[
                                          kWaterLevelType]!,
                                      initLevel: _initialLevel!,
                                      minLevel: _minLevel!,
                                      maxLevel: _maxLevel!,
                                      currentInfo:
                                          widget.device.additionalInfo ??
                                              {},
                                      deviceData:
                                          widget.device.deviceData ?? {},
                                      establishmentName:
                                          _establishment!.name);
                              context
                                  .read<DevicesCubit>()
                                  .configureDevice(params);
                            }
                          },
                          borderRadius: 10,
                          child: const Text('configure', style: TextStyle(fontSize: 12),).tr());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  bool _validateForm() {
    if (_position.isEmpty) {
      setState(() {
        _positionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    return _configureWaterLevelFormKey.currentState?.validate() ?? false;
  }
}
