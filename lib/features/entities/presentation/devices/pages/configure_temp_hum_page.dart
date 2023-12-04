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
import '../widgets/widgets.dart';
import 'pages.dart';

class ConfigureTempHumPage extends StatefulWidget {
  final EntityModel device;

  const ConfigureTempHumPage({super.key, required this.device});

  @override
  State<ConfigureTempHumPage> createState() => _ConfigureTempHumPageState();
}

class _ConfigureTempHumPageState extends State<ConfigureTempHumPage> {
  final _configureTempHumFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  String _label = '';
  Map<String, dynamic> _position = {};
  String? _positionErrorMessage;
  List<AlertModel> _alerts = [];

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
    _position = widget.device.additionalInfo?['position'] ?? {};
    _alerts =
        AlertsResponseModel.fromJson(widget.device.additionalInfo ?? {}).alerts;
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
              'configureTempHum',
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _configureTempHumFormKey,
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
                      : const Text(
                          'viewDevicePosition',
                          style: TextStyle(fontSize: 12),
                        ).tr(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'alerts',
              style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ).tr(),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(
                  height: 10,
                ),
                itemCount: _alerts.length,
                itemBuilder: (BuildContext context, int index) {
                  return AlertTileWidget(
                    editMode: true,
                    alert: _alerts[index],
                    onEdit: () async {
                      var editedAlert = await showDialog<AlertModel?>(
                          context: context,
                          builder: (context) => DialogContainer(
                                  child: CreateTempHumAlertPage(
                                alert: _alerts[index],
                              )));
                      if (editedAlert != null) {
                        setState(() {
                          _alerts[index] = editedAlert;
                        });
                      }
                    },
                    onDelete: () async {
                      bool result = await MyDialogs.showQuestionDialog(
                            context: context,
                            title: 'delete'.tr(args: [
                              'alert'.tr(),
                            ]),
                            message: 'deleteAlertMessage'.tr(),
                          ) ??
                          false;
                      if (result && mounted) {
                        setState(() {
                          _alerts.removeAt(index);
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 120,
                height: 30,
                child: CustomElevatedButton(
                    onPressed: () async {
                      final alert = await showDialog<AlertModel?>(
                          context: context,
                          builder: (context) => const DialogContainer(
                              child: CreateTempHumAlertPage()));

                      if (alert != null) {
                        setState(() {
                          _alerts.add(alert);
                        });
                      }
                    },
                    borderRadius: 10,
                    backgroundColor: kSecondaryColor,
                    child: const Text('createAlert').tr()),
              ),
            ],
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
                    context, 'TempHumConfigured'.tr());
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
                      _configureTempHumFormKey.currentState!.save();
                      UserModel? user = context.read<AuthCubit>().user;
                      ConfigureTempHumParams params =
                          ConfigureTempHumParams(
                              id: widget.device.id.id,
                              createdTime: widget.device.createdTime,
                              name: widget.device.name,
                              label: _label,
                              customerId: user!.customerId!.id,
                              position: _position,
                              ownerId: user.ownerId.id,
                              tenantId: user.tenantId.id,
                              type: kTempAndHumidityType,
                              deviceProfileId:
                                  kDevicesProfiles[kTempAndHumidityType]!,
                              currentInfo:
                                  widget.device.additionalInfo ?? {},
                              deviceData: widget.device.deviceData ?? {},
                              alerts: AlertsResponseModel(alerts: _alerts),
                              establishmentName: _establishment!.name);
                      context.read<DevicesCubit>().configureDevice(params);
                    }
                  },
                  borderRadius: 10,
                  child: const Text('configure').tr());
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
    if (_position.isEmpty) {
      setState(() {
        _positionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    return _configureTempHumFormKey.currentState?.validate() ?? false;
  }
}
