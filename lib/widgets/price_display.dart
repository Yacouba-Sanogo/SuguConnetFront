import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher un prix
class PriceDisplay extends StatelessWidget {
  final double price;
  final String currency;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final bool showCurrency;

  const PriceDisplay({
    super.key,
    required this.price,
    this.currency = 'fcfa',
    this.fontSize,
    this.fontWeight,
    this.color,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice = price.toStringAsFixed(0);
    final displayText = showCurrency ? '$formattedPrice $currency' : formattedPrice;

    return Text(
      displayText,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color ?? Colors.black,
      ),
    );
  }
}


