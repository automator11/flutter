import 'package:flutter/material.dart';


import '../../../../config/themes/colors.dart';

class CustomNavDestination extends StatelessWidget {
  final Widget icon;
  final Widget? selectedIcon;
  final String? label;
  final bool isSelected;

  const CustomNavDestination(
      {super.key,
      required this.icon,
      this.selectedIcon,
      this.label,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return isSelected
        ? Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: kSecondaryBackground,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                  ),
                  BoxShadow(
                      color: kSecondaryColor, blurRadius: 10, spreadRadius: 10),
                ]),
            child: selectedIcon)
        : SizedBox(
            width: 50,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: icon,
            ));
  }
}
