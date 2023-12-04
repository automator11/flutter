import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/params/params.dart';
import '../../assets/cubits/cubits.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';

class ClaimEarTagPage extends StatefulWidget {
  final EntitySearchModel? batchInfo;

  const ClaimEarTagPage({super.key, this.batchInfo});

  @override
  State<ClaimEarTagPage> createState() => _ClaimEarTagPageState();
}

class _ClaimEarTagPageState extends State<ClaimEarTagPage> {
  final _claimEarTagFormKey = GlobalKey<FormState>();

  final _deviceNameController = TextEditingController();
  final _secretKeyController = TextEditingController();

  String _deviceName = '';
  String _secretKey = '';

  String? _selectedAnimalName;
  EntityModel? _animal;
  List<EntitySearchModel> _animals = [];
  EntityModel? _currentEstablishment;
  EntityModel? _device;

  String? _selectedBatchName;
  EntitySearchModel? _batch;

  bool _isLoading = false;

  DropdownSelectedState _animalsState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntitySearchModel>[]);
  DropdownSelectedState _batchesState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntitySearchModel>[]);

  @override
  void initState() {
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    _batch = widget.batchInfo;
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
    return SingleChildScrollView(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Form(
              key: _claimEarTagFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - (2 * 84) - 16,
                    child: const Text(
                      'addEarTag',
                      style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ).tr(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Column(
                      children: [
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
                            _animals = state.items as List<EntitySearchModel>;
                            return Autocomplete<EntitySearchModel>(
                              optionsBuilder: (editingValue) {
                                if (editingValue.text == '') {
                                  return const Iterable<
                                      EntitySearchModel>.empty();
                                } else {
                                  List<EntitySearchModel> matches =
                                      <EntitySearchModel>[];
                                  matches.addAll(_animals);

                                  matches.retainWhere((s) {
                                    return s.latest.label
                                        .contains(editingValue.text);
                                  });
                                  return matches;
                                }
                              },
                              displayStringForOption: (item) =>
                                  item.latest.label,
                              fieldViewBuilder: (context, controller,
                                  fieldFocusNode, onFieldSubmitted) {
                                return CustomTextField(
                                  controller: controller,
                                  focusNode: fieldFocusNode,
                                  label: 'animalId'.tr(),
                                  hint: '00000 1234 ',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10),
                                    AnimalFormatter()
                                  ],
                                  onSave: (value) {
                                    _selectedAnimalName =
                                        value.replaceAll(" ", "");
                                    for (var animal in _animals) {
                                      if (animal.latest.label ==
                                          _selectedAnimalName) {
                                        _animal = animal.toEntityModel();
                                      }
                                    }
                                  },
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'emptyFieldValidation'.tr();
                                    }
                                    if ((value?.replaceAll(" ", "").length ??
                                            0) <
                                        9) {
                                      return 'mustEnterValid9DigitsNumber'.tr();
                                    }
                                    return null;
                                  },
                                );
                              },
                            );
                          },
                        ),
                        if (widget.batchInfo == null)
                          const SizedBox(
                            height: 20,
                          ),
                        if (widget.batchInfo == null)
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
                                    if (batch.latest.name ==
                                        _selectedBatchName) {
                                      _batch = batch;
                                    }
                                  }
                                  if (_selectedBatchName == null &&
                                      batches.isNotEmpty) {
                                    _selectedBatchName =
                                        batches.first.latest.name;
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
                                        _currentEstablishment!.id.id,
                                        kBatchTypeKey),
                                onSave: (value) => _batch = value,
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
                          controller: _deviceNameController,
                          label: 'deviceName'.tr(),
                          hint: 'deviceName'.tr(),
                          onSave: (value) => _deviceName = value,
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
                          label: 'secretKey'.tr(),
                          hint: 'deviceSecretKey'.tr(),
                          onSave: (value) => _secretKey = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'emptyFieldValidation'.tr();
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 30,
                        child: CustomOutlinedButton(
                            borderRadius: 10,
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'cancel',
                              style: TextStyle(color: kSecondaryColor),
                            ).tr()),
                      ),
                      SizedBox(
                        width: 120,
                        height: 30,
                        child: MultiBlocListener(
                          listeners: [
                            BlocListener<DevicesCubit, DevicesState>(
                              listener: (context, state) async {
                                if (state is DevicesFail) {
                                  MyDialogs.showErrorDialog(
                                      context, state.message);
                                  if (_isLoading) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                                if (state is GetDeviceSuccess) {
                                  _device = state.device;

                                  // 3. Configure Ear Tag
                                  UserModel? user =
                                      context.read<AuthCubit>().user;
                                  if (_animal != null && _device != null) {
                                    ConfigureEarTagParams configureParams =
                                        ConfigureEarTagParams(
                                            id: _device!.id.id,
                                            createdTime: _device!.createdTime,
                                            name: _device!.name,
                                            label: _animal!.name,
                                            customerId: user!.customerId!.id,
                                            ownerId: user.ownerId.id,
                                            tenantId: user.tenantId.id,
                                            type: kEarTagType,
                                            deviceProfileId:
                                                kDevicesProfiles[kEarTagType]!,
                                            currentInfo:
                                                _device!.additionalInfo ?? {},
                                            deviceData:
                                                _device!.deviceData ?? {},
                                            animalId: _animal!.id.id,
                                            batchId: _batch?.entityId.id,
                                            batchName: _batch?.latest.name,
                                            establishmentName:
                                                _currentEstablishment!.name);
                                    context
                                        .read<DevicesCubit>()
                                        .configureDevice(configureParams);
                                  }
                                }
                                if (state is DevicesSuccess) {
                                  Navigator.pop(context, true);
                                  await showDialog(
                                      context: context,
                                      builder: (context) => DialogContainer(
                                          child: EarTagAddedDialog(
                                              device: _animal!)));
                                }
                              },
                            ),
                            BlocListener<AssetsCubit, AssetsState>(
                              listener: (context, state) async {
                                if (state is AssetsFail) {
                                  MyDialogs.showErrorDialog(
                                      context, state.message);
                                  if (_isLoading) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                                if (state is AnimalValidationFail) {
                                  _animal = state.animal.toEntityModel();
                                  bool result =
                                      await MyDialogs.showQuestionDialog(
                                              context: context,
                                              title: 'warning'.tr(),
                                              message: state.message) ??
                                          false;
                                  if (result && mounted) {
                                    context
                                        .read<AssetsCubit>()
                                        .setAssetSuccess(_animal!);
                                  } else {
                                    if (_isLoading) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                }
                                if (state is AnimalValidationSuccess &&
                                    mounted) {
                                  UserModel? user =
                                      context.read<AuthCubit>().user;
                                  AnimalCreateParams animalParams =
                                      AnimalCreateParams(
                                          name: _selectedAnimalName!,
                                          label: _selectedAnimalName!,
                                          customerId: user!.customerId!.id,
                                          ownerId: user.ownerId.id,
                                          tenantId: user.tenantId.id,
                                          parentName:
                                              _currentEstablishment!.name,
                                          type: kAnimalTypeKey,
                                          assetProfileId:
                                              kAssetsProfiles[kAnimalTypeKey]!,
                                          birthday: _batch!.latest
                                              .additionalInfo!['birthday'],
                                          category: _batch!.latest
                                              .additionalInfo!['lotCategory'],
                                          race: _batch!.latest
                                              .additionalInfo!['lotRace'],
                                          animalType: _batch!.latest
                                              .additionalInfo!['lotType'],
                                          batchName: _batch!.latest.name);
                                  context.read<AssetsCubit>().createAsset(
                                      animalParams,
                                      parentId: _currentEstablishment!.id.id);
                                }
                                if (state is AssetsSuccess && mounted) {
                                  _animal = state.asset;
                                  // 2. Claim Ear Tag
                                  if (_device == null) {
                                    ClaimDeviceParams params =
                                        ClaimDeviceParams(
                                            name: _deviceName,
                                            secretKey: _secretKey);
                                    context
                                        .read<DevicesCubit>()
                                        .claimDevice(params);
                                  } else {
                                    context
                                        .read<DevicesCubit>()
                                        .setDeviceClaimed(_device!);
                                  }
                                }
                              },
                            ),
                          ],
                          child: CustomElevatedButton(
                              isLoading: _isLoading,
                              onPressed: () {
                                if (_validateForm()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _claimEarTagFormKey.currentState!.save();

                                  // 1. If selected animal doesn't exists in available animals group
                                  // validate if exists with an attached ear tag
                                  if (_animal == null) {
                                    context
                                        .read<AssetsCubit>()
                                        .validateAnimal(_selectedAnimalName!);
                                  } else {
                                    context
                                        .read<AssetsCubit>()
                                        .setAssetSuccess(_animal!);
                                  }
                                }
                              },
                              borderRadius: 10,
                              child: const Text('add').tr()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    return _claimEarTagFormKey.currentState?.validate() ?? false;
  }
}

class AnimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length == 6) {
          return TextEditingValue(
              text:
                  "${oldValue.text} ${newValue.text.substring(newValue.text.length - 1)}",
              selection:
                  TextSelection.collapsed(offset: newValue.selection.end + 1));
        }
      }
    }
    return newValue;
  }
}
