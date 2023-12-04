import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';

class HourAutomationFormWidget extends StatefulWidget {
  final HourAutomationModel? automation;

  const HourAutomationFormWidget({super.key, this.automation});

  @override
  State<HourAutomationFormWidget> createState() =>
      _HourAutomationFormWidgetState();
}

class _HourAutomationFormWidgetState extends State<HourAutomationFormWidget> {
  final _createHourAutomationFormKey = GlobalKey<FormState>();

  final _recurrenceController = TextEditingController();

  int? _recurrence;
  DateTime? _onDate;
  String? _onDateErrorMessage;
  DateTime? _offDate;
  String? _offDateErrorMessage;
  DateTime? _recurrenceEnd;
  String? _recurrenceEndDateErrorMessage;

  @override
  void initState() {
    _recurrence = widget.automation?.recurrence;
    _recurrenceController.text = _recurrence?.toString() ?? '';
    int? onDateMilli = widget.automation?.onDate;
    if (onDateMilli != null) {
      _onDate = DateTime.fromMillisecondsSinceEpoch(onDateMilli, isUtc: true)
          .toLocal();
    }
    int? offDateMilli = widget.automation?.offDate;
    if (offDateMilli != null) {
      _offDate = DateTime.fromMillisecondsSinceEpoch(offDateMilli, isUtc: true)
          .toLocal();
    }
    int? recurrenceDateMilli = widget.automation?.endOfRecurrenceDate;
    if (recurrenceDateMilli != null) {
      _recurrenceEnd =
          DateTime.fromMillisecondsSinceEpoch(recurrenceDateMilli, isUtc: true)
              .toLocal();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _createHourAutomationFormKey,
      child: Column(
        children: [
          CustomSelectorField(
            onTap: () async {
              var onDate = await showDatePicker(
                context: context,
                locale: context.locale,
                firstDate: DateTime.now()
                    .copyWith(month: 1, hour: 0, minute: 0, day: 1),
                lastDate: DateTime.now()
                    .copyWith(month: 12, hour: 23, minute: 59, day: 31),
                initialDate: _onDate ?? DateTime.now(),
              );
              if (!mounted) {
                return;
              }
              TimeOfDay initialTime =
                  TimeOfDay.fromDateTime(_onDate ?? DateTime.now());
              var onTime = await showTimePicker(
                  context: context, initialTime: initialTime);
              if (onDate is DateTime && onTime is TimeOfDay) {
                setState(() {
                  _onDate = DateTime(onDate.year, onDate.month, onDate.day,
                      onTime.hour, onTime.minute);
                  _onDateErrorMessage = null;
                });
              }
            },
            label: 'controllerOnDate'.tr(),
            errorMessage: _onDateErrorMessage,
            value: _onDate == null
                ? Text(
                    'selectControllerOnDate'.tr(),
                    style: const TextStyle(fontSize: 11),
                  )
                : Text(_getFormattedDate(_onDate!),
                    style: const TextStyle(fontSize: 11)),
          ),
          const SizedBox(
            height: 20,
          ),
          CustomSelectorField(
            onTap: () async {
              var offDate = await showDatePicker(
                context: context,
                locale: context.locale,
                firstDate: DateTime.now()
                    .copyWith(month: 1, hour: 0, minute: 0, day: 1),
                lastDate: DateTime.now()
                    .copyWith(month: 12, hour: 23, minute: 59, day: 31),
                initialDate: _offDate ?? DateTime.now(),
              );
              if (!mounted) {
                return;
              }
              TimeOfDay initialTime =
                  TimeOfDay.fromDateTime(_offDate ?? DateTime.now());
              var offTime = await showTimePicker(
                  context: context, initialTime: initialTime);
              if (offDate is DateTime && offTime is TimeOfDay) {
                setState(() {
                  _offDate = DateTime(offDate.year, offDate.month, offDate.day,
                      offTime.hour, offTime.minute);
                  _offDateErrorMessage = null;
                });
              }
            },
            label: 'controllerOffDate'.tr(),
            errorMessage: _offDateErrorMessage,
            value: _offDate == null
                ? Text('selectControllerOffDate'.tr(),
                    style: const TextStyle(fontSize: 11))
                : Text(_getFormattedDate(_offDate!),
                    style: const TextStyle(fontSize: 11)),
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
                    style: const TextStyle(fontSize: 11))
                : Text(_getFormattedDate(_recurrenceEnd!),
                    style: const TextStyle(fontSize: 11)),
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
                          _createHourAutomationFormKey.currentState!.save();
                          String name = widget.automation?.name ??
                              'byHour_${DateTime.now().millisecondsSinceEpoch}';
                          HourAutomationModel automation = HourAutomationModel(
                              name: name,
                              type: 'hour',
                              recurrence: _recurrence!,
                              endOfRecurrenceDate:
                                  _recurrenceEnd!.millisecondsSinceEpoch,
                              onDate: _onDate!.millisecondsSinceEpoch,
                              offDate: _offDate!.millisecondsSinceEpoch);
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
    bool result = true;
    if (_onDate == null) {
      result = false;
      _onDateErrorMessage = 'emptyStartDateValidation'.tr();
    }
    if (_offDate == null) {
      result = false;
      _offDateErrorMessage = 'emptyEndDateValidation'.tr();
    }
    if (_recurrenceEnd == null) {
      result = false;
      _recurrenceEndDateErrorMessage = 'emptyRecurrenceEndDateValidation'.tr();
    }
    if (result && _onDate!.isAfter(_offDate!)) {
      result = false;
      _onDateErrorMessage = 'startDateIsAfterEndDateValidation'.tr();
      _offDateErrorMessage = 'startDateIsAfterEndDateValidation'.tr();
    }
    if (result && _recurrenceEnd!.isBefore(_offDate!)) {
      result = false;
      _recurrenceEndDateErrorMessage =
          'recurrenceEndDateIsBeforeEndDateValidation'.tr();
    }
    result = result &&
        (_createHourAutomationFormKey.currentState?.validate() ?? false);
    if (!result) {
      setState(() {});
    }
    return result;
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }
}
