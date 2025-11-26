import 'package:flutter/material.dart';

/// Widget réutilisable pour un divider avec espacement
class DividerWithSpacing extends StatelessWidget {
  final double? height;
  final double? thickness;
  final Color? color;
  final double spacingBefore;
  final double spacingAfter;

  const DividerWithSpacing({
    super.key,
    this.height,
    this.thickness,
    this.color,
    this.spacingBefore = 0,
    this.spacingAfter = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: spacingBefore),
        Divider(
          height: height,
          thickness: thickness ?? 0.5,
          color: color ?? Colors.grey,
        ),
        SizedBox(height: spacingAfter),
      ],
    );
  }
}


