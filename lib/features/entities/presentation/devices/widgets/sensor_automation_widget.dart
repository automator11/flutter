import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import 'widgets.dart';

class SensorAutomationWidget extends StatelessWidget {
  final SensorAutomationModel automation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool editMode;

  const SensorAutomationWidget(
      {super.key,
      required this.automation,
      this.onEdit,
      this.onDelete,
      this.editMode = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
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
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: const Border.fromBorderSide(
                            BorderSide(color: kInputDefaultBorderColor))),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: const Text(
                            'sensors',
                            style:
                                TextStyle(color: kPrimaryText, fontSize: 12),
                          ).tr(),
                        )),
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
                      'action',
                      style: TextStyle(color: kSecondaryText, fontSize: 12),
                    ).tr(),
                  ),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: const Border.fromBorderSide(
                            BorderSide(color: kInputDefaultBorderColor))),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(
                            automation.action,
                            style:
                                const TextStyle(color: kPrimaryText, fontSize: 12),
                          ).tr(),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 10, left: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'conditions',
              style: TextStyle(
                  color: kPrimaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        if (automation.conditions.isEmpty)
          Align(
            alignment: Alignment.center,
            child: const Text(
              'conditionsEmpty',
              style: TextStyle(
                  color: kSecondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ).tr(),
          ),
        ...automation.conditions
            .map((condition) => AutomationConditionWidget(
                  isFirst: automation.conditions.indexOf(condition) == 0,
                  condition: condition,
                ))
            ,
        if (editMode)
          const SizedBox(
            height: 10,
          ),
        if (editMode)
          Row(
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
      ],
    );
  }
}
