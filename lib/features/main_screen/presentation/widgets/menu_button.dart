import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const MenuButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: icon,
      ),
    );
  }
}
