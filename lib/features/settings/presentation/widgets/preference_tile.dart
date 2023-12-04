import 'package:flutter/material.dart';


class PreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onPrefSelected;
  final Widget? trailing;

  const PreferenceTile({
    required this.title,
    required this.subtitle,
    this.onPrefSelected,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        onTap: onPrefSelected,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}
