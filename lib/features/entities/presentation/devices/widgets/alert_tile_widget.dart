import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';

class AlertTileWidget extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool editMode;

  const AlertTileWidget(
      {super.key,
      required this.alert,
      this.onEdit,
      this.onDelete,
      this.editMode = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      alert.name,
                      style: const TextStyle(
                        color: kSecondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    alert.level,
                    style: TextStyle(color: _getLevelColor(), fontSize: 12),
                  ).tr(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: const Border.fromBorderSide(
                      BorderSide(color: kInputDefaultBorderColor))),
              child: Row(
                children: [
                  Expanded(
                    child: Text(alert.variable,
                            style: const TextStyle(
                                color: kSecondaryText, fontSize: 12))
                        .tr(),
                  ),
                  Text('${_getCondition()} ${alert.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: kSecondaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700))
                ],
              ),
            ),
            if (editMode)
              const SizedBox(
                height: 10,
              ),
            if (editMode)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
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
                            size: 20,
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
                            size: 20,
                          ),
                        ))
                  ],
                ),
              ),
          ],
        ));
  }

  Color _getLevelColor() {
    switch (alert.level) {
      case 'DANGER':
        return Colors.red[700]!;
      case 'MINOR':
        return Colors.green;
      case 'MAJOR':
        return Colors.yellow;
      case 'CRITICAL':
        return Colors.deepOrange;
      default:
        return Colors.blueGrey;
    }
  }

  String _getCondition() {
    switch (alert.condition) {
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
