import 'package:flutter/material.dart';

/// Caps content width and centers it — without this, cards and buttons
/// stretch edge-to-edge on tablet/desktop, which reads as a broken phone
/// layout rather than a responsive one. Every screen's body wraps its
/// content in this; phones (the overwhelming common case) are narrower
/// than the cap and see no difference at all.
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({super.key, required this.child, this.maxWidth = 560});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
