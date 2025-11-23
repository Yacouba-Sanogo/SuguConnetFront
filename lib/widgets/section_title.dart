import 'package:flutter/material.dart';

/// Widget réutilisable pour les titres de section
class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.fontSize = 20,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight ?? FontWeight.bold,
              color: color ?? Colors.orange,
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}


