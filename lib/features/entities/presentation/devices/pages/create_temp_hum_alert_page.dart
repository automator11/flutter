import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';

class CreateTempHumAlertPage extends StatefulWidget {
  final AlertModel? alert;

  const CreateTempHumAlertPage({super.key, this.alert});

  @override
  State<CreateTempHumAlertPage> createState() => _CreateTempHumAlertPageState();
}

class _CreateTempHumAlertPageState extends State<CreateTempHumAlertPage> {
  final _createAlertFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _valueController = TextEditingController();

  String _name = '';
  String? _level;
  String? _variable;
  String? _condition;
  double? _value;

  @override
  void initState() {
    _nameController.text = _name = widget.alert?.name ?? '';
    _variable = widget.alert?.variable;
    _value = widget.alert?.value;
    _valueController.text = _value?.toString() ?? '';
    _level = widget.alert?.level;
    _condition = widget.alert?.condition;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - (2 * 84) - 16,
              child: Text(
                widget.alert != null ? 'editAlert' : 'createAlert',
                style: const TextStyle(
                    color: kSecondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _createAlertFormKey,
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
                    CustomDropDown<String>(
                      initialValue: _level,
                      items: const [
                        'UNDETERMINED',
                        'DANGER',
                        'MINOR',
                        'MAJOR',
                        'CRITICAL'
                      ],
                      label: 'level'.tr(),
                      hint: 'selectLevel'.tr(),
                      onSave: (value) => _level = value!,
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
                    CustomDropDown<String>(
                      initialValue: _variable,
                      items: const ['temperature', 'humidity'],
                      label: 'variable'.tr(),
                      hint: 'selectVariable'.tr(),
                      onSave: (value) => _variable = value!,
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
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(),
                              child: const Text(
                                'cancel',
                                style: TextStyle(
                                    color: kSecondaryColor, fontSize: 12),
                              ).tr()),
                        ),
                        SizedBox(
                          width: 120,
                          height: 30,
                          child: CustomElevatedButton(
                              onPressed: () {
                                if (_validateForm()) {
                                  _createAlertFormKey.currentState!.save();
                                  AlertModel alert = AlertModel(
                                      name: _name,
                                      level: _level!,
                                      variable: _variable!,
                                      condition: _condition!,
                                      value: _value!);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(alert);
                                }
                              },
                              borderRadius: 10,
                              child: Text(
                                widget.alert != null ? 'update' : 'create',
                                style: const TextStyle(fontSize: 12),
                              ).tr()),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    return _createAlertFormKey.currentState?.validate() ?? false;
  }
}
