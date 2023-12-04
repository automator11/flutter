import 'package:flutter/material.dart';

import '../../../../config/themes/colors.dart';

class CustomElevatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? progressIndicatorColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const CustomElevatedButton(
      {super.key,
      required this.child,
      required this.onPressed,
      this.isLoading = false,
      this.progressIndicatorColor,
      this.backgroundColor,
      this.borderRadius,
      this.padding});

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: widget.padding,
            backgroundColor: widget.backgroundColor ?? kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 9),
            ),
            disabledBackgroundColor: kInputDefaultBorderColor,
            textStyle: const TextStyle(color: kSecondaryColor)),
        onPressed: widget.onPressed,
        child: widget.isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: widget.progressIndicatorColor ?? Colors.white,
                  ),
                ),
              )
            : widget.child);
  }
}
