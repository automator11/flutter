import 'package:flutter/material.dart';

class NewPageErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const NewPageErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("New Page Error"),
    );
  }
}
