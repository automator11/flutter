import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';


import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';

class HourAutomationWidget extends StatelessWidget {
  final HourAutomationModel automation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool editMode;

  const HourAutomationWidget(
      {super.key,
      required this.automation,
      this.onEdit,
      this.onDelete,
      this.editMode = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 6),
          child: const Text(
            'type',
            style: TextStyle(color: kSecondaryText, fontSize: 12),
          ).tr(),
        ),
        Container(
          constraints: const BoxConstraints.expand(height: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: const Border.fromBorderSide(
                  BorderSide(color: kInputDefaultBorderColor))),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: const Text(
                  'schedules',
                  style: TextStyle(color: kPrimaryText, fontSize: 12),
                ).tr(),
              )),
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6),
                    child: const Text(
                      'from',
                      style: TextStyle(color: kSecondaryText, fontSize: 12),
                    ).tr(),
                  ),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: const Border.fromBorderSide(
                              BorderSide(color: kInputDefaultBorderColor))),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/calendar_blue.png',
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  _getFormattedDate(automation.onDate),
                                  style: const TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/time_blue.png',
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(_getFormattedTime(automation.onDate),
                                    style: const TextStyle(fontSize: 12))
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6),
                    child: const Text(
                      'to',
                      style: TextStyle(color: kSecondaryText, fontSize: 12),
                    ).tr(),
                  ),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: const Border.fromBorderSide(
                              BorderSide(color: kInputDefaultBorderColor))),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/calendar_blue.png',
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(_getFormattedDate(automation.offDate),
                                    style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/time_blue.png',
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(_getFormattedTime(automation.offDate),
                                    style: const TextStyle(fontSize: 12))
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6),
                    child: const Text(
                      'isRepeated',
                      style: TextStyle(color: kSecondaryText, fontSize: 12),
                    ).tr(),
                  ),
                  Container(
                    constraints: const BoxConstraints.expand(height: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: const Border.fromBorderSide(
                            BorderSide(color: kInputDefaultBorderColor))),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(_getRecurrenceString(),
                                  style: const TextStyle(fontSize: 12))
                              .tr(args: [automation.recurrence.toString()]),
                        )),
                  ),
                  if (editMode)
                    const SizedBox(
                      height: 10,
                    ),
                  if (editMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleButton(
                              onTap: onEdit,
                              backgroundColor: kPrimaryColor,
                              elevation: 0,
                              icon: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Ionicons.pencil_outline,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          CircleButton(
                              onTap: onDelete,
                              backgroundColor: kSecondaryColor,
                              elevation: 0,
                              icon: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Ionicons.trash_outline,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ))
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6),
                    child: const Text(
                      'recurrenceEnd',
                      style: TextStyle(color: kSecondaryText, fontSize: 12),
                    ).tr(),
                  ),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: const Border.fromBorderSide(
                              BorderSide(color: kInputDefaultBorderColor))),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/calendar_blue.png',
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    _getFormattedDate(
                                        automation.endOfRecurrenceDate),
                                    style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/time_blue.png',
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    _getFormattedTime(
                                        automation.endOfRecurrenceDate),
                                    style: const TextStyle(fontSize: 12))
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getFormattedDate(int dateInMilliseconds) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInMilliseconds);
    return DateFormat.yMd().format(date);
  }

  String _getFormattedTime(int dateInMilliseconds) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInMilliseconds);
    return DateFormat.jm().format(date);
  }

  String _getRecurrenceString() {
    if (automation.recurrence == 0) {
      return 'No';
    }
    if (automation.recurrence == 1) {
      return 'everyDay';
    }
    if (automation.recurrence == 7) {
      return 'everyWeek';
    }
    return 'everyNDays';
  }
}
