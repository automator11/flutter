import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Destination extends Equatable {
  const Destination(
      {required this.index,
      required this.title,
      required this.icon,
      this.selectedIcon,
      required this.path,
      this.type});

  final int index;
  final String title;
  final Widget icon;
  final Widget? selectedIcon;
  final String path;
  final String? type;

  @override
  List<Object?> get props => [index, title, icon, selectedIcon, path];
}
