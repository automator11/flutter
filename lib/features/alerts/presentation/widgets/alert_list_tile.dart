import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';



import '../../../../config/themes/colors.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../cubits/alerts_cubit.dart';

class AlertListTile extends StatefulWidget {
  final AlarmModel alert;
  final bool read;
  final VoidCallback? onTap;

  const AlertListTile(
      {super.key, required this.alert, required this.read, this.onTap});

  @override
  State<AlertListTile> createState() => _AlertListTileState();
}

class _AlertListTileState extends State<AlertListTile> {
  @override
  Widget build(BuildContext context) {
    final details = widget.alert.details;
    final title =
        details.containsKey('title') ? details['title'] : widget.alert.name;
    final message = details['message'] ?? '';
    return InkWell(
      onTap: widget.onTap,
      child: Card(
          elevation: 0,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: kPrimaryColor.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 20, 16),
                child: SizedBox(
                  width: 20,
                  child: _getLeading(),
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: kPrimaryText,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                  Text(
                    message,
                    style: const TextStyle(
                        color: kSecondaryText,
                        fontWeight: FontWeight.w400,
                        fontSize: 10),
                  ),
                ],
              )),
              IconButton(
                onPressed: () async {
                  bool result = await MyDialogs.showQuestionDialog(
                          context: context,
                          title: 'deleteAlert'.tr(),
                          message: 'deleteNotificationMessage'.tr()) ??
                      false;
                  if (result && mounted) {
                    context.read<AlertsCubit>().deleteAlert(widget.alert.id.id);
                  }
                },
                icon: const Icon(
                  Ionicons.trash_outline,
                  color: kSecondaryColor,
                  size: 20,
                ),
              )
            ],
          )),
    );
  }

  Widget _getLeading() {
    if (widget.read) {
      return Image.asset('assets/icons/read_notification.png');
    }
    return Image.asset('assets/icons/unread_notification.png');
  }
}
