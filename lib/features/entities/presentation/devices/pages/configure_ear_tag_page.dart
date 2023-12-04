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
import '../../assets/cubits/cubits.dart';
import '../cubits/cubits.dart';

class ConfigureEarTagPage extends StatefulWidget {
  final EntityModel device;
  final Map<String, dynamic>? batchInfo;

  const ConfigureEarTagPage({super.key, required this.device, this.batchInfo});

  @override
  State<ConfigureEarTagPage> createState() => _ConfigureEarTagPageState();
}

class _ConfigureEarTagPageState extends State<ConfigureEarTagPage> {
  final _configureEarTagFormKey = GlobalKey<FormState>();

  final _typeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _raceController = TextEditingController();
  final _birthdayController = TextEditingController();

  String? _selectedAnimalName;
  EntitySearchModel? _animal;
  String? _selectedBatchName;
  EntitySearchModel? _batch;
  EntityModel? _currentEstablishment;
  EntityModel? _establishment;

  DropdownSelectedState _animalsState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntitySearchModel>[]);
  DropdownSelectedState _batchesState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntitySearchModel>[]);
  DropdownSelectedState _establishmentsState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntityModel>[]);

  void _updateSelectedAnimalData(EntitySearchModel value) {
    _typeController.text = value.latest.additionalInfo!['type'];
    _categoryController.text = value.latest.additionalInfo!['category'];
    _raceController.text = value.latest.additionalInfo!['race'];
    _birthdayController.text =
        value.latest.additionalInfo!['birthday'].toString();
  }

  @override
  void initState() {
    if (widget.batchInfo != null) {
      //TODO: Update data according to batch
    }
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    context.read<DropdownCubit>().getEstablishments();
    context
        .read<DropdownCubit>()
        .getAssetsByParentId(_currentEstablishment!.id.id, kBatchTypeKey);
    context.read<DropdownCubit>().getAssetsByGroupName(
        '${_currentEstablishment?.name}$kAvailableAnimalsName');
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
              'configureEarTag',
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
            key: _configureEarTagFormKey,
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
                BlocSelector<DropdownCubit, DropdownState,
                    DropdownSelectedState>(
                  selector: (state) {
                    if (state.groupType == kBatchTypeKey) {
                      bool isLoading = state is DropdownLoading;
                      bool hasError = state is DropdownFail;
                      List<EntitySearchModel> batches = [];
                      if (state is DropdownSuccess) {
                        batches = state.searchItems!;
                        for (EntitySearchModel batch in batches) {
                          if (batch.latest.name == _selectedBatchName) {
                            _batch = batch;
                          }
                        }
                        if (_selectedBatchName == null && batches.isNotEmpty) {
                          _selectedBatchName = batches.first.latest.name;
                          _batch = batches.first;
                        }
                      }
                      if (state is DropdownFail) {
                        batches = [];
                      }
                      _batchesState = DropdownSelectedState(
                          isLoading: isLoading,
                          error: hasError,
                          items: batches);
                      return _batchesState;
                    }
                    return _batchesState;
                  },
                  builder: (context, state) {
                    return CustomDropDown<EntitySearchModel>(
                      initialValue: _batch,
                      items: state.items as List<EntitySearchModel>,
                      label: 'batch'.tr(),
                      hint: '',
                      isLoading: state.isLoading,
                      hasError: state.error,
                      onRefresh: () => context
                          .read<DropdownCubit>()
                          .getAssetsByParentId(
                              _currentEstablishment!.id.id, kBatchTypeKey),
                      disabled: widget.batchInfo?.isNotEmpty ?? true,
                      onSave: widget.batchInfo == null
                          ? null
                          : (value) => _batch = value,
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
                BlocSelector<DropdownCubit, DropdownState,
                    DropdownSelectedState>(
                  selector: (state) {
                    if (state.groupType ==
                        '${_currentEstablishment?.name}$kAvailableAnimalsName') {
                      bool isLoading = state is DropdownLoading;
                      bool hasError = state is DropdownFail;
                      List<EntitySearchModel> animals = [];
                      if (state is DropdownSuccess) {
                        animals = state.searchItems!;
                        for (EntitySearchModel animal in animals) {
                          if (animal.latest.name == _selectedAnimalName) {
                            _animal = animal;
                            setState(() {
                              _updateSelectedAnimalData(animal);
                            });
                          }
                        }
                        if (_selectedAnimalName == null && animals.isNotEmpty) {
                          _selectedAnimalName = animals.first.latest.name;
                          _animal = animals.first;
                          setState(() {
                            _updateSelectedAnimalData(_animal!);
                          });
                        }
                      }
                      if (state is DropdownFail) {
                        animals = [];
                      }
                      _animalsState = DropdownSelectedState(
                          isLoading: isLoading,
                          error: hasError,
                          items: animals);
                      return _animalsState;
                    }
                    return _animalsState;
                  },
                  builder: (context, state) {
                    return CustomDropDown<EntitySearchModel>(
                      initialValue: _animal,
                      items: state.items as List<EntitySearchModel>,
                      label: 'animal'.tr(),
                      hint: '',
                      isLoading: state.isLoading,
                      hasError: state.error,
                      onRefresh: () => context
                          .read<DropdownCubit>()
                          .getAssetsByGroupName(
                              '${_currentEstablishment?.name}$kAvailableAnimalsName'),
                      onChange: (value) {
                        if (value != null) {
                          setState(() {
                            _updateSelectedAnimalData(value);
                          });
                        }
                      },
                      onSave: (value) => _animal = value,
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
                  readOnly: true,
                  controller: _typeController,
                  label: 'type'.tr(),
                  onSave: (_) {},
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  readOnly: true,
                  controller: _categoryController,
                  label: 'category'.tr(),
                  onSave: (_) {},
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  readOnly: true,
                  controller: _raceController,
                  label: 'race'.tr(),
                  onSave: (_) {},
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  readOnly: true,
                  controller: _birthdayController,
                  label: 'birthday'.tr(),
                  onSave: (_) {},
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: 120,
                  height: 30,
                  child: CustomElevatedButton(
                      onPressed: () async {
                        final animal = await context.pushNamed<EntityModel?>(kMapEditAssetPageRoute,
                            queryParameters: {'type': kAnimalTypeKey});
                        if (animal != null && mounted) {
                          _selectedAnimalName = animal.name;
                          context.read<DropdownCubit>().getAssetsByGroupName(
                              '${_currentEstablishment?.name}$kAvailableAnimalsName');
                        }
                      },
                      borderRadius: 10,
                      backgroundColor: kSecondaryColor,
                      child: const Text(
                        'createAnimal',
                        textAlign: TextAlign.center,
                      ).tr()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 120,
          height: 30,
          child: BlocConsumer<DevicesCubit, DevicesState>(
            listener: (context, state) async {
              if (state is DevicesFail) {
                MyDialogs.showErrorDialog(context, state.message.tr());
              }
              if (state is DevicesSuccess) {
                await MyDialogs.showSuccessDialog(
                    context, 'earTagConfigured'.tr());
                if (mounted) {
                  Navigator.pop(context, true);
                }
              }
            },
            builder: (context, state) {
              bool isLoading = state is DevicesLoading;
              return CustomElevatedButton(
                  isLoading: isLoading,
                  onPressed: () {
                    if (_validateForm()) {
                      _configureEarTagFormKey.currentState!.save();
                      UserModel? user = context.read<AuthCubit>().user;
                      ConfigureEarTagParams params = ConfigureEarTagParams(
                          id: widget.device.id.id,
                          createdTime: widget.device.createdTime,
                          name: widget.device.name,
                          label: _animal!.latest.name,
                          customerId: user!.customerId!.id,
                          ownerId: user.ownerId.id,
                          tenantId: user.tenantId.id,
                          type: kEarTagType,
                          deviceProfileId: kDevicesProfiles[kEarTagType]!,
                          currentInfo: widget.device.additionalInfo ?? {},
                          deviceData: widget.device.deviceData ?? {},
                          animalId: _animal!.entityId.id,
                          batchId: _batch?.entityId.id,
                          batchName: _batch?.latest.name,
                          establishmentName: _establishment!.name);
                      context.read<DevicesCubit>().configureDevice(params);
                    }
                  },
                  borderRadius: 10,
                  child: const Text('configure',
                          style: TextStyle(fontSize: 12))
                      .tr());
            },
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  bool _validateForm() {
    return _configureEarTagFormKey.currentState?.validate() ?? false;
  }
}
