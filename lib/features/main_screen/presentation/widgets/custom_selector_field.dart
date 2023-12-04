import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';


class CustomSelectorField extends StatelessWidget {
  final String label;
  final Widget value;
  final String? errorMessage;
  final VoidCallback? onTap;

  const CustomSelectorField(
      {super.key,
      required this.value,
      required this.label,
      this.errorMessage,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 12),
          child: Text(
            label,
            style: const TextStyle(
                color: kPrimaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: const Border.fromBorderSide(
                    BorderSide(color: kInputDefaultBorderColor, width: 1))),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                child: value,
              ),
              const Icon(
                Ionicons.chevron_forward_outline,
                color: kSecondaryColor,
                size: 20,
              ),
            ]),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[700], fontSize: 10),
            ),
          )
      ],
    );
  }
}
