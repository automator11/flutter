import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/themes/colors.dart';
import 'widgets.dart';

class MyDialogs {
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          key: const Key('loadingDialogKey'),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 10,
              ),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showErrorDialog(
      BuildContext context, String error) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: _buildDialogContent(context, 'Error', error),
      ),
    );
  }

  static Future<void> showSuccessDialog(
      BuildContext context, String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: _buildDialogContent(context, 'success'.tr(), message),
      ),
    );
  }

  static Future<dynamic> showQuestionDialog(
      {required BuildContext context,
      required String title,
      required String message,
      VoidCallback? onOkButtonPressed}) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: _buildDialogContent(context, title, message,
            okText: 'accept'.tr(),
            cancelText: 'cancel'.tr(),
            hasCancelButton: true,
            onOkAction: onOkButtonPressed ?? () {}),
      ),
    );
  }

  static Widget _buildDialogContent(
      BuildContext context, String title, String message,
      {bool hasCancelButton = false,
      String? cancelText,
      String? okText,
      VoidCallback? onOkAction}) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 700, maxWidth: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Color(0xFF030405),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(message,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.start),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasCancelButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(context, false);
                        },
                        child: Text(cancelText ?? 'close'.tr(),
                            style: const TextStyle(color: kPrimaryColor)),
                      ),
                    ),
                  CustomElevatedButton(
                    borderRadius: 8,
                    onPressed: () async {
                      if (onOkAction != null) {
                        onOkAction();
                      }
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      okText ?? 'accept'.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
