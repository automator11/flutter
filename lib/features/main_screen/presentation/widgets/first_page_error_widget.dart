import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'widgets.dart';

class FirstPageErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const FirstPageErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(
          height: 40,
        ),
        Center(
            child: SizedBox(
                height: 30,
                width: 120,
                child: CustomElevatedButton(
                    borderRadius: 10,
                    onPressed: onRetry,
                    child: const Text(
                      'retry',
                      style: TextStyle(fontSize: 12),
                    ).tr())))
      ],
    );
  }
}
