import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher un badge de statut
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Couleurs par défaut selon le statut
    Color bgColor = backgroundColor ?? _getDefaultBackgroundColor(status);
    Color txtColor = textColor ?? Colors.white;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: txtColor,
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Color _getDefaultBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'livrée':
      case 'livré':
        return const Color(0xFFFB662F);
      case 'en attente':
      case 'en cours':
        return Colors.orange;
      case 'annulée':
      case 'annulé':
        return Colors.red;
      case 'disponible':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}


