import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/utils/utils.dart';

class SelectTimeIntervalDialog extends StatefulWidget {
  const SelectTimeIntervalDialog({super.key});

  @override
  State<SelectTimeIntervalDialog> createState() =>
      _SelectTimeIntervalDialogState();
}

class _SelectTimeIntervalDialogState extends State<SelectTimeIntervalDialog> {
  final _timeIntervalFormKey = GlobalKey<FormState>();

  DateTime? _startDate;
  String? _startDateErrorMessage;
  DateTime? _endDate;
  String? _endDateErrorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 50, 16.0, 16.0),
                  child: Form(
                    key: _timeIntervalFormKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text(
                        'selectTimeInterval',
                        style: TextStyle(
                            color: kSecondaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ).tr(),
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
                            lastDate: DateTime.now().copyWith(
                                month: 12, hour: 23, minute: 59, day: 31),
                            initialDate: _startDate ?? DateTime.now(),
                          );
                          if (!mounted) {
                            return;
                          }
                          TimeOfDay initialTime = TimeOfDay.fromDateTime(
                              _startDate ?? DateTime.now());
                          var startTime = await showTimePicker(
                              context: context, initialTime: initialTime);
                          if (startDate is DateTime && startTime is TimeOfDay) {
                            setState(() {
                              _startDate = DateTime(
                                  startDate.year,
                                  startDate.month,
                                  startDate.day,
                                  startTime.hour,
                                  startTime.minute);
                              _startDateErrorMessage = null;
                            });
                          }
                        },
                        label: 'start'.tr(),
                        errorMessage: _startDateErrorMessage,
                        value: _startDate == null
                            ? Text('selectIntervalStartDate'.tr())
                            : Text(Utils.getLongDate(_startDate!)),
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
                            lastDate: DateTime.now().copyWith(
                                month: 12, hour: 23, minute: 59, day: 31),
                            initialDate: _endDate ?? DateTime.now(),
                          );
                          if (!mounted) {
                            return;
                          }
                          TimeOfDay initialTime = TimeOfDay.fromDateTime(
                              _endDate ?? DateTime.now());
                          var endTime = await showTimePicker(
                              context: context, initialTime: initialTime);
                          if (endDate is DateTime && endTime is TimeOfDay) {
                            setState(() {
                              _endDate = DateTime(endDate.year, endDate.month,
                                  endDate.day, endTime.hour, endTime.minute);
                              _endDateErrorMessage = null;
                            });
                          }
                        },
                        label: 'end'.tr(),
                        errorMessage: _endDateErrorMessage,
                        value: _endDate == null
                            ? Text('selectIntervalEndDate'.tr())
                            : Text(Utils.getLongDate(_endDate!)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 42,
                            child: CustomOutlinedButton(
                                borderRadius: 10,
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(),
                                child: const Text(
                                  'cancel',
                                  style: TextStyle(color: kSecondaryColor),
                                ).tr()),
                          ),
                          SizedBox(
                              width: 120,
                              height: 42,
                              child: CustomElevatedButton(
                                  onPressed: () async {
                                    if (_validateForm()) {
                                      _timeIntervalFormKey.currentState!.save();
                                      Navigator.of(context, rootNavigator: true)
                                          .pop({
                                        'startDate': _startDate,
                                        'endDate': _endDate
                                      });
                                    }
                                  },
                                  borderRadius: 10,
                                  child: const Text('select').tr())),
                        ],
                      )
                    ]),
                  ),
                ),
                Positioned(
                    top: 16,
                    right: 16,
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircleButton(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        icon: const Icon(
                          Ionicons.close_outline,
                          color: kIconLightColor,
                          size: 18,
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    bool result = true;
    if (_startDate == null) {
      result = false;
      _startDateErrorMessage = 'emptyStartDateValidation'.tr();
    }
    if (_endDate == null) {
      result = false;
      _endDateErrorMessage = 'emptyEndDateValidation'.tr();
    }
    if (result && _startDate!.isAfter(_endDate!)) {
      result = false;
      _startDateErrorMessage = 'startDateIsAfterEndDateValidation'.tr();
      _endDateErrorMessage = 'startDateIsAfterEndDateValidation'.tr();
    }
    result = result && (_timeIntervalFormKey.currentState?.validate() ?? false);
    if (!result) {
      setState(() {});
    }
    return result;
  }
}
