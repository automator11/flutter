import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../../assets/cubits/cubits.dart';

class AddAutomationConditionDialog extends StatefulWidget {
  final AutomationConditionModel? condition;

  const AddAutomationConditionDialog({super.key, this.condition});

  @override
  State<AddAutomationConditionDialog> createState() =>
      _AddAutomationConditionDialogState();
}

class _AddAutomationConditionDialogState
    extends State<AddAutomationConditionDialog> {
  final _createAutomationConditionFormKey = GlobalKey<FormState>();

  final _valueController = TextEditingController();

  EntityModel? _sensor;
  String _operator = 'AND';
  String? _variable;
  String _condition = 'greater';
  dynamic _value;

  DropdownSelectedState _sensorsState = const DropdownSelectedState(
      isLoading: false, error: false, items: <EntityModel>[]);
  DropdownSelectedState _sensorVariablesState = const DropdownSelectedState(
      isLoading: false, error: false, items: <String>[]);

  @override
  void initState() {
    if (widget.condition != null) {
      _operator = widget.condition!.operator;
      _value = widget.condition!.value;
      _valueController.text = _value?.toString() ?? '';
      _condition = widget.condition!.condition;
    }

    context.read<DropdownCubit>().getSensors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 50, 16.0, 16.0),
          child: Form(
            key: _createAutomationConditionFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.condition != null ? 'editCondition' : 'addCondition',
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ).tr(),
                const SizedBox(
                  height: 20,
                ),
                BlocSelector<DropdownCubit, DropdownState,
                    DropdownSelectedState>(
                  selector: (state) {
                    if (state.groupType == 'sensors') {
                      bool isLoading = state is DropdownLoading;
                      bool hasError = state is DropdownFail;
                      List<EntityModel> sensors = [];
                      if (state is DropdownSuccess) {
                        sensors = state.items!;
                        for (EntityModel sensor in sensors) {
                          if (sensor.name == widget.condition?.sensorName) {
                            _sensor = sensor;
                            context
                                .read<DropdownCubit>()
                                .getSensorVariables(sensor.id.id);
                          }
                        }
                        if (_sensor == null && sensors.isNotEmpty) {
                          _sensor = sensors.first;
                          context
                              .read<DropdownCubit>()
                              .getSensorVariables(_sensor!.id.id);
                        }
                      }
                      if (state is DropdownFail) {
                        sensors = [];
                      }
                      _sensorsState = DropdownSelectedState(
                          isLoading: isLoading,
                          error: hasError,
                          items: sensors);
                      return _sensorsState;
                    }
                    return _sensorsState;
                  },
                  builder: (context, state) {
                    return CustomDropDown<EntityModel>(
                      initialValue: _sensor,
                      items: state.items as List<EntityModel>,
                      label: 'sensor'.tr(),
                      hint: '',
                      isLoading: state.isLoading,
                      hasError: state.error,
                      onRefresh: () =>
                          context.read<DropdownCubit>().getSensors(),
                      onChange: (value) => context
                          .read<DropdownCubit>()
                          .getSensorVariables(value!.id.id),
                      onSave: (value) => _sensor = value,
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
                CustomDropDown<String>(
                  initialValue: _operator,
                  items: const ['AND', 'OR'],
                  label: 'operator'.tr(),
                  hint: 'selectOperator',
                  onSave: (value) => _operator = value!,
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
                BlocSelector<DropdownCubit, DropdownState,
                    DropdownSelectedState>(
                  selector: (state) {
                    if (state.groupType == 'telemetry') {
                      bool isLoading = state is DropdownLoading;
                      bool hasError = state is DropdownFail;
                      List<String> variables = [];
                      if (state is DropdownSuccess) {
                        variables = state.textItems!;
                        for (String variable in variables) {
                          if (variable == widget.condition?.variable) {
                            _variable = variable;
                          }
                        }
                        if (_variable == null && variables.isNotEmpty) {
                          _variable = variables.first;
                        }
                      }
                      if (state is DropdownFail) {
                        variables = <String>[];
                      }
                      _sensorVariablesState = DropdownSelectedState(
                          isLoading: isLoading,
                          error: hasError,
                          items: variables);
                      return _sensorVariablesState;
                    }
                    return _sensorVariablesState;
                  },
                  builder: (context, state) {
                    return CustomDropDown<String>(
                      initialValue: _variable,
                      items: state.items as List<String>,
                      label: 'variable'.tr(),
                      hint: '',
                      isLoading: state.isLoading,
                      hasError: state.error,
                      onRefresh: () => context
                          .read<DropdownCubit>()
                          .getSensorVariables(_sensor!.id.id),
                      onSave: (value) => _variable = value!,
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
                CustomDropDown<String>(
                  initialValue: _condition,
                  items: const [
                    'greater',
                    'greaterEqual',
                    'equal',
                    'notEqual',
                    'lesser',
                    'lesserEqual'
                  ],
                  label: 'condition'.tr(),
                  hint: 'selectCondition',
                  onSave: (value) => _condition = value!,
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
                  keyboardType: TextInputType.number,
                  controller: _valueController,
                  label: 'value'.tr(),
                  onSave: (value) => _value = double.tryParse(value),
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
                  height: 45,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 30,
                      child: CustomOutlinedButton(
                          borderRadius: 10,
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          child: const Text(
                            'cancel',
                            style: TextStyle(color: kSecondaryColor),
                          ).tr()),
                    ),
                    SizedBox(
                      width: 120,
                      height: 30,
                      child: CustomElevatedButton(
                          onPressed: () {
                            if (_validateForm()) {
                              _createAutomationConditionFormKey.currentState!
                                  .save();
                              AutomationConditionModel condition =
                                  AutomationConditionModel(
                                      sensorId: _sensor!.id.id,
                                      sensorName: _sensor!.name,
                                      operator: _operator,
                                      variable: _variable!,
                                      condition: _condition,
                                      value: _value!);
                              Navigator.of(context, rootNavigator: true)
                                  .pop(condition);
                            }
                          },
                          borderRadius: 10,
                          child:
                              Text(widget.condition != null ? 'update' : 'add')
                                  .tr()),
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
      ),
    );
  }

  bool _validateForm() {
    return _createAutomationConditionFormKey.currentState?.validate() ?? false;
  }
}
