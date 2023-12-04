import 'package:flutter/material.dart';

class AnimatedIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const AnimatedIndexedStack(
      {super.key,
      required this.index,
      required this.children,
      required this.duration});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: [
        for (var i = 0; i < children.length; i++)
          AnimatedOpacity(
            opacity: index == i ? 1.0 : 0.0,
            duration: duration,
            child: children[i],
          )
      ],
    );
  }
}
