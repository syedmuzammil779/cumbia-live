import 'package:flutter/material.dart';

class MyCustomDialog extends StatelessWidget {
  final Widget child;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final double? elevation;
  final double? minWidth;

  const MyCustomDialog({
    Key? key,
    required this.child,
    this.shape,
    this.backgroundColor,
    this.elevation,
    this.minWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: shape,
      backgroundColor: backgroundColor,
      elevation: elevation ?? 24.0,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? 280.0,
        ),
        child: child,
      ),
    );
  }
}
