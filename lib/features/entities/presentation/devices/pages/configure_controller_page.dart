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
import '../../../../../core/utils/local_storage_helper.dart';
import '../../../../../injector.dart';
import '../../../../user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/params/params.dart';
import '../../assets/cubits/cubits.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class ConfigureControllerPage extends StatefulWidget {
  final EntityModel device;

  const ConfigureControllerPage({super.key, required this.device});

  @override
  State<ConfigureControllerPage> createState() =>
      _ConfigureControllerPageState();
}

class _ConfigureControllerPageState extends State<ConfigureControllerPage> {
  final _configureControllerFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  EntityModel? _currentEstablishment;
  EntityModel? _establishment;

  String _label = '';
  Map<String, dynamic> _position = {};
  String? _positionErrorMessage;
  List<AutomationModel> _automations = [];

  bool _isLoading = false;

  DropdownSelectedState _establishmentsState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntityModel>[]);

  @override
  void initState() {
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    context.read<DropdownCubit>().getEstablishments();
    _nameController.text = _label = widget.device.label ?? '';
    _position = widget.device.additionalInfo?['position'] ?? {};
    _automations =
        AutomationsResponseModel.fromJson(widget.device.additionalInfo ?? {})
            .automations;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - (2 * 84) - 16,
            child: const Text(
              'configureController',
              style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ).tr(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _configureControllerFormKey,
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
                      var result = await context
                          .pushNamed<Map<String, dynamic>>(
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
                            style: TextStyle(fontSize: 11),
                          ).tr()
                        : const Text('viewDevicePosition',
                                style: TextStyle(fontSize: 11))
                            .tr(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'automations',
                style: TextStyle(
                    color: kSecondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ).tr(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(
                    height: 30,
                  ),
                  itemCount: _automations.length,
                  itemBuilder: (BuildContext context, int index) {
                    onEdit() async {
                      var editedAutomation = await showDialog<AutomationModel?>(
                          context: context,
                          builder: (context) => DialogContainer(
                                  child: CreateControllerAutomationPage(
                                automation: _automations[index],
                              )));
                      if (editedAutomation != null) {
                        setState(() {
                          _automations[index] = editedAutomation;
                        });
                      }
                    }

                    onDelete() async {
                      bool result = await MyDialogs.showQuestionDialog(
                            context: context,
                            title: 'delete'.tr(args: [
                              'automation'.tr(),
                            ]),
                            message: 'deleteAutomationMessage'.tr(),
                          ) ??
                          false;
                      if (result && mounted) {
                        setState(() {
                          _automations.removeAt(index);
                        });
                      }
                    }

                    if (_automations[index].type == 'hour') {
                      return HourAutomationWidget(
                        editMode: true,
                        automation: _automations[index] as HourAutomationModel,
                        onEdit: onEdit,
                        onDelete: onDelete,
                      );
                    }
                    if (_automations[index].type == 'sensor') {
                      return SensorAutomationWidget(
                        editMode: true,
                        automation:
                            _automations[index] as SensorAutomationModel,
                        onEdit: onEdit,
                        onDelete: onDelete,
                      );
                    }
                    return Container();
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: 150,
                  height: 35,
                  child: CustomElevatedButton(
                      onPressed: () async {
                        final automation = await showDialog<AutomationModel?>(
                            context: context,
                            builder: (context) => const DialogContainer(
                                child: CreateControllerAutomationPage()));

                        if (automation != null) {
                          setState(() {
                            _automations.add(automation);
                          });
                        }
                      },
                      borderRadius: 10,
                      backgroundColor: kSecondaryColor,
                      child: const Text(
                        'createAutomation',
                        textAlign: TextAlign.center,
                      ).tr()),
                ),
              ],
            ),
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
                  MyDialogs.showErrorDialog(context, state.message.tr());
                }
                if (state is DevicesSuccess) {
                  await MyDialogs.showSuccessDialog(
                      context, 'controllerConfigured'.tr());
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                }
              },
              builder: (context, state) {
                _isLoading = state is DevicesLoading;
                return CustomElevatedButton(
                    isLoading: _isLoading,
                    onPressed: () async {
                      if (_validateForm()) {
                        _configureControllerFormKey.currentState!.save();
                        UserModel? user = context.read<AuthCubit>().user;
                        String token = await injector<LocalStorageHelper>()
                                .readString(kAccessTokenKey) ??
                            '';
                        ConfigureControllerParams params =
                            ConfigureControllerParams(
                                token: token,
                                id: widget.device.id.id,
                                createdTime: widget.device.createdTime,
                                name: widget.device.name,
                                label: _label,
                                customerId: user!.customerId!.id,
                                position: _position,
                                ownerId: user.ownerId.id,
                                tenantId: user.tenantId.id,
                                type: kControllerType,
                                deviceProfileId:
                                    kDevicesProfiles[kControllerType]!,
                                currentInfo:
                                    widget.device.additionalInfo ?? {},
                                deviceData: widget.device.deviceData ?? {},
                                automations: AutomationsResponseModel(
                                    automations: _automations),
                                establishmentName: _establishment!.name);
                        if (mounted) {
                          context
                              .read<DevicesCubit>()
                              .configureDevice(params);
                        }
                      }
                    },
                    borderRadius: 10,
                    child: const Text('configure').tr());
              },
            ),
          ),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  bool _validateForm() {
    if (_position.isEmpty) {
      setState(() {
        _positionErrorMessage = 'emptyFieldValidation'.tr();
      });
      return false;
    }
    return _configureControllerFormKey.currentState?.validate() ?? false;
  }
}
