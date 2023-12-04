import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../config/themes/colors.dart';
import 'circle_button.dart';

class DialogContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  final double? width;

  const DialogContainer(
      {super.key, required this.child, this.onBackPressed, this.width});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.8;
    return Dialog(
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: PointerInterceptor(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: width ?? 350, maxHeight: height),
          color: Colors.white,
          child: Stack(
            children: [
              child,
              Positioned(
                  top: 16,
                  right: 16,
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircleButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Ionicons.close_outline,
                        color: kIconLightColor,
                        size: 18,
                      ),
                    ),
                  )),
              if (onBackPressed != null)
                Positioned(
                    top: 8,
                    left: 8,
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircleButton(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        icon: const Icon(
                          Ionicons.chevron_back_outline,
                          color: kIconLightColor,
                          size: 18,
                        ),
                      ),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
