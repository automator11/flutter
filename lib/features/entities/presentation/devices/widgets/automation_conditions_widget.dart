import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';

class AutomationConditionWidget extends StatelessWidget {
  final AutomationConditionModel condition;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool editMode;
  final bool isFirst;

  const AutomationConditionWidget(
      {super.key,
      required this.condition,
      this.editMode = false,
      this.onEdit,
      this.onDelete,
      this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              condition.operator,
              style: const TextStyle(
                  color: kSecondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: '${'sensor'.tr()}: ',
                    style: const TextStyle(color: kSecondaryText, fontSize: 12)),
                TextSpan(
                    text: condition.sensorName,
                    style: const TextStyle(
                        color: kSecondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700))
              ])),
            ),
            if (editMode)
              const SizedBox(
                width: 20,
              ),
            if (editMode)
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
            if (editMode)
              const SizedBox(
                width: 10,
              ),
            if (editMode)
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
                  )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: const Border.fromBorderSide(
                        BorderSide(color: kInputDefaultBorderColor))),
                child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        condition.variable,
                        style: const TextStyle(color: kPrimaryText, fontSize: 12),
                      ).tr(),
                    )),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Container(
              height: 30,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: const Border.fromBorderSide(
                      BorderSide(color: kInputDefaultBorderColor))),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _getCondition(condition.condition),
                    style: const TextStyle(color: kPrimaryText, fontSize: 16),
                  ).tr()),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              height: 30,
              constraints: const BoxConstraints(minWidth: 60),
              decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: const Border.fromBorderSide(
                      BorderSide(color: kInputDefaultBorderColor))),
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      condition.value.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ).tr(),
                  )),
            ),
          ],
        ),
      ],
    );
  }

  String _getCondition(String condition) {
    switch (condition) {
      case 'greater':
        return ' > ';
      case 'greaterEqual':
        return ' >= ';
      case 'equal':
        return ' = ';
      case 'notEqual':
        return ' != ';
      case 'lesser':
        return ' < ';
      case 'lesserEqual':
        return ' <= ';
      default:
        return '';
    }
  }
}
