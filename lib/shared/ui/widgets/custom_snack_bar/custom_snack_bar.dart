import 'package:flutter/material.dart';

class CustomSnackBar extends StatefulWidget {
  final List<BoxShadow> boxShadow;
  final BorderRadius borderRadius;
  final double textScaleFactor;
  final Widget child;

  const CustomSnackBar.snackBar({
    super.key,
    this.boxShadow = kDefaultBoxShadow,
    this.borderRadius = kDefaultBorderRadius,
    this.textScaleFactor = 1.0,
    required this.child,
  });

  @override
  CustomSnackBarState createState() => CustomSnackBarState();
}

class CustomSnackBarState extends State<CustomSnackBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
      ),
      child: widget.child,
    );
  }
}

const kDefaultBoxShadow = [
  BoxShadow(
    color: Colors.black26,
    offset: Offset(4, 8),
    spreadRadius: 0.2,
    blurRadius: 10,
  ),
];

const kDefaultBorderRadius = BorderRadius.all(Radius.circular(12));
