import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';
import '../../../user/data/models/models.dart';
import '../cubit/cubits.dart';

class UserMenuWidget extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onTap;

  const UserMenuWidget({super.key, required this.onTap, required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      offset: const Offset(0, 50),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
            onTap: () {
              context.read<AuthCubit>().logout();
            },
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Image.asset(
                'assets/icons/logout.png',
                width: 20,
              ),
              title: const Text(
                'logout',
                style: TextStyle(fontSize: 12, color: kPrimaryText),
              ).tr(),
            ))
      ],
      child: SizedBox(
        width: 220,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user?.name ?? '',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.fade),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                        color: kSecondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.fade),
                  ),
                  const Icon(
                    Ionicons.chevron_down_outline,
                    color: kSecondaryText,
                    size: 24,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
