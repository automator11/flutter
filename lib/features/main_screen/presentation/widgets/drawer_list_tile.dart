import 'package:flutter/material.dart';

import '../../../../config/themes/colors.dart';

class DrawerListTile extends StatelessWidget {
  const DrawerListTile(
      {super.key,
      required this.title,
      required this.press,
      this.active = false,
      this.leading,
      this.activeLeading});

  final String title;
  final VoidCallback press;
  final bool active;
  final Widget? leading;
  final Widget? activeLeading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SizedBox(
          width: 30,
          height: 30,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: active ? activeLeading : leading,
          )),
      title: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          title,
          style: TextStyle(
              color: active ? kPrimaryColor : Colors.white, fontSize: 12),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: active ? Colors.white : kSecondaryColor,
    );
  }
}
