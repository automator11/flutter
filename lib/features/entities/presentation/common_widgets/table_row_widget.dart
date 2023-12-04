import 'package:flutter/material.dart';

class TableRowWidget extends StatelessWidget {
  final List<Widget> cells;
  final BorderRadius? rowBorderRadius;
  final Color? rowBackgroundColor;
  final BoxBorder? rowBorderSide;

  const TableRowWidget(
      {super.key,
      required this.cells,
      this.rowBorderRadius,
      this.rowBackgroundColor,
      this.rowBorderSide});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      height: 45,
      decoration: BoxDecoration(
          borderRadius: rowBorderRadius,
          color: rowBackgroundColor ?? Colors.transparent,
          border: rowBorderSide),
      child: Row(
        children: cells.map((e) => Expanded(child: e)).toList(),
      ),
    );
  }
}
