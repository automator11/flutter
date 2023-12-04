import 'package:flutter/material.dart';

import '../../../../config/themes/colors.dart';


class CustomOutlinedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? progressIndicatorColor;
  final Color? backgroundColor;
  final double? borderRadius;

  const CustomOutlinedButton(
      {super.key,
      required this.child,
      required this.onPressed,
      this.isLoading = false,
      this.progressIndicatorColor,
      this.backgroundColor,
      this.borderRadius});

  @override
  State<CustomOutlinedButton> createState() => _CustomOutlinedButtonState();
}

class _CustomOutlinedButtonState extends State<CustomOutlinedButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kSecondaryColor, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 15),
          ),
        ),
        onPressed: widget.onPressed,
        child: widget.isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: widget.progressIndicatorColor ?? kSecondaryColor,
                  ),
                ),
              )
            : widget.child);
  }
}
