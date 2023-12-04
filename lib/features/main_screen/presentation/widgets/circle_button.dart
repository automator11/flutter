import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final int? elevation;
  final Color? backgroundColor;

  const CircleButton(
      {super.key,
      this.onTap,
      required this.icon,
      this.elevation = 3,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              shape: BoxShape.circle,
              boxShadow: kElevationToShadow[elevation]),
          child: icon,
        ));
  }
}
