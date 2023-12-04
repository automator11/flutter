import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/constants.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/params/params.dart';
import '../cubits/cubits.dart';

class EditBatchContentWidget extends StatefulWidget {
  final EntityModel? asset;

  const EditBatchContentWidget({super.key, this.asset});

  @override
  State<EditBatchContentWidget> createState() => _EditBatchContentWidgetState();
}

class _EditBatchContentWidgetState extends State<EditBatchContentWidget> {
  final _updateBatchFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _totalAnimalsController = TextEditingController();

  String _name = '';
  String? _type;
  String? _category;

  String? _race;
  int? _birthday;
  int? _totalAnimals;

  bool _isLoading = false;

  DropdownSelectedState _typeState =
      const DropdownSelectedState(isLoading: false, error: false, items: []);
  DropdownSelectedState _categoriesState =
      const DropdownSelectedState(isLoading: false, error: false, items: []);
  DropdownSelectedState _racesState =
      const DropdownSelectedState(isLoading: false, error: false, items: []);

  @override
  void initState() {
    if (widget.asset != null) {
      _nameController.text = _name = widget.asset!.label ?? '';
      _birthday = widget.asset!.additionalInfo?['birthday'];
      _birthdayController.text = _birthday?.toString() ?? '';
      _totalAnimals = widget.asset!.additionalInfo?['totalAnimals'];
      _totalAnimalsController.text = _totalAnimals?.toString() ?? '';
      _type = widget.asset!.additionalInfo?['lotType'] ?? '';
      _category = widget.asset!.additionalInfo?['lotCategory'] ?? '';
      _race = widget.asset!.additionalInfo?['lotRace'] ?? '';
    }

    DropdownCubit cubit = context.read<DropdownCubit>();
    cubit.getAssetsByGroupId(kBatchTypeGroupId);
    cubit.getAssetsByGroupId(kAnimalCategoryGroupId);
    cubit.getAssetsByGroupId(kAnimalRaceGroupId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Form(
        key: _updateBatchFormKey,
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
            BlocSelector<DropdownCubit, DropdownState, DropdownSelectedState>(
              selector: (state) {
                if (state.groupType == kBatchTypeGroupId) {
                  bool isLoading = state is DropdownLoading;
                  bool hasError = state is DropdownFail;
                  List<String> types = [];
                  if (state is DropdownSuccess) {
                    types = state.items != null
                        ? state.items!
                            .map((e) =>
                                (e.label?.isEmpty ?? true) ? e.name : e.label!)
                            .toList()
                        : <String>[];
                  }
                  if (state is DropdownFail) {
                    types = [];
                  }
                  _typeState = DropdownSelectedState(
                      isLoading: isLoading, error: hasError, items: types);
                  return _typeState;
                }
                return _typeState;
              },
              builder: (context, state) {
                return CustomDropDown(
                  initialValue: _type,
                  items: state.items,
                  label: 'type'.tr(),
                  hint: '',
                  isLoading: state.isLoading,
                  hasError: state.error,
                  onRefresh: () => context
                      .read<DropdownCubit>()
                      .getAssetsByGroupId(kBatchTypeGroupId),
                  onSave: (value) => _type = value,
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
            BlocSelector<DropdownCubit, DropdownState, DropdownSelectedState>(
              selector: (state) {
                if (state.groupType == kAnimalCategoryGroupId) {
                  bool isLoading = state is DropdownLoading;
                  bool hasError = state is DropdownFail;
                  List<String> categories = [];
                  if (state is DropdownSuccess) {
                    categories = state.items != null
                        ? state.items!
                            .map((e) =>
                                (e.label?.isEmpty ?? true) ? e.name : e.label!)
                            .toList()
                        : <String>[];
                  }
                  if (state is DropdownFail) {
                    categories = [];
                  }
                  _categoriesState = DropdownSelectedState(
                      isLoading: isLoading, error: hasError, items: categories);
                  return _categoriesState;
                }
                return _categoriesState;
              },
              builder: (context, state) {
                return CustomDropDown(
                  initialValue: _category,
                  items: state.items,
                  label: 'category'.tr(),
                  hint: '',
                  isLoading: state.isLoading,
                  hasError: state.error,
                  onRefresh: () => context
                      .read<DropdownCubit>()
                      .getAssetsByGroupId(kAnimalCategoryGroupId),
                  onSave: (value) => _category = value,
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
            BlocSelector<DropdownCubit, DropdownState, DropdownSelectedState>(
              selector: (state) {
                if (state.groupType == kAnimalRaceGroupId) {
                  bool isLoading = state is DropdownLoading;
                  bool hasError = state is DropdownFail;
                  List<String> races = [];
                  if (state is DropdownSuccess) {
                    races = state.items != null
                        ? state.items!
                            .map((e) =>
                                (e.label?.isEmpty ?? true) ? e.name : e.label!)
                            .toList()
                        : <String>[];
                  }
                  if (state is DropdownFail) {
                    races = [];
                  }
                  _racesState = DropdownSelectedState(
                      isLoading: isLoading, error: hasError, items: races);
                  return _racesState;
                }
                return _racesState;
              },
              builder: (context, state) {
                return CustomDropDown(
                  initialValue: _race,
                  items: state.items,
                  label: 'race'.tr(),
                  hint: '',
                  isLoading: state.isLoading,
                  hasError: state.error,
                  onRefresh: () => context
                      .read<DropdownCubit>()
                      .getAssetsByGroupId(kAnimalRaceGroupId),
                  onSave: (value) => _race = value,
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
            CustomTextField(
              controller: _birthdayController,
              label: 'birthday'.tr(),
              onSave: (value) => _birthday = int.tryParse(value),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'emptyFieldValidation'.tr();
                }
                if (int.tryParse(value!) == null) {
                  return 'invalidIntegerValidation'.tr();
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
              controller: _totalAnimalsController,
              label: 'totalAnimals'.tr(),
              onSave: (value) => _totalAnimals = int.tryParse(value),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'emptyFieldValidation'.tr();
                }
                if (int.tryParse(value!) == null) {
                  return 'invalidIntegerValidation'.tr();
                }
                return null;
              },
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
                            ? 'batchUpdated'.tr()
                            : 'batchCreated'.tr());
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
                          _updateBatchFormKey.currentState!.save();
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
    BatchCreateParams params = BatchCreateParams(
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kBatchTypeKey,
        assetProfileId: kAssetsProfiles[kBatchTypeKey]!,
        birthday: _birthday!,
        lotCategory: _category!,
        lotRace: _race!,
        lotType: _type!,
        totalAnimals: _totalAnimals!);
    context.read<AssetsCubit>().createAsset(params, parentId: parent.id.id);
  }

  void _updateAsset(UserModel? user, EntityModel? parent) {
    BatchUpdateParams params = BatchUpdateParams(
        id: widget.asset!.id.id,
        createdTime: widget.asset!.createdTime,
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kBatchTypeKey,
        assetProfileId: kAssetsProfiles[kBatchTypeKey]!,
        birthday: _birthday!,
        lotCategory: _category!,
        lotRace: _race!,
        lotType: _type!,
        totalAnimals: _totalAnimals!);
    context.read<AssetsCubit>().updateAsset(params, parentId: parent.id.id);
  }

  bool _validateForm() {
    return _updateBatchFormKey.currentState?.validate() ?? false;
  }
}
