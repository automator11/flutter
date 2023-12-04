import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/local_storage_helper.dart';
import '../../../../../injector.dart';
import '../../../../user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/params/params.dart';
import '../cubits/cubits.dart';

class EditRotationContentWidget extends StatefulWidget {
  final EntityModel? asset;

  const EditRotationContentWidget({super.key, this.asset});

  @override
  State<EditRotationContentWidget> createState() =>
      _EditRotationContentWidgetState();
}

class _EditRotationContentWidgetState extends State<EditRotationContentWidget> {
  final _updateRotationFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _recurrenceController = TextEditingController();

  EntityModel? _currentEstablishment;

  String _name = '';
  EntitySearchModel? _paddock;
  String _paddockName = '';
  EntitySearchModel? _batch;
  String _batchName = '';
  int? _recurrence;
  DateTime? _startDate;
  String? _rotationStartDateErrorMessage;
  DateTime? _endDate;
  String? _rotationEndDateErrorMessage;
  DateTime? _recurrenceEnd;
  String? _recurrenceEndDateErrorMessage;

  bool _isLoading = false;

  DropdownSelectedState _availablePaddocksState =
      const DropdownSelectedState(isLoading: false, error: false, items: []);
  DropdownSelectedState _availableBatchesState =
      const DropdownSelectedState(isLoading: false, error: false, items: []);

  @override
  void initState() {
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    if (widget.asset != null) {
      _nameController.text = _name = widget.asset!.label ?? '';
      _recurrence = widget.asset!.additionalInfo?['recurrence'];
      _recurrenceController.text = _recurrence.toString();
      _paddockName = widget.asset!.additionalInfo?['parcelName'] ?? '';
      _batchName = widget.asset!.additionalInfo?['lotName'] ?? '';
      int? startDateMilli = widget.asset!.additionalInfo?['startDate'];
      if (startDateMilli != null) {
        _startDate =
            DateTime.fromMillisecondsSinceEpoch(startDateMilli, isUtc: true)
                .toLocal();
      }
      int? endDateMilli = widget.asset!.additionalInfo?['endDate'];
      if (endDateMilli != null) {
        _endDate =
            DateTime.fromMillisecondsSinceEpoch(endDateMilli, isUtc: true)
                .toLocal();
      }
      int? recurrenceDateMilli =
          widget.asset!.additionalInfo?['recurrenceEndTime'];
      if (recurrenceDateMilli != null) {
        _recurrenceEnd = DateTime.fromMillisecondsSinceEpoch(
                recurrenceDateMilli,
                isUtc: true)
            .toLocal();
      }
    }

    DropdownCubit cubit = context.read<DropdownCubit>();
    cubit.getAssetsByGroupName(kAvailablePaddocksName);
    cubit.getAssetsByParentId(_currentEstablishment!.id.id, kBatchTypeKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Form(
        key: _updateRotationFormKey,
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
                if (state.groupType == kAvailablePaddocksName) {
                  bool isLoading = state is DropdownLoading;
                  bool hasError = state is DropdownFail;
                  List<EntitySearchModel> paddocks = [];
                  if (state is DropdownSuccess) {
                    paddocks = state.searchItems!;
                  }
                  if (state is DropdownFail) {
                    paddocks = [];
                  }
                  _availablePaddocksState = DropdownSelectedState(
                      isLoading: isLoading, error: hasError, items: paddocks);
                  return _availablePaddocksState;
                }
                return _availablePaddocksState;
              },
              builder: (context, state) {
                if (state.items.isNotEmpty) {
                  for (var element in state.items) {
                    if ((element as EntitySearchModel).latest.name ==
                        _paddockName) {
                      _paddock = element;
                      continue;
                    }
                  }
                }
                return CustomDropDown(
                  initialValue: _paddock,
                  items: state.items,
                  label: 'paddock'.tr(),
                  hint: '',
                  isLoading: state.isLoading,
                  hasError: state.error,
                  onRefresh: () => context
                      .read<DropdownCubit>()
                      .getAssetsByGroupId(kAvailablePaddocksName),
                  onSave: (value) => _paddock = value,
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
            BlocSelector<DropdownCubit, DropdownState, DropdownSelectedState>(
              selector: (state) {
                if (state.groupType == kBatchTypeKey) {
                  bool isLoading = state is DropdownLoading;
                  bool hasError = state is DropdownFail;
                  List<EntitySearchModel> batches = [];
                  if (state is DropdownSuccess) {
                    batches = state.searchItems!;
                  }
                  if (state is DropdownFail) {
                    batches = [];
                  }
                  _availableBatchesState = DropdownSelectedState(
                      isLoading: isLoading, error: hasError, items: batches);
                  return _availableBatchesState;
                }
                return _availableBatchesState;
              },
              builder: (context, state) {
                if (state.items.isNotEmpty) {
                  for (var element in state.items) {
                    if ((element as EntitySearchModel).latest.name ==
                        _batchName) {
                      _batch = element;
                      continue;
                    }
                  }
                }
                return CustomDropDown(
                  initialValue: _batch,
                  items: state.items,
                  label: 'batch'.tr(),
                  hint: '',
                  isLoading: state.isLoading,
                  hasError: state.error,
                  onRefresh: () => context
                      .read<DropdownCubit>()
                      .getAssetsByParentId(
                          _currentEstablishment!.id.id, kBatchTypeKey),
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
            CustomSelectorField(
              onTap: () async {
                var startDate = await showDatePicker(
                  context: context,
                  locale: context.locale,
                  firstDate: DateTime.now()
                      .copyWith(month: 1, hour: 0, minute: 0, day: 1),
                  lastDate: DateTime.now()
                      .copyWith(month: 12, hour: 23, minute: 59, day: 31),
                  initialDate: _startDate ?? DateTime.now(),
                );
                if (!mounted) {
                  return;
                }
                TimeOfDay initialTime =
                    TimeOfDay.fromDateTime(_startDate ?? DateTime.now());
                var startTime = await showTimePicker(
                    context: context, initialTime: initialTime);
                if (startDate is DateTime && startTime is TimeOfDay) {
                  setState(() {
                    _startDate = DateTime(startDate.year, startDate.month,
                        startDate.day, startTime.hour, startTime.minute);
                    _rotationStartDateErrorMessage = null;
                  });
                }
              },
              label: 'startDate'.tr(),
              errorMessage: _rotationStartDateErrorMessage,
              value: _startDate == null
                  ? Text('selectRotationStartDate'.tr(),
                      style: const TextStyle(fontSize: 12))
                  : Text(_getFormattedDate(_startDate!),
                      style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomSelectorField(
              onTap: () async {
                var endDate = await showDatePicker(
                  context: context,
                  locale: context.locale,
                  firstDate: DateTime.now()
                      .copyWith(month: 1, hour: 0, minute: 0, day: 1),
                  lastDate: DateTime.now()
                      .copyWith(month: 12, hour: 23, minute: 59, day: 31),
                  initialDate: _endDate ?? DateTime.now(),
                );
                if (!mounted) {
                  return;
                }
                TimeOfDay initialTime =
                    TimeOfDay.fromDateTime(_endDate ?? DateTime.now());
                var endTime = await showTimePicker(
                    context: context, initialTime: initialTime);
                if (endDate is DateTime && endTime is TimeOfDay) {
                  setState(() {
                    _endDate = DateTime(endDate.year, endDate.month,
                        endDate.day, endTime.hour, endTime.minute);
                    _rotationEndDateErrorMessage = null;
                  });
                }
              },
              label: 'endDate'.tr(),
              errorMessage: _rotationEndDateErrorMessage,
              value: _endDate == null
                  ? Text('selectRotationEndDate'.tr(),
                      style: const TextStyle(fontSize: 12))
                  : Text(_getFormattedDate(_endDate!),
                      style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
              controller: _recurrenceController,
              keyboardType: TextInputType.number,
              label: '${'recurrence'.tr()} (${'days'.tr()})',
              onSave: (value) => _recurrence = int.tryParse(value),
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
            CustomSelectorField(
              onTap: () async {
                var recurrenceDate = await showDatePicker(
                  context: context,
                  locale: context.locale,
                  firstDate: DateTime.now()
                      .copyWith(month: 1, hour: 0, minute: 0, day: 1),
                  lastDate: DateTime.now()
                      .copyWith(month: 12, hour: 23, minute: 59, day: 31),
                  initialDate: _recurrenceEnd ?? DateTime.now(),
                );
                if (!mounted) {
                  return;
                }
                TimeOfDay initialTime =
                    TimeOfDay.fromDateTime(_recurrenceEnd ?? DateTime.now());
                var recurrenceTime = await showTimePicker(
                    context: context, initialTime: initialTime);
                if (recurrenceDate is DateTime && recurrenceTime is TimeOfDay) {
                  setState(() {
                    _recurrenceEnd = DateTime(
                        recurrenceDate.year,
                        recurrenceDate.month,
                        recurrenceDate.day,
                        recurrenceTime.hour,
                        recurrenceTime.minute);
                    _recurrenceEndDateErrorMessage = null;
                  });
                }
              },
              label: 'recurrenceEndDate'.tr(),
              errorMessage: _recurrenceEndDateErrorMessage,
              value: _recurrenceEnd == null
                  ? Text('selectRecurrenceEndDate'.tr(),
                      style: const TextStyle(fontSize: 12))
                  : Text(_getFormattedDate(_recurrenceEnd!),
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
                            ? 'rotationUpdated'.tr()
                            : 'rotationCreated'.tr());
                    if (mounted) {
                      Navigator.pop(context, state.asset);
                    }
                  }
                  if (state is BatchValidationSuccess && mounted) {
                    UserModel? user = context.read<AuthCubit>().user;
                    EntityModel? parent =
                        context.read<AppStateCubit>().currentEstablishment;
                    String token = await injector<LocalStorageHelper>()
                            .readString(kAccessTokenKey) ??
                        '';
                    if (widget.asset != null) {
                      _updateAsset(user, parent, token);
                      return;
                    }
                    _createAsset(user, parent, token);
                  }
                },
                builder: (context, state) {
                  _isLoading = state is AssetsLoading;
                  return CustomElevatedButton(
                      isLoading: _isLoading,
                      onPressed: () async {
                        if (_validateForm()) {
                          _updateRotationFormKey.currentState!.save();

                          FindBatchRelatedRotationsParams params =
                              FindBatchRelatedRotationsParams(
                                  currentBatchId: widget.asset?.id.id,
                                  batchId: _batch!.entityId.id,
                                  batchName: _batch!.latest.name,
                                  startDate: _startDate!,
                                  endDate: _endDate!);

                          context.read<AssetsCubit>().validateBatch(params);
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

  void _createAsset(UserModel? user, EntityModel? parent, String token) {
    RotationCreateParams params = RotationCreateParams(
        token: token,
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kRotationTypeKey,
        assetProfileId: kAssetsProfiles[kRotationTypeKey]!,
        parcelName: _paddock!.latest.name,
        parcelLabel: _paddock!.latest.label,
        lotName: _batch!.latest.name,
        lotLabel: _batch!.latest.label,
        batchId: _batch!.entityId.id,
        startDate: _startDate!.toUtc().millisecondsSinceEpoch,
        endDate: _endDate!.toUtc().millisecondsSinceEpoch,
        recurrenceEndTime: _recurrenceEnd!.toUtc().millisecondsSinceEpoch,
        recurrence: _recurrence!);
    context.read<AssetsCubit>().createAsset(params, parentId: parent.id.id);
  }

  void _updateAsset(UserModel? user, EntityModel? parent, String token) {
    RotationUpdateParams params = RotationUpdateParams(
        token: token,
        id: widget.asset!.id.id,
        createdTime: widget.asset!.createdTime,
        name: _name.toLowerCase(),
        label: _name,
        customerId: user!.customerId!.id,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        parentName: parent!.name,
        type: kRotationTypeKey,
        assetProfileId: kAssetsProfiles[kRotationTypeKey]!,
        parcelName: _paddock!.latest.name,
        parcelLabel: _paddock!.latest.label,
        lotName: _batch!.latest.name,
        lotLabel: _batch!.latest.label,
        batchId: _batch!.entityId.id,
        startDate: _startDate!.toUtc().millisecondsSinceEpoch,
        endDate: _endDate!.toUtc().millisecondsSinceEpoch,
        recurrenceEndTime: _recurrenceEnd!.toUtc().millisecondsSinceEpoch,
        recurrence: _recurrence!);
    context.read<AssetsCubit>().updateAsset(params, parentId: parent.id.id);
  }

  bool _validateForm() {
    bool result = true;
    if (_startDate == null) {
      result = false;
      _rotationStartDateErrorMessage = 'emptyStartDateValidation'.tr();
    }
    if (_endDate == null) {
      result = false;
      _rotationEndDateErrorMessage = 'emptyEndDateValidation'.tr();
    }
    if (_recurrenceEnd == null) {
      result = false;
      _recurrenceEndDateErrorMessage = 'emptyRecurrenceEndDateValidation'.tr();
    }
    if (result && _startDate!.isAfter(_endDate!)) {
      result = false;
      _rotationStartDateErrorMessage = 'startDateIsAfterEndDateValidation'.tr();
      _rotationEndDateErrorMessage = 'startDateIsAfterEndDateValidation'.tr();
    }
    if (result && _recurrenceEnd!.isBefore(_endDate!)) {
      result = false;
      _recurrenceEndDateErrorMessage =
          'recurrenceEndDateIsBeforeEndDateValidation'.tr();
    }
    result =
        result && (_updateRotationFormKey.currentState?.validate() ?? false);
    if (!result) {
      setState(() {});
    }
    return result;
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }
}
