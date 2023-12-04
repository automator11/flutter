import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NoItemsFoundWidget extends StatelessWidget {
  final VoidCallback? onRefresh;
  const NoItemsFoundWidget({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: const Text("noItemsFound").tr(),
      ),
    );
  }
}
