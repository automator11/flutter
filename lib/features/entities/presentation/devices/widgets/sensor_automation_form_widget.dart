import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../injector.dart';
import '../../../data/models/models.dart';
import '../../assets/cubits/cubits.dart';
import 'widgets.dart';

class SensorAutomationFormWidget extends StatefulWidget {
  final SensorAutomationModel? automation;

  const SensorAutomationFormWidget({super.key, this.automation});

  @override
  State<SensorAutomationFormWidget> createState() =>
      _SensorAutomationFormWidgetState();
}

class _SensorAutomationFormWidgetState
    extends State<SensorAutomationFormWidget> {
  final _createSensorAutomationFormKey = GlobalKey<FormState>();

  String _action = 'ON';
  List<AutomationConditionModel> _conditions = [];

  @override
  void initState() {
    if (widget.automation != null) {
      _action = widget.automation!.action;
      _conditions = widget.automation!.conditions;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _createSensorAutomationFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropDown<String>(
            initialValue: _action,
            items: const ['ON', 'OFF'],
            label: 'action'.tr(),
            hint: 'selectAction'.tr(),
            onSave: (value) => _action = value!,
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
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 12),
            child: Text(
              'conditions',
              style: TextStyle(
                  color: kPrimaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if (_conditions.isEmpty)
            Align(
              alignment: Alignment.center,
              child: const Text(
                'conditionsEmpty',
                style: TextStyle(
                    color: kSecondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ).tr(),
            ),
          ..._conditions
              .map((condition) => AutomationConditionWidget(
                    isFirst: _conditions.indexOf(condition) == 0,
                    condition: condition,
                    editMode: true,
                    onDelete: () {
                      setState(() {
                        _conditions.remove(condition);
                      });
                    },
                    onEdit: () async {
                      final editedCondition =
                          await showDialog<AutomationConditionModel?>(
                              context: context,
                              builder: (context) => BlocProvider(
                                    create: (context) =>
                                        injector<DropdownCubit>(),
                                    child: AddAutomationConditionDialog(
                                      condition: condition,
                                    ),
                                  ));
                      if (editedCondition != null) {
                        setState(() {
                          _conditions.remove(condition);
                          _conditions.add(editedCondition);
                        });
                      }
                    },
                  ))
              ,
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 150,
              height: 35,
              child: CustomElevatedButton(
                  onPressed: () async {
                    final condition =
                        await showDialog<AutomationConditionModel?>(
                            context: context,
                            builder: (context) => BlocProvider(
                                  create: (context) =>
                                      injector<DropdownCubit>(),
                                  child: const AddAutomationConditionDialog(),
                                ));
                    if (condition != null) {
                      setState(() {
                        _conditions.add(condition);
                      });
                    }
                  },
                  borderRadius: 10,
                  backgroundColor: kSecondaryColor,
                  child: const Text(
                    'addCondition',
                    style: TextStyle(fontSize: 12),
                  ).tr()),
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
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: const Text(
                      'cancel',
                      style: TextStyle(color: kSecondaryColor, fontSize: 12),
                    ).tr()),
              ),
              SizedBox(
                  width: 120,
                  height: 30,
                  child: CustomElevatedButton(
                      onPressed: () async {
                        if (_validateForm()) {
                          _createSensorAutomationFormKey.currentState!.save();
                          String name = widget.automation?.name ??
                              'bySensor_${DateTime.now().millisecondsSinceEpoch}';
                          SensorAutomationModel automation =
                              SensorAutomationModel(
                                  name: name,
                                  type: 'sensor',
                                  action: _action,
                                  conditions: _conditions);
                          Navigator.of(context, rootNavigator: true)
                              .pop(automation);
                        }
                      },
                      borderRadius: 10,
                      child: Text(
                        widget.automation != null ? 'update' : 'add',
                        style: const TextStyle(fontSize: 12),
                      ).tr())),
            ],
          )
        ],
      ),
    );
  }

  bool _validateForm() {
    return _createSensorAutomationFormKey.currentState?.validate() ?? false;
  }
}
